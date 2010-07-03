package Noosphere;

use Noosphere::baseconf;

use strict;

# some globals
#
use vars qw(%tdesc %tname %table_id);

# secret portion of hashes
#
use constant SECRET=>$Noosphere::baseconf::base_config{HASH_SECRET};

# type enums for encyclopedia
#
use constant THEOREM=>1;
use constant COROLLARY=>2;
use constant PROOF=>3;
use constant DEFINITION=>5;
use constant RESULT=>6;
use constant EXAMPLE=>7;
use constant ALGORITHM=>17;
use constant DSTRUCT=>19;    # data structure
use constant AXIOM=>20;      # axiom, ie, unprovable hypothesis
use constant TOPIC=>21;      # topic or field, very general 
use constant BIOGRAPHY=>22;  # biography of a person.
use constant CONJECTURE=>24;
use constant DERIVATION=>25; 
use constant APPLICATION=>26; 
use constant FEATURE=>27; 
use constant BIBLIOGRAPHY=>28;

# special "meta types" (not real entries)
#  these are deprecated, only listed so they aren't used above.
#
use constant SYNONYM=>16;
use constant DEFINES=>23;

# action constants
use constant ACT_VOTE=>1;

# the main configuration hash
# 
use constant CONFIG=>(
  
	"projname" =>$Noosphere::baseconf::base_config{PROJECT_NAME},
	"proj_nickname" => $Noosphere::baseconf::base_config{PROJECT_NICKNAME},

	"base_dir"=>$Noosphere::baseconf::base_config{BASE_DIR},
	"entity_dir"=>$Noosphere::baseconf::base_config{ENTITY_DIR},

	"latex_cmd_prefix" => 'PM',
	"template_cmd_prefix" => 'NS',
	"rendering_output_file" => $Noosphere::baseconf::base_config{RENDERING_OUTPUT_FILE},

	# is ratings module present?
	"ratings_module" => $Noosphere::baseconf::base_config{RATINGS_MODULE},

	# banned ips
	#
	'bannedips' => $Noosphere::baseconf::base_config{BANNED_IPS},

	# regexp strings for detecting screen-scraper user-agents. 
	#
	'screen_scrapers' => ['httrack', 'wget', 'ecatch'],

 	'open_history' => $Noosphere::baseconf::base_config{'open_history'},

	# search engine stuff
	#
	'search_limit' => 50,
	'searchd_mode' => "inet", # 'unix' or 'inet'
	'searchd_loc' => "7654",
	'searchd_test_loc' => "7653",
#	unquote and change mode to 'unix' to use sockets
#	'searchd_loc' => "$Noosphere::baseconf::base_config{BASE_DIR}/bin/run/essex.sock",
#	'searchd_test_loc' => "$Noosphere::baseconf::base_config{BASE_DIR}/bin/run/essex.test.sock",
                      
	# site addresses to use in templates
	#
	"siteaddrs"=>{
		# main content  
		"main"=>$Noosphere::baseconf::base_config{MAIN_SITE}, 
		# static image serving 
		"image"=>$Noosphere::baseconf::base_config{IMAGE_SITE},
		# filebox files
		"files"=>$Noosphere::baseconf::base_config{FILE_SITE},
		# static content
		"static"=>$Noosphere::baseconf::base_config{STATIC_SITE},
		# feedback mail
		"feedback"=>$Noosphere::baseconf::base_config{FEEDBACK_EMAIL},
	}, 
	
	# root URLs for use in code
	#
	"main_url"=>"http://$Noosphere::baseconf::base_config{MAIN_SITE}",      
	"cache_url"=>"http://$Noosphere::baseconf::base_config{IMAGE_SITE}/cache",
	"image_url"=>"http://$Noosphere::baseconf::base_config{IMAGE_SITE}/images",
	"file_url"=>"http://$Noosphere::baseconf::base_config{FILE_SITE}/files",
	"forum_policy"=>"http://$Noosphere::baseconf::base_config{MAIN_SITE}/?op=getobj;from=collab;id=55",

	# leave this to direct system bugs to Noosphere home
	"bug_url" => $Noosphere::baseconf::base_config{BUG_URL},

	# a site slogan
	"slogan" => $Noosphere::baseconf::base_config{SLOGAN},

	# subject domain
	"subject_domain" => $Noosphere::baseconf::base_config{SUBJECT_DOMAIN},

	# classification support
	"classification_supported" => $Noosphere::baseconf::base_config{CLASSIFICATION_SUPPORTED},

					  
	# XSL "global" variables 
	# 
	'xsl_globals' => "

		<feedback_email>$Noosphere::baseconf::base_config{FEEDBACK_EMAIL}</feedback_email>
		<main_url>http://$Noosphere::baseconf::base_config{MAIN_SITE}</main_url>
		<doc_url>$Noosphere::baseconf::base_config{DOC_URL}</doc_url>
		<bug_url>$Noosphere::baseconf::base_config{BUG_URL}</bug_url>
		<file_url>http://$Noosphere::baseconf::base_config{FILE_SITE}/files</file_url>
		<image_url>http://$Noosphere::baseconf::base_config{IMAGE_SITE}/images</image_url>

		<static_site>http://$Noosphere::baseconf::base_config{STATIC_SITE}</static_site>
		<image_site>http://$Noosphere::baseconf::base_config{IMAGE_SITE}</image_site>

		<subject_domain>$Noosphere::baseconf::base_config{SUBJECT_DOMAIN}</subject_domain>

		<site_name>$Noosphere::baseconf::base_config{PROJECT_NAME}</site_name>
		<classification_supported>$Noosphere::baseconf::base_config{CLASSIFICATION_SUPPORTED}</classification_supported>

	",

	# robots.txt "file" contents.
	#
	'robotstxt' => "User-agent: Nutch
Disallow: /

User-agent: *
Disallow: /?",

	#BB: the list of additional files to serve from (these are cached)
	#    they are served from `files' virtual directory
	'cachedfiles' => {'style.css' => ["$Noosphere::baseconf::base_config{BASE_DIR}/stemplates/style.css",'text/css'] },

	# email addresses for the system mail account
	#
	"system_email" => $Noosphere::baseconf::base_config{SYSTEM_EMAIL},
	"reply_email" => $Noosphere::baseconf::base_config{REPLY_EMAIL},
					  
	# root server directories
	#
	"template_path"=>"$Noosphere::baseconf::base_config{BASE_DIR}/templates",
	"stemplate_path"=>"$Noosphere::baseconf::base_config{STEMPLATES_DIR}",
	"cache_root"=>"$Noosphere::baseconf::base_config{BASE_DIR}/data/cache",
    "file_root"=>"$Noosphere::baseconf::base_config{BASE_DIR}/data/files",
	"symbol_root"=>"$Noosphere::baseconf::base_config{BASE_DIR}/data/symbols",
	"version_root"=>"$Noosphere::baseconf::base_config{BASE_DIR}/data/versions",
	'single_render_root'=>'/tmp/single_render',

	# other data files
	#
	"stopwords_file"=>"$Noosphere::baseconf::base_config{BASE_DIR}/etc/stopwords.txt",

	# basic database information
	#
	"db_name"=>$Noosphere::baseconf::base_config{DB_NAME},
    "db_user"=>$Noosphere::baseconf::base_config{DB_USER},
    "db_pass"=>$Noosphere::baseconf::base_config{DB_PASS},
	"db_host"=>$Noosphere::baseconf::base_config{DB_HOST},
	"dbms"=>$Noosphere::baseconf::base_config{DBMS},

	# TeX template files
	#
	'default_preamble' => 'default_preamble.tex',
	'entry_template' => 'entry_template.tex',
	
 	# tables
	# 
	"en_tbl"=>"objects",     # encyclopedia (i know, misnamed)
	"news_tbl"=>"news",
	"user_tbl"=>"users",
	"message_tbl"=>"messages",
	"forum_tbl"=>"forums",
	"class_tbl"=>"classification",
	"msc_tbl"=>"msc",
	"papers_tbl"=>"papers",
	"polls_tbl"=>"polls",
	"action_tbl"=>"actions",
	"cor_tbl"=>"corrections",
	"nag_tbl"=>"nag",
	"xref_tbl"=>"links",
	"widx_tbl"=>"wordidx",
	"index_tbl"=>"objindex",    # main index table
	"msg_tbl"=>"messages",
	"hit_tbl"=>"hits",
	"news_tbl"=>"news",
	"cache_tbl"=>"cache",
	"exp_tbl"=>"lec",
	"books_tbl"=>"books",
	"lseen_tbl"=>"lastmsg",
	"ns_tbl"=>"ns",
	"clinks_tbl"=>"catlinks",   # category transitive closure links
	"olinks_tbl"=>"objlinks",   # links between objects
	"req_tbl"=>"requests",    
	"notice_tbl"=>"notices",
	"watch_tbl"=>"watches",
	"rsugg_tbl"=>"relsuggest", 
	"results_tbl"=>"searchresults",
	"author_tbl"=>"authors",
	"acl_tbl"=>"acl",
	"dacl_tbl"=>"acl_default",		# default ACL info table
	"groups_tbl"=>"groups",			# group listing table
	"gmember_tbl"=>"group_members",	# group membership table
	'rendered_tbl'=>'rendered_images', # rendered images table
	'storage_tbl'=>'storage', 		# persistent storage of data
	'blist_tbl'=>'blacklist', 		# email address blacklist 
	'collab_tbl'=>'collab',			# private document collaborations
	'ownerlog_tbl'=>'ownerlog',		# past owner history table

	# tables restricted by the ACL system
	#
	'acl_tables' => {'objects'=>1, 'lec'=>1, 'books'=>1, 'papers'=>1, 'collab'=>1},

	# i dont think this is actually used, but i think its supposed to be used
	# in generating the "your objects" listing
	# 
	"user_object_tables" => ['objects','news','papers','lec'],

	# numerical value of exact match "infinity" rank
	'exactrank' => 9999,
					  
	# daemon info
	"idxsrv_port"=>"3050",   # not used yet
	"spell_port"=>"3060",    # query spelling repair daemon
	"daemonpw"=>"mathnost",
                      
	# time periods
	#
	"cookie_timeout"=>14*24*60,     # minutes... 2 weeks
	"build_timeout"=>10,            # seconds after which a user is told to refresh an entry
	"render_failed"=>300,			# seconds after which a rendering is considered totally failed by the system
	"singlerender_failed"=>30,		# seconds after which an image rendering is considered totally failed by the system
	"keep_search_results"=>'30 MINUTE',
                      
	# single math environment rendering
	#
	'single_render_template_prefix'=>'single_render',
	'single_render_variants'=>['normal', 'highlight', 'title'],
					  
	# various limits and counts
	#
	'concurrent_renders'=>5,		# max # of concurrent renders to allow
	'useractivity_max'=>50,			# show last <this many> users.
	"news_frontpage_count"=>10,		# concurrent news items on blog-style frontpage
	"page_widget_width"=>15,		# number of pages to allow direct selection of in pager
	"news_list_page"=>30,			# number of items on past news list page
	"message_maxcols"=>65,			# maximum columns to allow in messages before wrapping
	"headline_maxlen"=>768,			# maximum length of a news headline
	"votingbar_pels"=>350,			# pixel width of poll results bar
	"votingbar_chars"=>25,			# character with of text rendering of poll results bars
	"votingbar_char"=>'*',			# bar character for text rendering of poll results
	"topusers_alltime"=>"10",		# all time top users to show on front page
	"topusers_2weeks"=>"10",		# last two weeks top users to show on front page
	"latest_additions"=>"20",		# number of latest addition objects to show on front page
	"latest_revisions"=>"20",		# number of latest revisions to show on front page
	"latest_messages"=>"30",		# number of latest messages to show on front page
	"search_results_page"=>10,		# default number of items per search results page
	"listings_page"=>20,			# default number of items on each paged display page
	"inval_maxdf"=>20,				# max times an invalidation phrase can occur before extension
					  
	# the types displayed in "latest additions"
	#
	"latest_additions_types"=>[THEOREM,DEFINITION,PROOF,ALGORITHM,AXIOM,DSTRUCT,TOPIC,BIOGRAPHY,FEATURE,BIBLIOGRAPHY],

	# words that are "bad" for invalidations.   when these occur at the beginning of
	# a title or other concept label (pluralized or not), they get removed in
	# invalidation preprocessing.
	#
	"bad_inval_words" => {
		'derivation' => 1, 
		'proof' => 1, 
		'example' => 1, 
		'table' => 1, 
		'theorem' => 1,
	},

	# single characters to represent types
	# (arbitrary but unique)
	#
    "typechars"=>{
		1=>'t',     # Theorem
		2=>'c',     # Corollary
		5=>'d',     # Definition
		6=>'r',     # Result
		3=>'p',     # Proof
		17=>'a',    # Algorithm
		19=>'s',    # data Struct
		20=>'x',    # aXiom
		21=>'o',    # tOpic
		22=>'b',    # Bio
		24=>'j',	# conJecture
		25=>'v',	# deriVation
		7=>'e',		# Example
		26=>'n',    # applicatioN
		27=>'f',	# Feature
		28=>'l',	# bibLiography
	},
		
	# human-readable strings for object types defined above
	# 
	"typestrings"=>{
		1=>'Theorem',     # Theorem
		2=>'Corollary',     # Corollary
		5=>'Definition',    # Definition
		6=>'Result',     	# Result
		3=>'Proof',     	# Proof
		17=>'Algorithm',    # Algorithm
		19=>'Data Structure', # data Struct
		20=>'Axiom',    	# aXiom
		21=>'Topic',   		# tOpic
		22=>'Biography',    # Bio
		7=>'Example',		# Example
		25=>'Derivation',	# deriVation
		24=>'Conjecture',	# conJecture
		26=>'Application',	# applicatioN
		27=>'Feature',
		28=>'Bibliography',
	},   
					  
	# score table : how much various actions are worth
	#
	"scores"=>{
		addpaper=>50,       # adding a paper
		addlec=>75,         # adding lecture note
		addbook=>100,       # adding books
		addgloss=>100,      # adding to glossary 
		adden=>100,         # adding to encyc 
		vote=>1,            # voting 
		postmsg=>1,         # posting a message 
		err_accept=>30,     # correction accept : type Errata
		add_accept=>20,     # correction accept : type Addenda
		met_accept=>10,     # correction accept : type Meta/Minor
		edit_en_minor=>5,   # minor editing  
		edit_en_major=>5,	# major editing		 
	},
					  
	# preferences information structure
	# each hash should point to an array which contains
	#   type, description, default value, additional info 
	#
	"prefs_schema"=>{
		pagelength=>['Items per page (for lists)','select','020',
			{'010'=>'10', '020'=>'20', '030'=>'30', '040'=>'40',
			 '050'=>'50', '075'=>'75', '100'=>'100', '150'=>'150'}],
		usesig=>['Use sig in messages','check','off'],
		hideemail=>['Hide email address (NOTE: still shows for you)','check','off'],
		coremail=>['Receive email when you get corrections','check','on'],
		sysemail=>['Receive email when you get system mail','check','on'],
		noticeemail=>['Also send email for each system notice?','check','on'],
		xferoffermail=>['Receive object transfer offer email (for others\' offers)','check','on'],
		xferfinishmail=>['Receive object transfer completion email (for your offers)','check','on'],
		corecloseemail=>['Receive email when corrections you\'ve filed are closed','check','on'],
		msgexpand=>['Default messages to expand','select','1',
			{'0'=>'none', '1'=>'1', '2'=>'2', '3'=>'3', 
			 '4'=>'4', '5'=>'5', '6'=>'6', '7'=>'7', '8'=>'8', 
			 '9'=>'9', '-1'=>'all'}],
		msgstyle=>['Default message style','select','threaded',
			{flat=>'Flat',threaded=>'Threaded'}],
		msgorder=>['Default message order','select','desc',
			{desc=>'Newest first',asc=>'Oldest First'}],
		cmethod=>['Collaboration rendering style','select','png',
			{
			js=>'jsMath HTML',
			l2h=>'HTML with images',
			 png=>'page images',
			 src=>'TeX source'}],
		method=>['Encyclopedia rendering style','select','js',
			{
			js=>'jsMath HTML',
			l2h=>'HTML with images',
			 png=>'page images',
			 src=>'TeX source'}],
		objwatch=>['Automatically watch your objects','check','on'],
		corwatch=>['Automatically watch corrections to your objects','check','on'],
		reqfwatch=>['Automatically watch requests you\'ve filled','check','on'],
		reqfowatch=>['Automatically watch requests others say you\'ve filled','check','on'],
		reqfywatch=>['Automatically watch requests you say others have filled','check','on'],
		editwatch=>['Automatically watch objects you edit','check','on'],
		msgwatch=>['Automatically watch your message threads','check','on'],
		symrelated=>['Attempt to set symmetric "related" links','check','on'],
		acceptrelated=>['Accept "related" link suggestions.','select','on',{on=>'Yes', off=>'No', ask=>'Ask'}],
		replynotify=>['Receive notification for message replies (regardless of watches)','check','on'],
		neverlogout=>['Never automatically log me out','check','off'],
		secret_phrase=>['Secret phrase for automatic email posting verification', 'text'],
		self_email=>['Receive your own messages through email bridge', 'check', 'off']
	},

	# preferences groupings information
	#
	prefs_groupings=>[
		['General Options', ['pagelength','usesig']],
		['Privacy', ['hideemail']],
		['Security', ['neverlogout']],
		['E-mail Notification', ['coremail','corecloseemail', 'xferoffermail', 'xferfinishmail','sysemail','noticeemail']],
		['Messages', ['msgexpand','msgstyle','msgorder','replynotify']],
		['Watches', ['objwatch','corwatch','editwatch','reqfwatch','reqfowatch','reqfywatch','msgwatch']],
		['Appearance', ['method', 'cmethod']],
		['Encyclopedia Integrity', ['symrelated','acceptrelated']],
		['Email Bridge', ['secret_phrase', 'self_email']]
	],

	# help blurbs
	#
	'help'=>{
		'indicator_u'=>"The indicator 'u' means the object is unclassified.",
		'indicator_c'=>"The indicator 'c' means the object has corrections.",
		'indicator_m'=>"The indicator 'm' means the object has unread messages.",
		'typechar_a'=>"'a' means the object is of type <b>algorithm</b>.",
		'typechar_o'=>"'o' means the object is of type <b>topic</b>.",
		'typechar_d'=>"'d' means the object is of type <b>definition</b>.",
		'typechar_t'=>"'t' means the object is of type <b>theorem</b>.",
		'typechar_l'=>"'l' means the object is of type <b>bibliography</b>.",
		'typechar_f'=>"'f' means the object is of type <b>feature</b>.",
		'typechar_p'=>"'p' means the object is of type <b>proof</b>.",
		'typechar_x'=>"'x' means the object is of type <b>axiom</b>.",
		'typechar_b'=>"'b' means the object is of type <b>bio</b>.",
		'typechar_c'=>"'c' means the object is of type <b>corollary</b>.",
		'typechar_r'=>"'r' means the object is of type <b>result</b>.",
		'typechar_s'=>"'s' means the object is of type <b>data structure</b>.",
		'typechar_e'=>"'e' means the object is of type <b>example</b>.",
		'typechar_v'=>"'v' means the object is of type <b>derivation</b>.",
		'typechar_j'=>"'j' means the object is of type <b>conjecture</b>.",
		'typechar_n'=>"'n' means the object is of type <b>application</b>."
	},

	# encyclopedia object quick-edit schema
	#
	'en_schema'=>{
		name=>['Canonical Name', 'text', '', 32],
		title=>['Title','text','',32],
		synonyms=>['Synonyms','text','',64],
		defines=>['Defines','text','',64],
		pronounce=>['Pronunciation','text','',64],
		self=>['Contains own proof','check','off'],
		related=>['Related','text','',64],
		keywords=>['Keywords','text','',64],
		data=>['Data','tbox','',10,80],
		preamble=>['Preamble','tbox','',6,80],
		type=>['Type','select','5',
			{'1'=>'theorem', '2'=>'corollary', '5'=>'definition', 
			 '6'=>'result', '3'=>'proof', '17'=>'algorithm', 
			 '19'=>'data structure', '20'=>'axiom', '21'=>'topic', 
			 '22'=>'bio', '25'=>'derivation', '24'=>'conjecture', 
			 '7'=>'example', '28'=>'bibliography'}]
	},

	# generic metadata editor schema
	#
	'generic_schema'=>{
		'books' => {
			title => ['Title','text','',32],
			data => ['Synopsis','tbox','',10,80],
			keywords => ['Keywords','text','',64],
			authors => ['Authors','text','',64],
			comments => ['Comments','text','',64],
			isbn => ['ISBN #','text','',64],
			rights => ['Rights','tbox','',6,80],
			urls => ['URLs (one per line)','tbox','',6,80]
		},

		'papers' => {
			title => ['Title','text','',32],
			data => ['Abstract','tbox','',10,80],
			keywords => ['Keywords','text','',64],
			authors => ['Authors','text','',64],
			rights => ['Rights','tbox','',6,80],
			comments=> ['Comments','text','',64]
		},
	
		'lec' => {
			title => ['Title','text','',32],
			data => ['Synopsis','tbox','',10,80],
			keywords => ['Keywords','text','',64],
			authors => ['Authors','text','',64],
			comments => ['Comments','text','',64],
			rights => ['Rights','tbox','',6,80],
			urls => ['URLs (one per line)','tbox','',6,80]
 		}
	},
                      
	# flat list of method strings
	"methods" => ["js","l2h","png","src"],
	#"methods" => ["l2h","png","src"],
					  
	# this hash contains commands and additional LaTeX
	# packages needed to support each command
	#
	"latex_packages" => {#psfrag=>'psfrag', 
		#includegraphics=>'graphicx', 
		#theorem=>'amsthm', 
		htmladdnormallink => 'html', 
		#xymatrix=>'xypic' 
	},
					  
	# correction types, for correction filing form
	# 
	"correction_types"=>{
		Erratum =>'err', 
		Addendum => 'add', 
		'Meta/Minor' => 'met'},

	# access levels for various tasks
	# 
	"access_admin"=>100, 
	"access_seehiddenemail"=>100,
	"access_postnews"=>200,
	"access_editobj"=>100,
					  
	# various system commands and command options
	# 
	"spellcmd" => $Noosphere::baseconf::base_config{spellcmd}, 
	"wgetcmd" => $Noosphere::baseconf::base_config{wgetcmd}, 
	"latexcmd" => $Noosphere::baseconf::base_config{latexcmd},
	"latex2htmlcmd" => $Noosphere::baseconf::base_config{latex2htmlcmd},
	"tidycmd" => $Noosphere::baseconf::base_config{tidycmd},
	"vimcmd" => $Noosphere::baseconf::base_config{vimcmd},
	"sendmailcmd" => $Noosphere::baseconf::base_config{sendmailcmd},
	"diffcmd" => $Noosphere::baseconf::base_config{diffcmd},
	"dvipscmd" => $Noosphere::baseconf::base_config{dvipscmd},
	"timeoutprog"=> $Noosphere::baseconf::base_config{timeoutcmd},

	#BB: added latin1 BEFORE unicode
	#    to cirumvent the bug in latex2html
	#    when unicode.pl loads latin1
	#    which in turn in sub do_require_extension (in latex2html)
	#    resets $NO_UTF and $USE_UTF flag
	#"l2h_opts" => "-antialias -html_version 4.0,latin1,unicode",
	"l2h_opts" => "",
					  
	# message stuff
	"msgstylesel" => {flat=>'Flat',threaded=>'Threaded'},
	"msgordersel" => {desc=>'Newest first',asc=>'Oldest First'},
	"msgexpandsel" => {'0'=>'none', '1'=>'1', '2'=>'2', '3'=>'3', '4'=>'4', 
		'5'=>'5', '6'=>'6', '7'=>'7', '8'=>'8', '9'=>'9', '-1'=>'all'},

	# xref linking blacklist
	"dontlink"=>['zero','and','or','i','e','means','set','sets','choose','definition'],

	# default classification scheme/namespace 
	"default_scheme"=>'msc',

	# pronunciation encoding (default) 
	"default_pronunciation"=>'jargon',

	# index weights of index fields
	#
	indexweights => {

		# common stuff
		'title' => 10,
		'defines' => 5,
		'synonyms' => 3,
		'keywords' => 2,
		'related' => 1,
		'body' => 1,

		# user-specific stuff
		'forename' => '5',
		'surname' => '6',
		
		# generic-specific (ha) stuff
		'authors' => 5,
	},

	# indexable mappings, of database tables to index fields
	#
	indexablefields=>{ 
		objects=>{ 
			'title'=>'title',
			'defines'=>'defines',
			'synonyms'=>'synonyms',
			'keywords'=>'keywords',
			'related'=>'related',
			'data'=>'body',
		},
		users=>{ 
			'username'=>'title',
			'forename'=>'forename',
			'surname'=>'surname',
			'bio'=>'body',
		}, 
		papers=>{ 
			'title'=>'title',
			'authors'=>'authors',
			'keywords'=>'keywords',
			'data'=>'body',
		},
		books=>{ 
			'title'=>'title',
			'authors'=>'authors',
			'keywords'=>'keywords',
			'data'=>'body',
		}, 
		lec=>{ 
			'title'=>'title',
			'authors'=>'authors',
			'keywords'=>'keywords',
			'data'=>'body',
		}, 
		collab=>{
			'title'=>'title',
			'abstract'=>'body',
		},
		messages=>{
			'subject'=>'title',
			'body'=>'body',
		},
	}, 
	
	# correction event/interval time settings
	# these are phrase in such a way that makes them compatible with both
	# mysql and postgresql (kind of).  Mysql has no "week" unit.
	#
	"cor_times"=>{
		nagstart=>'14 DAY',		# 2 weeks
		adopt=>'42 DAY',		# 6 weeks 
		orphan=>'56 DAY',		# 8 weeks
		naginterval=>'7 DAY', 	# 1 week
	} ,

	# tags we allow users to use in HTML-enabled text.  also, allowed attribs
	# specified as sub-hashes
	# 
	'allowed_html_tags' => {'cite' => undef, 
		'strong' => undef, 
		'dt' => undef, 
		'tt' => undef,
		'a' => {'href'=>1, 'name'=>1},
		'b' => undef,
		'li' => {'value'=>1, 'type'=>1},
		'strike' => undef,
		'i' => undef,
		'sub' => undef,
		'ol' => {'start'=>1, 'type'=>1},
		'dd' => undef,
		'code' => undef,
		'p' =>undef,
		'blockquote' => {'type'=>1},
		'dl' => undef,
		'br' => undef,
		'sup' => undef,
		'ul' => {'type'=>1}, 
		'em' => undef
	},

	"optionaltags" =>$Noosphere::baseconf::base_config{'optionaltags'},

);

# get a value from the config hash.
# 
sub getConfig {
  my $key = shift;
 
  my %config = CONFIG;
 
  return $config{$key}; 
}

sub getAddr {
 my $site = shift;
 
 my $addrhash = getConfig("siteaddrs");
 
 return $addrhash->{$site};
}

sub getScore {
 my $action = shift;
 
 my %config = CONFIG;
 
 return $config{scores}->{$action};
}

sub getMethods {
 my %config = CONFIG;
 
 return @{ $config{methods} };
}

sub getHelpText {
 my $key = shift;

 my $help = getConfig('help');
 
 return $help->{$key};
}

sub tabledesc {
  my $table = shift;

  # read in the descriptions from the database
  #
  if (not defined %tdesc) {
    my ($rv,$sth) = dbSelect($dbh,{WHAT=>"*",FROM=>'tdesc'}); 
	my @rows = dbGetRows($sth);
	foreach my $row (@rows) {
	  $tdesc{$row->{tname}} = $row->{description};
	}
  }

  return $tdesc{$table};
}

# get a table name from a table id
#
sub tablename {
  my $id = shift;

  # read in the descriptions from the database
  #
  if (not defined %tname) {
    my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>'tdesc'}); 
	my @rows = dbGetRows($sth);
	foreach my $row (@rows) {
	  $tname{$row->{uid}} = $row->{tname};
	}
  }

  return $tname{$id};
}

# get a table id by table name
#
sub tableid {
  my $name = shift;

  # cache the lookup table
  #
  if (not defined %table_id) {
    my ($rv,$sth) = dbSelect($dbh,{WHAT=>'*',FROM=>'tdesc'}); 
	my @rows = dbGetRows($sth);
	foreach my $row (@rows) {
	  $table_id{$row->{'tname'}} = $row->{'uid'};
	}
  }

  return $table_id{$name};
}

1;
