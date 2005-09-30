use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'FormValidator::Simple',
    VERSION_FROM      => 'lib/FormValidator/Simple.pm', # finds $VERSION
    PREREQ_PM         => {
		'Class::Accessor'          => 0,
		'Class::Inspector'         => 0,
		'Class::Data::Inheritable' => 0.04,
		'UNIVERSAL::require'       => 0,
		'Email::Valid'             => 0,
		'Email::Valid::Loose'      => 0,
        'Date::Calc'               => 0,
	}, # e.g., Module::Name => 1.1
);

