package FormValidator::Simple::Results;
use strict;
use base qw/Class::Accessor::Fast/;
use FormValidator::Simple::Result;
use FormValidator::Simple::Exception;
use FormValidator::Simple::Constants;

__PACKAGE__->mk_accessors(qw/_records/);

sub new {
    my $class = shift;
    my $self  = bless { }, $class;
    $self->_init(@_);
    return $self;
}

sub _init {
    my $self = shift;
    $self->_records( { } );
}

sub register {
    my ($self, $name) = @_;
    $self->_records->{$name}
        ||= FormValidator::Simple::Result->new($name);
}

sub record {
    my ($self, $name) = @_;
    $self->register($name)
    unless exists $self->_records->{$name};
    return $self->_records->{$name};
}

sub set_result {
    my ($self, $name, $type, $result) = @_;
    $self->register($name);
    $self->record($name)->set($type, $result);
}

sub has_blank {
    my $self = shift;
    foreach my $record ( values %{ $self->_records } ) {
        return TRUE if $record->is_blank;
    }
    return FALSE;
}

*has_missing = \&has_blank;

sub has_invalid {
    my $self = shift;
    foreach my $record ( values %{ $self->_records } ) {
        return TRUE if $record->is_invalid;
    }
    return FALSE;
}

sub valid {
    my ($self, $name) = @_;
    if ($name) {
        return unless exists $self->_records->{$name};
        return $self->record($name)->is_valid
             ? $self->record($name)->data : FALSE;
    }
    else {
        my %valids
            = map  { ( $_->name, $_->data ) }
              grep { $_->is_valid }
                   values %{ $self->_records };

        return \%valids;
    }
}

sub blank {
    my ($self, $name) = @_;
    if ($name) {
        return $self->record($name)->is_blank ? TRUE : FALSE;
    }
    else {
        my @blanks
            = sort { $a cmp $b    }
              map  { $_->name     }
              grep { $_->is_blank }
                   values %{ $self->_records };

        return wantarray ? @blanks : \@blanks;
    }
}

*missing = \&blank;

sub invalid {
    my ($self, $name, $constraint) = @_;
    if ($name) {
        if ($constraint) {
            $self->record($name)->is_invalid_for($constraint)
                ? TRUE : FALSE;
        }
        else {
            if ($self->record($name)->is_invalid) {
                my $constraints = $self->record($name)->constraints;
                my @invalids =  sort { $a cmp $b } grep { !$constraints->{$_} }
                                keys %$constraints;
                return wantarray ? @invalids : \@invalids;
            }
            else {
                return FALSE;
            }
        }
    }
    else {
        my @invalids
            = sort { $a cmp $b      }
              map  { $_->name       }
              grep { $_->is_invalid }
                   values %{ $self->_records };

        return wantarray ? @invalids : \@invalids;
    }
}

1;
__END__

