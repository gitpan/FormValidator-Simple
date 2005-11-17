use strict;
use Test::More tests => 5;
BEGIN{ use_ok("FormValidator::Simple") }
use CGI;

FormValidator::Simple->set_messages( {
    test => {
        data1 => {
            NOT_BLANK => 'input data1',
            INT       => 'input integer for data1',
            LENGTH    => 'data1 has wrong length',
        },
        data2 => {
            DEFAULT => 'default error for data2',
        },
        data3 => {
            NOT_BLANK => 'input data3',
        },
    },
} );

my $q = CGI->new;
$q->param( data1 => 'hoge' );
$q->param( data2 => '123'  );
$q->param( data3 => ''     );

my $r = FormValidator::Simple->check( $q => [
    data1 => [qw/NOT_BLANK INT/, [qw/LENGTH 0 3/] ],
    data2 => [qw/NOT_BLANK ASCII/, [qw/LENGTH 5/]],
    data3 => [qw/NOT_BLANK/], 
] );

my $messages = $r->messages('test');
is($messages->[0], 'input integer for data1');
is($messages->[1], 'data1 has wrong length');
is($messages->[2], 'default error for data2');
is($messages->[3], 'input data3');

