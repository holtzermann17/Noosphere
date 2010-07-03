package Noosphere::baseconf;

use vars qw(%base_config);

%base_config = (

	# secret portion of hashes
	
	HASH_SECRET => 'fill_me_with_random_junk',

	# System paths
	
	BASE_DIR => '/var/www/pm',
	ENTITY_DIR => '/var/www/pm/data/entities',
	SEARCH_ENGINE_LIB => '/var/www/lucene_search_module/clients',

	# Web paths
	
	MAIN_SITE => 'planetmath.org',
	IMAGE_SITE => 'images.planetmath.org',
	FILE_SITE => 'aux.planetmath.org',
	STATIC_SITE => 'aux.planetmath.org',
	ENTITY_SITE => 'aux.planetmath.org',
	
	BUG_URL => 'http://bugs.planetmath.org',
	DOC_URL => 'http://aux.planetmath.org/doc',
	
	# E-mail config
	
	FEEDBACK_EMAIL => 'feedback@planetmath.org',
	SYSTEM_EMAIL => 'pm@planetmath.org',
	REPLY_EMAIL => 'noreply@planetmath.org',

	# Database configuration

	DBMS => 'mysql',	# should be a valid DBI name for your DBMS
	DB_NAME => 'pm',
	DB_USER => 'pm',
	DB_PASS => '*******',
	DB_HOST => 'localhost',

	# Project customization

	PROJECT_NAME => 'PlanetMath',
	PROJECT_NICKNAME => 'PM',
	SLOGAN => 'Math for the people, by the people.',
	SUBJECT_DOMAIN => 'mathematics',

	# banned ips (usually people trying to mirror the site)

	BANNED_IPS => {
		'x.y.z.1'=>1,
		'x.y.z.2'=>1},

	# misc options

	CLASSIFICATION_SUPPORTED => 1,
	RENDERING_OUTPUT_FILE => 'planetmath.html',

	# End of config
);

