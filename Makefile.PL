use strict;
use warnings;
use ExtUtils::MakeMaker;

# http://wiki.cpantesters.org/wiki/CPANAuthorNotes
exit 0 unless -x '/usr/bin/svnlook';

WriteMakefile(
    NAME                => 'SVN::Hooks',
    AUTHOR              => 'Gustavo Chaves <gustavo+perl@gnustavo.com>',
    VERSION_FROM        => 'lib/SVN/Hooks.pm',
    ABSTRACT_FROM       => 'lib/SVN/Hooks.pm',
    PL_FILES            => {},
    LICENSE             => 'perl',
    PREREQ_PM => {
	'Email::Send'   => 0,
	'Email::Simple' => 0,
	'Email::Simple::Creator' => 0,
	'Switch'        => 0,
	'XMLRPC::Lite'  => 0,
        'Test::More'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'SVN-Hooks-*' },
);
