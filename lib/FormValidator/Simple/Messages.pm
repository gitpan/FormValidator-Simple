package FormValidator::Simple::Messages;
use strict;
use YAML;
use FormValidator::Simple::Exception;

sub new {
    my $class = shift;
    my $self  = bless {
        _data => undef,
    }, $class;
    return $self;
}

sub load {
    my ($self, $data) = @_;
    if (ref $data eq 'HASH') {
        $self->{_data} = $data;
    }
    elsif (-e $data && -f _ && -r _) {
        eval {
        $self->{_data} = YAML::LoadFile($data);
        };
        if ($@) {
        FormValidator::Simple::Exception->throw(
        qq/faled to load YAML file. "$@"/
        );
        }
    }
    else {
        FormValidator::Simple::Exception->throw(
        qq/set hash reference or YAML file path./
        );
    }
}

sub get {
    my ($self, $action, $name, $type) = @_;
    my $data = $self->{_data};
    unless ($data) {
    FormValidator::Simple::Exception->throw(
    qq/load file before calling get()./
    );
    }
    unless ( exists $data->{$action} ) {
    FormValidator::Simple::Exception->throw(
    qq/Unknown action-name "$action"./
    );
    }
    if ( exists $data->{$action}{$name} ) {
        my $conf = $data->{$action}{$name};
        if ( exists $conf->{$type} ) {
            return $conf->{$type};
        }
        elsif ( exists $conf->{DEFAULT} ) {
            return $conf->{DEFAULT};
        }
        else {
        FormValidator::Simple::Exception->throw(
        qq/Unknown validation type "$type"./
        );
        }
    }
    return "$name is invalid.";
}

1;
__END__

