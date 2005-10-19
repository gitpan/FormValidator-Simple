package FormValidator::Simple;
use strict;
use base qw/Class::Accessor::Fast/;
use Class::Inspector;
use UNIVERSAL::require;
use FormValidator::Simple::Results;
use FormValidator::Simple::Exception;
use FormValidator::Simple::Data;
use FormValidator::Simple::Profile;
use FormValidator::Simple::Validator;
use FormValidator::Simple::Constants;

our $VERSION = '0.04';

__PACKAGE__->mk_accessors(qw/data prof results/);

sub import {
    my $class = shift;
    foreach my $plugin (@_) {
        my $plugin_class = "FormValidator::Simple::Plugin::".$plugin;
        $class->load_plugin($plugin_class);
    }
}

sub load_plugin {
    my ($proto, $plugin) = @_;
    my $class  = ref $proto || $proto;
    unless (Class::Inspector->installed($plugin)) {
        FormValidator::Simple::Exception->throw(
            qq/$plugin isn't installed./
        );
    }
    $plugin->require;
    if ($@) {
        FormValidator::Simple::Exception->throw(
            qq/Couldn't require "$plugin", "$@"./
        );
    }
    {
        no strict 'refs';
        push @FormValidator::Simple::Validator::ISA, $plugin;
    }
}

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my $self  = bless { }, $class;
    $self->_init(@_);
    return $self;
}

sub _init {
    my ($self, %options) = @_;
    FormValidator::Simple::Validator->options( \%options );
    $self->results( FormValidator::Simple::Results->new );
}

sub set_invalid {
    my ($self, $name, $type) = @_;
    unless (ref $self) {
        FormValidator::Simple::Exception->throw(
            qq/set_invalid is instance method./
        );
    }
    unless ($name && $type) {
        FormValidator::Simple::Exception->throw(
            qq/set_invalid needs two arguments./
        );
    }
    $self->results->set_result($name, $type, FALSE);
}

sub check {
    my ($proto, $input, $prof, $options) = @_;
    $options ||= {};
    my $self = ref $proto ? $proto : $proto->new(%$options);

    my $data = FormValidator::Simple::Data->new($input);
    my $prof_setting = FormValidator::Simple::Profile->new($prof);

    my $profile_iterator = $prof_setting->iterator;

    PROFILE:
    while ( my $profile = $profile_iterator->next ) {

        my $name        = $profile->name;
        my $keys        = $profile->keys;
        my $constraints = $profile->constraints;

        #KEYCHECK:
        #foreach my $key (@$keys) {
        #    next PROFILE unless $data->has_key($key);
        #}
        my $params = $data->param($keys);

        $self->results->register($name);

        $self->results->record($name)->data( @$params == 1 ? $params->[0] : '');

        my $constraint_iterator = $constraints->iterator;
        if ( scalar @$params == 1 ) {
            unless ( defined $params->[0] && $params->[0] ne '' ) {
                if ( $constraints->needs_blank_check ) {
                    $self->results->record($name)->is_blank( TRUE );
                }
                next PROFILE;
            }
        }

        CONSTRAINT:
        while ( my $constraint = $constraint_iterator->next ) {

            my ($result, $data) = $constraint->check($params);

            $self->results->set_result($name, $constraint->name, $result);

            $self->results->record->data($data) if $data;
        }

    }
    return $self->results;
}

1;
__END__

=head1 NAME

FormValidator::Simple - validation with simple chains of constraints 

=head1 SYNOPSIS

    my $query = CGI->new;
    $query->param( param1 => 'ABCD' );
    $query->param( param2 =>  12345 );
    $query->param( mail1  => 'lyo.kato@gmail.com' );
    $query->param( mail2  => 'lyo.kato@gmail.com' );
    $query->param( year   => 2005 );
    $query->param( month  =>   11 );
    $query->param( day    =>   27 );

    my $result = FormValidator::Simple->check( $query => [
        param1 => ['NOT_BLANK', 'ASCII', ['LENGTH', 2, 5]],
        param2 => ['NOT_BLANK', 'INT'  ],
        mail1  => ['NOT_BLANK', 'EMAIL_LOOSE'],
        mail2  => ['NOT_BLANK', 'EMAIL_LOOSE'],
        { mails => ['mail1', 'mail2'       ] } => ['DUPLICATION'],
        { date  => ['year',  'month', 'day'] } => ['DATE'],
    ] );

    if ( $result->has_missing or $results->has_invalid ) {
        my $tt = Template->new({ INCLUDE_PATH => './tmpl' });
        $tt->process('template.html', { result => $result });
    }

template example

    [% IF result.has_invalid || result.has_missing %]
    <p>Found Input Error</p>
    <ul>

        [% IF result.missing('param1') %]
        <li>param1 is blank.</li>
        [% END %]

        [% IF result.invalid('param1') %]
        <li>param1 is invalid.</li>
        [% END %]

        [% IF result.invalid('param1', 'ASCII') %]
        <li>param1 needs ascii code.</li>
        [% END %]

        [% IF result.invalid('param1', 'LENGTH') %]
        <li>input into param1 with characters that's length should be between two and five. </li>
        [% END %]

    </ul>
    [% END %]

=head1 DESCRIPTION

This module provides you a sweet way of form data validation with simple constraints chains.
You can write constraints on single line for each input data.

This idea is based on Sledge::Plugin::Validator, and most of validation code is borrowed from this plugin.

(Sledge is a MVC web application framework: http://sl.edge.jp [Japanese] )

The result object this module returns behaves like L<Data::FormValidator::Results>.

=head1 HOW TO SET PROFILE

    FormValidator::Simple->check( $q => [
        #profile
    ] );

Use 'check' method. 

A hash reference includes input data, or an object of some class that has a method named 'param', for example L<CGI>, is needed as first argument.

And set profile as array reference into second argument. Profile confists of some pairs of input data and constraints.

    my $q = CGI->new;
    $q->param( param1 => 'hoge' );

    FormValidator::Simple->check( $q => [
        param1 => [ ['NOT_BLANK'], ['LENGTH', 4, 10] ],
    ] );

In this case, param1 is the name of a form element. and the array ref "[ ['NOT_BLANK']... ]" is a constraints chain.

Write constraints chain as arrayref, and you can set some constraints into it. In the last example, two constraints
'NOT_BLANK', and 'LENGTH' are set. Each constraints is should be set as arrayref, but in case the constraint has no
argument, it can be written as scalar text.

    FormValidator::Simple->check( $q => [
        param1 => [ 'NOT_BLANK', ['LENGTH', 4, 10] ],
    ] );

Now, in this sample 'NOT_BLANK' constraint is not an arrayref, but 'LENGTH' isn't. Because 'LENGTH' has two arguments, 4 and 10.

=head2 MULTIPLE DATA VALIDATION

When you want to check about multiple input data, do like this.

    my $q = CGI->new;
    $q->param( mail1 => 'lyo.kato@gmail.com' );
    $q->param( mail2 => 'lyo.kato@gmail.com' );

    my $result = FormValidator::Simple->check( $q => [
        { mails => ['mail1', 'mail2'] } => [ 'DUPLICATION' ],
    ] )

    [% IF result.invalid('mails') %]
    <p>mail1 and mail2 aren't same.</p>
    [% END %]

and here's an another example.

    my $q = CGI->new;
    $q->param( year  => 2005 );
    $q->param( month =>   12 );
    $q->param(   day =>   27 );

    my $result = FormValidator::Simple->check( $q => [ 
        { date => ['year', 'month', 'day'] } => [ 'DATE' ],
    ] );

    [% IF result.invalid('date') %]
    <p>Set correct date.</p>
    [% END %]

=head2 FLEXIBLE VALIDATION

    my $valid = FormValidator::Simple->new();

    $valid->check( $q => [ 
        param1 => [qw/NOT_BLANK ASCII/, [qw/LENGTH 4 10/] ],
    ] );

    $valid->check( $q => [
        param2 => [qw/NOT_BLANK/],
    ] );

    my $results = $valid->results;

    if ( found some error... ) {
        $results->set_invalid('param3' => 'MY_ERROR');
    }

template example

    [% IF results.invalid('param1') %]
    ...
    [% END %]
    [% IF results.invalid('param2') %]
    ...
    [% END %]
    [% IF results.invalid('param3', 'MY_ERROR') %]
    ...
    [% END %]

=head1 VALIDATION COMMANDS

You can use follow variety validations.
and each validations can be used as negative validation with 'NOT_' prefix.

    FormValidator::Simple->check( $q => [ 
        param1 => [ 'INT', ['LENGTH', 4, 10] ],
        param2 => [ 'NOT_INT', ['NOT_LENGTH', 4, 10] ],
    ] );

=over 4

=item SP

check if the data has space or not.

=item INT

check if the data is integer or not.

=item ASCII

check is the data consists of only ascii code.

=item LENGTH

check the length of the data.

    my $result = FormValidator::Simple->check( $q => [
        param1 => [ ['LENGTH', 4] ],
    ] );

check if the length of the data is 4 or not.

    my $result = FormValidator::Simple->check( $q => [
        param1 => [ ['LENGTH', 4, 10] ],
    ] );

when you set two arguments, it checks if the length of data is in
the range between 4 and 10.

=item SELECTED_AT_LEAST

verify the selected parameters is counted over allowed minimum.

    <input type="checkbox" name="hobby" value="music" /> Music
    <input type="checkbox" name="hobby" value="movie" /> Movie
    <input type="checkbox" name="hobby" value="game"  /> Game

    my $result = FormValidator::Simple->check( $q => [ 
        hobby => ['NOT_BLANK', ['SELECTED_AT_LEAST', 2] ],
    ] );

=item REGEX

check with regular expression.

    my $result = FormValidator::Simple->check( $q => [ 
        param1 => [ ['REGEX', qr/^hoge$/ ] ],
    ] );

=item DUPLICATION

check if the two data are same or not.

    my $result = FormValidator::Simple->check( $q => [ 
        { duplication_check => ['param1', 'param2'] } => [ 'DUPLICATION' ],
    ] );

=item EMAIL

check with L<Email::Valid>.

=item EMAIL_MX

check with L<Email::Valid>, including  mx check.

=item EMAIL_LOOSE

check with L<Email::Valid::Loose>.

=item EMAIL_LOOSE_MX

check with L<Email::Valid::Loose>, including mx check.

=item DATE

check with L<Date::Calc>

    my $result = FormValidator::Simple->check( $q => [ 
        { date => [qw/year month day/] } => [ 'DATE' ]
    ] );

=item TIME

check with L<Date::Calc>

    my $result = FormValidator::Simple->check( $q => [
        { time => [qw/hour min sec/] } => ['TIME'],
    ] );

=item DATETIME

check with L<Date::Calc>

    my $result = FormValidator::Simple->check( $q => [ 
        { datetime => [qw/year month day hour min sec/] } => ['DATETIME']
    ] );


=item ANY

check if there is not blank data in multiple data.

    my $result = FormValidator::Simple->check( $q => [ 
        { some_data => [qw/param1 param2 param3/] } => ['ANY']
    ] );

=back

=head1 HOW TO LOAD PLUGINS

    use FormValidator::Simple qw/Japanese CreditCard/;

L<FormValidator::Simple::Plugin::Japanese>, L<FormValidator::Simple::Plugin::CreditCard> are loaded.

or use 'load_plugin' method.

    use FormValidator::Simple;
    FormValidator::Simple->load_plugin('FormValidator::Simple::Plugin::CreditCard');

=head1 TODO

=over 4

=item MORE VARIETY VALIDATIONS

=item MESSAGE MAPPING

sweet solution to put out messages on your application's error page.

=item MORE VERBOSE EXCEPTION

to make it easier to find wrong setting.

=item MORE DOCUMENTATION

=back

=head1 SEE ALSO

L<Data::FormValidator>

http://sl.edge.jp/ (Japanese)

http://sourceforge.jp/projects/sledge

=head1 AUTHOR

Lyo Kato E<lt>lyo.kato@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

This library is free software.
You can redistribute it and/or modify it under the same terms as perl itself.

=cut

