# -*- cperl -*-

use strict;
use warnings;
use lib 't';
use Test::More;

require "test-functions.pl";

if (can_svn()) {
    plan tests => 13;
}
else {
    plan skip_all => 'Cannot find or use svn commands.';
}

my $t    = reset_repo();
my $wc   = catdir($t, 'wc');
my $file = catfile($wc, 'file');

set_hook(<<'EOS');
use SVN::Hooks::UpdateConfFile;
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE();
EOS

work_nok('require first arg', 'UPDATE_CONF_FILE: invalid first argument.', <<"EOS");
echo asdf >$file
svn add -q --no-auto-props $file
svn ci -mx $file
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE('first');
EOS

work_nok('require second arg', 'UPDATE_CONF_FILE: invalid second argument.', <<"EOS");
svn ci -mx $file
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE('first', qr/regexp/);
EOS

work_nok('invalid second arg', 'UPDATE_CONF_FILE: invalid second argument', <<"EOS");
svn ci -mx $file
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE('first', 'second', 'third');
EOS

work_nok('odd number of args', 'UPDATE_CONF_FILE: odd number of arguments.', <<"EOS");
svn ci -mx $file
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE('first', 'second', validator => 'string');
EOS

work_nok('not code-ref', 'UPDATE_CONF_FILE: validator argument must be a CODE-ref or an ARRAY-ref', <<"EOS");
svn ci -mx $file
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE('first', 'second', foo => 'string');
EOS

work_nok('invalid function', 'UPDATE_CONF_FILE: invalid function names:', <<"EOS");
svn ci -mx $file
EOS

set_conf(<<'EOS');
UPDATE_CONF_FILE(file => 'file');

sub validate {
    my ($text, $file) = @_;
    die "undefined second argument" unless defined $file;
    if ($text =~ /abort/) {
	die "Aborting!"
    }
    else {
	return 1;
    }
}

UPDATE_CONF_FILE(validate  => 'validate',
                 validator => \&validate);

sub generate {
    my ($text, $file) = @_;
    die "undefined second argument" unless defined $file;
    return "[$file, $text]\n";
}

UPDATE_CONF_FILE(generate  => 'generate',
                 generator => \&generate);
EOS

my $conf  = catdir($t, 'repo', 'conf');
my $cfile = catfile($conf, 'file');

# Implement a script to compare two files. In Unix we would use 'cmp'
# but in Windows I couldn't use 'comp' because it's interactive.

my $cmp = catfile($t, 'cmp.pl');
{
    open my $fh, '>', $cmp or die "Can't open '$cmp' for writing: $!\n";
    print $fh <<'EOS';
use File::Compare;
compare(@ARGV);
EOS
}

my $perl = $^X;

work_ok('update without validation', <<"EOS");
svn ci -mx $file
$perl $cmp $file $cfile
EOS

my $validate  = catfile($wc, 'validate');
my $cvalidate = catfile($conf, 'validate');

work_ok('update valid', <<"EOS");
echo asdf >$validate
svn add -q --no-auto-props $validate
svn ci -mx $validate
$perl $cmp $validate $cvalidate
EOS

work_nok('update aborting', 'UPDATE_CONF_FILE: Validator aborted for:', <<"EOS");
echo abort >$validate
svn ci -mx $validate
EOS

my $generate  = catfile($wc, 'generate');
my $cgenerate = catfile($conf, 'generate');
my $generated = catfile($wc, 'generated');

{
    open my $fh, '>', $generated
      or die "Can't create $generated: $!\n";
    print $fh <<'EOS';
[generate, asdf
]
EOS
}

work_ok('generate', <<"EOS");
echo asdf >$generate
svn add -q --no-auto-props $generate
svn ci -mx $generate
$perl $cmp $generated $cgenerate
EOS

my $config = <<'EOS';
UPDATE_CONF_FILE(subfile => 'subdir');

UPDATE_CONF_FILE(qr/^file(\d)$/ => '$1-file');

sub actuate {
    my ($text, $file) = @_;
    die "undefined second argument" unless defined $file;
    open F, '>', "TTT/repo/conf/really-actuated" or die $!;
    print F $text;
    close F;
}

UPDATE_CONF_FILE(actuate  => 'actuate',
                 actuator => \&actuate);
EOS

$config =~ s/TTT/$t/;

set_conf($config);

my $subdir = catdir($conf, 'subdir');

mkdir $subdir;

my $subfile  = catfile($wc, 'subfile');
my $csubfile = catfile($subdir, 'subfile');

work_ok('to subdir', <<"EOS");
echo asdf >$subfile
svn add -q --no-auto-props $subfile
svn ci -mx $subfile
$perl $cmp $subfile $csubfile
EOS

my $cfile1 = catfile($conf, '1-file');

work_ok('regexp', <<"EOS");
echo asdf >${file}1
svn add -q --no-auto-props ${file}1
svn ci -mx ${file}1
$perl $cmp ${file}1 $cfile1
EOS

my $actuate  = catfile($wc, 'actuate');
my $cactuate = catfile($conf, 'really-actuated');

work_ok('actuate', <<"EOS");
echo asdf >$actuate
svn add -q --no-auto-props $actuate
svn ci -mx $actuate
$perl $cmp $actuate $cactuate
EOS
