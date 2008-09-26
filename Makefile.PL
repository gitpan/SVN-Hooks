use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SVN::Hooks',
    AUTHOR              => 'Gustavo Chaves <gustavo+perl@gnustavo.com>',
    VERSION_FROM        => 'lib/SVN/Hooks.pm',
    ABSTRACT_FROM       => 'lib/SVN/Hooks.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Email::Send'   => 0,
	'Email::Simple' => 0,
	'Email::Simple::Creator' => 0,
	'Switch'        => 0,
	'XMLRPC::Lite'  => 0,
        'Test::More'    => 0,
	'SVN::Look'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'SVN-Hooks-*' },
);
