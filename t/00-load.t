#!/usr/bin/perl

use strict;
use warnings;
use lib 't';
use Test::More tests => 1;

require "test-functions.pl";

my $t = reset_repo();

set_hook(<<'EOS');
use SVN::Hooks::CheckMimeTypes;
use SVN::Hooks::AccessControl;
use SVN::Hooks::DenyChanges;
use SVN::Hooks::CheckMimeTypes;
use SVN::Hooks::CheckProperty;
use SVN::Hooks::CheckStructure;
use SVN::Hooks::DenyFilenames;
use SVN::Hooks::JiraAcceptance;
use SVN::Hooks::Mailer;
use SVN::Hooks::UpdateConfFile;
EOS

work_ok('commit' => <<"EOS");
touch $t/wc/file
svn add -q --no-auto-props $t/wc/file
svn ci -q -mx $t/wc/file
EOS
