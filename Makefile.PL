use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'FormValidator::Simple',
    VERSION_FROM      => 'lib/FormValidator/Simple.pm', # finds $VERSION
    PREREQ_PM         => {
		'Class::Accessor'          => 0.22,
		'Class::Inspector'         => 1.13,
		'Class::Data::Inheritable' => 0.04,
		'UNIVERSAL::require'       => 0,
        'Mail::Address'            => 0,
		'Email::Valid'             => 0.15,
		'Email::Valid::Loose'      => 0.04,
        'Date::Calc'               => 5.4,
	}, # e.g., Module::Name => 1.1
);

