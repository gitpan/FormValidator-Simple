package FormValidator::Simple::Validator;
use strict;
use base qw/Class::Data::Inheritable/;

use FormValidator::Simple::Constants;
use FormValidator::Simple::Exception;
use Email::Valid;
use Email::Valid::Loose;
use Date::Calc;

__PACKAGE__->mk_classdata( options => { } );

sub SP {
	my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return $data =~ /\s/ ? TRUE : FALSE;
}

sub INT {
	my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return $data =~ /^\-?[\d]+$/ ? TRUE : FALSE;
}

sub ASCII {
	my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return $data =~ /^[\x21-\x7E]+$/ ? TRUE : FALSE;
}

sub DUPLICATION {
	my ($self, $params, $args) = @_;
    my $data1 = $params->[0];
    my $data2 = $params->[1];
    unless (defined $data1 && defined $data2) {
        FormValidator::Simple::Exception->throw(
        qq/validation "DUPLICATION" needs two keys of data./
        );
    }
    return $data1 eq $data2 ? TRUE : FALSE;
}

sub LENGTH {
	my ($self, $params, $args) = @_;
    unless ( scalar(@$args) > 0 ) {
        FormValidator::Simple::Exception->throw(
        qq/validation "LENGTH" needs one or two arguments./
        );
    }
    my $data   = $params->[0];
    my $length = length $data;
    my $min    = $args->[0];
    my $max    = $args->[1] || $min;
    $min += 0;
    $max += 0;
    return $min <= $length && $length <= $max ? TRUE : FALSE;
}

sub REGEX {
	my ($self, $params, $args) = @_;
    my $data  = $params->[0];
    my $regex = $args->[0];
    return $data =~ /$regex/ ? TRUE : FALSE;
}

sub EMAIL {
    my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return FALSE unless $data;
    return Email::Valid->address(-address => $data) ? TRUE : FALSE;
}

sub EMAIL_MX {
    my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return FALSE unless $data;
    return Email::Valid->address(-address => $data, -mxcheck => 1) ? TRUE : FALSE;
}

sub EMAIL_LOOSE {
    my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return FALSE unless $data;
    return Email::Valid::Loose->address($data) ? TRUE : FALSE;
}

sub EMAIL_LOOSE_MX {
    my ($self, $params, $args) = @_;
    my $data = $params->[0];
    return FALSE unless $data;
    return Email::Valid::Loose->address(-address => $data, -mxcheck => 1) ? TRUE : FALSE;
}

sub DATE {
    my ($self, $params, $args) = @_;
    my ($year, $month,  $day ) = @$params;
    my $result = Date::Calc::check_date($year, $month, $day) ? TRUE : FALSE;
    return $result;
}

sub TIME {
    my ($self, $params, $args) = @_;
    my ($hour, $min,    $sec ) = @$params;
    $hour ||= 0;
    $min  ||= 0;
    $sec  ||= 0;
    my $result = Date::Calc::check_time($hour, $min, $sec) ? TRUE : FALSE;
    return $result;
}

sub DATETIME {
    my ($self, $params, $args) = @_;
    my ($year, $month, $day, $hour, $min, $sec) = @$params;
    $hour ||= 0;
    $min  ||= 0;
    $sec  ||= 0;
    my $result = Date::Calc::check_date($year, $month, $day)
              && Date::Calc::check_time($hour, $min,   $sec) ? TRUE : FALSE;
    return $result;
}

sub ANY {
    my ($self, $params, $args) = @_;
    foreach my $param ( @$params ) {
        return TRUE if ( defined $param && $param ne '' );
    }
    return FALSE;
}

1;
__END__

