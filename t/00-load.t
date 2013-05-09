#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 4;

BEGIN {
    use_ok( 'Ivacuum::Utils' ) || print "Bail out!\n";
    use_ok( 'Ivacuum::Utils::BitTorrent' ) || print "Bail out!\n";
    use_ok( 'Ivacuum::Utils::DB' ) || print "Bail out!\n";
    use_ok( 'Ivacuum::Utils::HTTP' ) || print "Bail out!\n";
}

diag( "Testing Ivacuum::Utils $Ivacuum::Utils::VERSION, Perl $], $^X" );
