use strict;
use Test::More tests => 3;

BEGIN{ use_ok("FormValidator::Simple") }

use CGI;

my $q = CGI->new;
$q->param( foo => 'foo' );
$q->param( bar => 'bar' );

my $r = FormValidator::Simple->check( $q => [ 
    foo => [ [qw/IN_ARRAY foo bar buz/] ],
    bar => [ [qw/IN_ARRAY foo buz/] ],
] );

ok(!$r->invalid('foo'));
ok($r->invalid('bar'));
