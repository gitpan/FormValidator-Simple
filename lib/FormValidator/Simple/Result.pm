package FormValidator::Simple::Result;
use strict;
use base qw/Class::Accessor::Fast/;
use FormValidator::Simple::Constants;
use FormValidator::Simple::Exception;

__PACKAGE__->mk_accessors(qw/name constraints data is_blank/);

sub new {
    my $class = shift;
    my $self  = bless { }, $class;
    $self->_init(@_);
    return $self;
}

sub _init {
    my ($self, $name) = @_; 
    $self->name($name);
    $self->constraints( { } );
    $self->data( undef );
    $self->is_blank( FALSE );
}

sub set {
    my ($self, $constraint, $result) = @_;
    $self->constraints->{$constraint} = $result;
}

sub is_valid {
    my $self   = shift;
    return FALSE if $self->is_blank;
    foreach my $result ( values %{ $self->constraints } ) {
        return FALSE unless $result;
    }
    return TRUE;
}

sub is_invalid {
    my $self = shift;
    return FALSE if $self->is_blank;
    foreach my $result ( values %{ $self->constraints } ) {
        return TRUE unless $result;
    }
    return FALSE;
}

sub is_valid_for {
    my ($self, $constraint) = @_;
    return TRUE unless exists $self->constraints->{$constraint};
    return $self->constraints->{$constraint} ? TRUE : FALSE;
}

sub is_invalid_for {
    my ($self, $constraint) = @_;
    return FALSE unless exists $self->constraints->{$constraint};
    return $self->constraints->{$constraint} ? FALSE : TRUE;
}

1;
__END__

