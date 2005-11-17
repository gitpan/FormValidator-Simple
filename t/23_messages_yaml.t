use strict;
use Test::More tests => 5;
BEGIN{ use_ok("FormValidator::Simple") }
use CGI;
my $conf_file = "t/conf/messages.yml";
FormValidator::Simple->set_messages($conf_file);

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

