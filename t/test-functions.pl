# Copyright (C) 2008 by CPqD

BEGIN { $ENV{PATH} = '/bin:/usr/bin' }

use strict;
use warnings;
use Cwd;
use File::Temp qw/tempdir/;

# Make sure the svn messages come in English.
$ENV{LC_MESSAGES} = 'C';

our $T;

sub do_script {
    my ($num, $cmd) = @_;
    {
	open my $script, '>', "$T/script" or die;
	print $script $cmd;
	close $script;
	chmod 0755, "$T/script";
    }

    system("$T/script 1>$T/$num.stdout 2>$T/$num.stderr");
}

sub work_ok {
    my ($tag, $cmd) = @_;
    my $num = 1 + Test::Builder->new()->current_test();
    ok((do_script($num, $cmd) == 0), $tag);
}

sub work_nok {
    my ($tag, $error_expect, $cmd) = @_;

    my $num = 1 + Test::Builder->new()->current_test();
    my $exit = do_script($num, $cmd);
    if ($exit == 0) {
	fail($tag);
	return;
    }

    my $stderr = `cat $T/$num.stderr`;

    if (! ref $error_expect) {
	ok(index($stderr, $error_expect) >= 0, $tag);
    }
    elsif (ref $error_expect eq 'Regexp') {
	ok($stderr =~ $error_expect, $tag);
    }
    else {
	fail($tag);
    }
}

sub set_hook {
    my ($text) = @_;
    open my $fd, '>', "$T/repo/hooks/svn-hooks.pl"
	or die "Can't create $T/repo/hooks/svn-hooks.pl: $!";
    print $fd <<'EOS';
#!/usr/bin/perl
use strict;
use warnings;
use lib 'blib/lib';
use SVN::Hooks;
EOS
    print $fd $text, "\n";
    print $fd <<'EOS';
run_hook($0, @ARGV);
EOS
    close $fd;
    chmod 0755 => "$T/repo/hooks/svn-hooks.pl";
}

sub set_conf {
    my ($text) = @_;
    open my $fd, '>', "$T/repo/conf/svn-hooks.conf"
	or die "Can't create $T/repo/conf/svn-hooks.conf: $!";
    print $fd $text, "\n1;\n";
    close $fd;
}

sub reset_repo {
    my $cleanup = exists $ENV{REPO_CLEANUP} ? $ENV{REPO_CLEANUP} : 1;
    $T = tempdir('t.XXXX', DIR => getcwd(), CLEANUP => $cleanup);

    system(<<"EOS");
svnadmin create $T/repo
EOS

    set_hook('');

    foreach my $hook (qw/post-commit post-lock post-refprop-change post-unlock pre-commit
			 pre-lock pre-revprop-change pre-unlock start-commit/) {
	symlink 'svn-hooks.pl' => "$T/repo/hooks/$hook";
    }

    set_conf('');

    system(<<"EOS");
svn co -q file://$T/repo $T/wc
EOS

    return $T;
}

1;
