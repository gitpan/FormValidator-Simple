use strict;
use Test::More tests => 5;
use CGI;

BEGIN{ use_ok("FormValidator::Simple") }

my $q = CGI->new;

$q->param( hoge => 'test' );

my $r = FormValidator::Simple->check( $q => [
    hoge => [ [qw/LENGTH 10/], [qw/INT/], [qw/NOT_ASCII/] ],
] );

my $invalids = $r->invalid('hoge');
is(scalar(@$invalids), 3);
is($invalids->[1], 'LENGTH');
is($invalids->[0], 'INT');
is($invalids->[2], 'NOT_ASCII');


