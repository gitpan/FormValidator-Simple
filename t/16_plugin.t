use strict;
use Test::More tests => 3;
use CGI;

use lib 't/lib';

BEGIN { require_ok("FormValidator::Simple") } 

FormValidator::Simple->import('Sample');

my $q = CGI->new;
$q->param( sample1 => 'hogehoge' );
$q->param( sample2 => 'sample'   );

my $r = FormValidator::Simple->check( $q => [
    sample1 => [qw/SAMPLE/],
    sample2 => [qw/SAMPLE/],
] );

ok($r->invalid('sample1'));
ok(!$r->invalid('sample2'));

