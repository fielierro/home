#!/usr/bin/env perl
#
# Copyright © (>>>YEAR<<<)  (>>>COPYRIGHT_HOLDER<<<)
# All Rights Reserved
# 
# author: (>>>AUTHOR<<<)
# maintainer: (>>>AUTHOR<<<)
# 

use strict;
use warnings;
use Getopt::Long;

my $prog = $0;
my $usage = <<EOQ;
Usage for $0:

  >$prog [-test -help -verbose]

EOQ

my $help;
my $test;
my $debug;
my $verbose =1;


my $ok = GetOptions(
                    'test'      => \$test,
                    'debug:i'   => \$debug,
                    'verbose:i' => \$verbose,
                    'help'      => \$help,
                   );

if ($help || !$ok ) {
    print $usage;
    exit;
}

(>>>POINT<<<)

sub get_date {

    my ($day, $mon, $year) = (localtime)[3..5] ;

    return my $date= sprintf "%04d-%02d-%02d", $year+1900, $mon+1, $day;
}


