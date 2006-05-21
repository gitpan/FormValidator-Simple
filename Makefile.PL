use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'FormValidator::Simple',
    VERSION_FROM      => 'lib/FormValidator/Simple.pm', # finds $VERSION
    PREREQ_PM         => {
    'Class::Accessor'            => 0.22,
    'Class::Inspector'           => 1.13,
    'Class::Data::Inheritable'   => 0.04,
    'UNIVERSAL::require'         => 0.10,
    'Mail::Address'              => 0,
    'Email::Valid'               => 0.15,
    'Email::Valid::Loose'        => 0.04,
    'Date::Calc'                 => 5.4,
    'Tie::IxHash'                => 1.21,
    'YAML'                       => 0.39,
    'List::MoreUtils'            => 0.16,
    'Scalar::Util'               => 0,
    'DateTime::Format::Strptime' => 1.0700,
	}, # e.g., Module::Name => 1.1
);

