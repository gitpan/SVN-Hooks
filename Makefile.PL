
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A framework for implementing Subversion hooks.",
  "AUTHOR" => "Gustavo L. de M. Chaves <gnustavo\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Config" => 0,
    "English" => 0,
    "File::Copy" => 0,
    "File::Path" => 0,
    "Test::More" => 0,
    "URI::file" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "SVN-Hooks",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "SVN::Hooks",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Cwd" => 0,
    "Data::Util" => 0,
    "Exporter" => 0,
    "File::Basename" => 0,
    "File::Spec::Functions" => 0,
    "File::Temp" => 0,
    "JIRA::Client" => 0,
    "SVN::Look" => 0,
    "SVN::Notify" => 0,
    "XMLRPC::Lite" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "1.19",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



