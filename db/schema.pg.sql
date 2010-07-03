/******************************************************************************
* 
*                            SECTION 1 : SCHEMA 
*
******************************************************************************/


/******************************************************************************
 blacklist - list of masks to check application email addresses against. if
  an address is in this list, the application will be rejected.
*******************************************************************************/
create sequence blacklist_uid_seq;
 
create table blacklist(
 uid bigint not null default nextval('blacklist_uid_seq'), 
 mask varchar(128) not null
);
--create index blacklist_uid_idx on blacklist using hash(uid);
create index blacklist_uid_idx on blacklist(uid);

/******************************************************************************
 persistent storage table (currently used for caching statistics)
*******************************************************************************/
create table storage (
	_key varchar(64) not null,  /* the key which is used to recall the record */
	_val text,                /* the value (could be a frozen perl structure) */
	valid int default 1,           /* whether or not the value is still valid */
	lastupdate varchar(32),        /* time stamp of last update (seconds UTC) */
	timeout varchar(32),             /* timeout before data expires (seconds) */
	callback varchar(32)  /* name of perl function used to generate the value */
);

--create index storage__key_idx on storage using hash(_key); 
create index storage__key_idx on storage (_key); 

/******************************************************************************
 rendered images table - holds a hash of rendered math images
*******************************************************************************/
create sequence rendered_images_uid_seq;

create table rendered_images (
 uid bigint primary key default nextval('rendered_images_uid_seq'),
 imagekey varchar(128), 
 variant varchar(16),  /* variant ('normal', 'title', 'highlight') ... */
 align varchar(10),
 image bytea,          /* binary image data */
 unique key(imagekey, variant)
);

--create index rendered_images_imagekey_idx on rendered_images using hash (imagekey);
create index rendered_images_imagekey_idx on rendered_images (imagekey);

/******************************************************************************
 authors table -- holds author list information for planetmath objects
*******************************************************************************/
create table authors (
 tbl varchar(16) not null,   /* pointer to object */
 objectid bigint not null,   
 userid bigint not null,     /* which user */
 ts timestamp                /* time of last modification to object */
);
--create index authors_userid_idx on authors using hash(userid);
create index authors_userid_idx on authors (userid);
--create index authors_ts_idx on authors using hash(ts);
create index authors_ts_idx on authors (ts);

/******************************************************************************
 acl_default table - holds default ACL spec for object creation per user. 
*******************************************************************************/
create sequence acl_default_seq;
create table acl_default (
 uid bigint default nextval('acl_default_seq') primary key, 
 userid bigint not null,
 subjectid bigint not null, 
 read integer default 1, 
 write integer default 0, 
 acl integer default 0, 
 user_or_group character(1) default 'u', 
 default_or_normal character(1) default 'n'
);

/******************************************************************************
 groups table
*******************************************************************************/
create sequence groups_groupid_seq;

create table groups (
 groupid bigint PRIMARY KEY default nextval('groups_groupid_seq'), 
 userid bigint not null,       /* group creator/admin id */
 groupname varchar(128),       /* name of the group */
 description text              /* optional description */
);
--create index groups_groupname_idx on groups using hash(groupname);
create index groups_groupname_idx on groups (groupname);

/******************************************************************************
 group membership table - associates users with groups
*******************************************************************************/
create table group_members (
 groupid bigint not null,    /* the group id */
 userid bigint not null       /* user which is in this group */
);
--create index group_members_groupid_idx on group_members using hash(groupid);
create index group_members_groupid_idx on group_members (groupid);
--create index group_members_userid_idx on group_members using hash(userid);
create index group_members_userid_idx on group_members (userid);

/******************************************************************************
 ACL (access control list) table
*******************************************************************************/
create sequence acl_uid_seq;

create table acl (

 uid bigint PRIMARY KEY default nextval('acl_uid_seq'),

  /* object pointer -- this is the object the ACL applies to */

 tbl varchar(16) not null,     /* object's table */
 objectid bigint not null,     /* object's id */

  /* subject pointer -- this is who the ACL applies to */
 subjectid bigint not null,

  /* ACL specification */

 read int default 1,           /* readable ? 1=yes 0=no */
 write int default 0,          /* writeable?  " " */
 acl int default 0,            /* can change ACL? " " */

  /* ACL properties */

 user_or_group character(1) default 'u',       /* applies to user or group ? */
 default_or_normal character(1) default 'n'    /* default policy or not ? */
);
--create index acl_objectid_idx on acl using hash(objectid);
create index acl_objectid_idx on acl (objectid);

/******************************************************************************
 main object index (title index)
*******************************************************************************/
create table objindex (
 objectid bigint not null,
 tbl varchar(16) not null,
 userid bigint not null,
 title varchar(128) not null,
 cname varchar(128) not null,
 type int not null default 1,
 source varchar(16),
 ichar character(1) 
);
--create index objindex_objectid_idx on objindex using hash(objectid);
create index objindex_objectid_idx on objindex (objectid);
create index objindex_lowertitle_idx on objindex(lower(title));
--create index objindex_cname_idx on objindex using hash(cname);
create index objindex_cname_idx on objindex (cname);

/******************************************************************************
 watches
*******************************************************************************/
create sequence watches_uid_seq;

create table watches (uid bigint primary key default nextval('watches_uid_seq') , objectid bigint not null, tbl varchar(16) not null, userid bigint not null);

--create index watches_objectid_idx on watches using hash(objectid);
create index watches_objectid_idx on watches (objectid);

/******************************************************************************
 searchresults - a "cache" table for search results, accessede by a unique
  token
*******************************************************************************/
create table searchresults (
 objectid bigint not null,
 tbl varchar(16) not null,
 ts timestamp default CURRENT_TIMESTAMP,
 rank float not null,
 token int not null
);
create index searchresults_rank_idx on searchresults(rank);
--create index searchresults_token_idx on searchresults using hash(token);
create index searchresults_token_idx on searchresults (token);
	 
/******************************************************************************
 relsuggest - keep track of "related" suggestions.  this is so that when 
 a "related" link is suggested on a particular object once, it will never 
 be suggested again.
*******************************************************************************/
create table relsuggest (
 objectid bigint not null, 
 tbl varchar(16) not null,  
 related varchar(255) not null
);

--create index relsuggest_objectid_idx on relsuggest using hash(objectid);
create index relsuggest_objectid_idx on relsuggest (objectid);
--create index relsuggest_related_idx on relsuggest using hash(related);
create index relsuggest_related_idx on relsuggest (related);

/******************************************************************************
 requests - requests for planetmath additions 
*******************************************************************************/
create sequence requests_uid_seq;
create table requests (
 uid int8 default nextval('requests_uid_seq'),
 creatorid int8 not null,
 fulfillerid int8,
 title varchar(128) not null,
 data text default '',
 created timestamp,
 closed timestamp,
 fulfilled timestamp
);
create index requests_uid_idx on requests(uid);

/******************************************************************************
 catlinks - association links between categories
*******************************************************************************/
create table catlinks(
 a int8,                /* (scheme) unique category number */
 b int8,                /* (scheme) unique category number */
 nsa int,               /* namespace id from ns */
 nsb int                /* namespace id from ns */
);

--create index catlinks_a_idx on catlinks using hash(a);
create index catlinks_a_idx on catlinks (a);
--create index catlinks_b_idx on catlinks using hash(b);
create index catlinks_b_idx on catlinks (b);

/******************************************************************************
 ns - classification namespace info 
*******************************************************************************/
create sequence ns_id_seq;
create table ns (
 name varchar(16) not null,
 shortdesc varchar(64) not null,
 longdesc varchar(255) not null,
 link varchar(255),
 id int default nextval('ns_id_seq')
);

/******************************************************************************
 classification - this table joins objects with a subject classification
*******************************************************************************/
create table classification (
  tbl varchar(32) not null,                          /* pointer to the object */
  objectid int8 not null,
  ns varchar(16) not null,                               /* name of namespace */
  catid int8 not null,                                         /* category id */
  ord integer default 0,  /* ordinal value of category for object (for lists) */
  nsid integer                /* namespace id of the above namespace (cached) */
);

--create index classification_objectid_idx on classification using hash(objectid);
create index classification_objectid_idx on classification (objectid);
--create index classification_catid_idx on classification using hash(catid);
create index classification_catid_idx on classification (catid);
create index classification_tbl_idx on classification(tbl);

/******************************************************************************
 lastmsg - keeps track of the last message a user saw in a discussion 
           under a particular object.  used to determine new posts.
*******************************************************************************/
create table lastmsg (
  tbl varchar(32) not null,
  objid int8 not null,
  userid int8 not null,
  lastmsg int8 not null
);
--create index lastmsg_userid_idx on lastmsg using hash(userid);
create index lastmsg_userid_idx on lastmsg (userid);
--create index lastmsg_tbl_idx on lastmsg using hash(tbl);
create index lastmsg_tbl_idx on lastmsg (tbl);
create index lastmsg_objid_idx on lastmsg(objid);

/******************************************************************************
 tdesc - human readable table description lookup 
*******************************************************************************/
create table tdesc(
 tname varchar(32) not null primary key, 
 description varchar(128) not null,
 uid integer
);

/******************************************************************************
 objlinks (generic links between planetmath objects) 
*******************************************************************************/
create sequence objlinks_objlink_seq;
create table objlinks (
 uid int8 default nextval('objlinks_objlink_seq'),
 srctbl varchar(32) not null,
 desttbl varchar(32) not null,
 srcid varchar(32) not null,
 destid varchar(32) not null,
 note varchar(128)
);
--create index objlinks_srcid_idx on objlinks using hash(srcid);
create index objlinks_srcid_idx on objlinks (srcid);
--create index objlinks_destid_idx on objlinks using hash(destid);
create index objlinks_destid_idx on objlinks (destid);

/******************************************************************************
 notices (system messages to user)
*******************************************************************************/
create sequence notices_notice_seq;
create table notices (
 uid int8 default nextval('notices_notice_seq'), 
 userid int8 not null, 
 userfrom int8,
 title varchar(128), 
 created timestamp default CURRENT_TIMESTAMP, 
 viewed int default 0, 
 data text,
 choice_default int, /* for a prompt: index of default choice, or -1 for none */
                     /* this activates upon deletion */
 choice_title text,  /* for a prompt: ;-sep list of choice titles */
 choice_action text  /* for a prompt: ;-sep list of URLs */
);
--create index notices_userid_idx on notices using hash(userid);
create index notices_userid_idx on notices (userid);

/******************************************************************************
 links (xref links between objects recorded here)
*******************************************************************************/

create table links (
 fromid int8 not null,                                  /* originating object */
 fromtbl varchar(16) not null,                           /* originating table */
 toid int8 not null,                                    /* destination object */
 totbl varchar(16) not null                              /* destination table */
);

 /* 
    make indices on both because the usage of this table will be 

    1. when a title is changed on object a, find the set B of all objects that 
	   link to a (fromid=anything, toid=a) 
	2. update this table, deleting all links originating from anything in B
	   (fromid = b, B \in B)

	Therefore, we need fast lookups on both from and to id.
 */
--create index links_fromid_idx on links using hash(fromid);
create index links_fromid_idx on links (fromid);
--create index links_toid_idx on links using hash(toid);
create index links_toid_idx on links (toid);

/******************************************************************************
 hits (object accesses)
*******************************************************************************/

create sequence hits_uid_seq;

create table hits (
 uid int8 default nextval('hits_uid_seq'),                   /* unique hit id */
 objectid int8 not null,                             /* id of object accessed */
 tbl varchar(32) not null,                              /* table object is in */
 at timestamp not null default CURRENT_TIMESTAMP, /* time object was accessed */
 /*primary key(uid)                                       */
);

/* this may be a dumb idea */
--create index hits_objectid_idx on hits using hash(objectid);

/******************************************************************************
 mail (private mail) 
*******************************************************************************/

create sequence mail_uid_seq;

create table mail (
 uid int8 default nextval('mail_uid_seq'),           /* unique id of message */
 userto int8 not null,                                 /* user id to send to */
 userfrom int8 not null,                             /* user id of user from */
 subject varchar(128) not null,                    /* subject of the message */ 
 body text not null,                                     /* body of the mail */
 sent timestamp default CURRENT_TIMESTAMP,                      /* time sent */ 
 read int,                             /* 0 or null for not read, 1 for read */
 primary key(uid)
);

--create index mail_userto_idx on mail using hash(userto);
create index mail_userto_idx on mail (userto);
--create index mail_userfrom_idx on mail using hash(userfrom);
create index mail_userfrom_idx on mail (userfrom);

/******************************************************************************
 corrections (to objects)
*******************************************************************************/

create sequence corrections_uid_seq;

create table corrections (
 uid int8 default nextval('corrections_uid_seq'),                /* unique id */
 objectid int8 not null,                       /* object correction points to */
 userid int8 not null,                          /* userid of correction filer */
 type varchar(3) not null,                    /* type string ('err' or 'add') */
 title varchar(128),                                      /* correction title */
 data text not null,                                       /* correction text */
 comment text,                                 /* acception/rejection comment */
 filed timestamp default CURRENT_TIMESTAMP,                     /* date filed */
 closed timestamp,                   /* date closed, otherwise null = pending */
 closedbyid int8 not null,                     /* userid of the user who closed the correction */
 graceint interval default interval '0 days' , /* a "Grace period" which should
                                   be added to the correction filing date when
								   computing outstanding correction status. 
								   this should be set to the time elapsed from
								   filing date at the time the object changes
								   hands */
 accepted int,              /* 1 for accepted, 0 for rejected, 2 for retracted,
 							   otherwise null */
 PRIMARY KEY (uid)
);

--create index corrections_uid_hidx on corrections using hash(uid);
--create index corrections_objectid_idx on corrections using hash(objectid);
create index corrections_objectid_idx on corrections (objectid);
--create index corrections_userid_idx on corrections using hash(userid);
create index corrections_userid_idx on corrections (userid);

/******************************************************************************
 msc (mathematics subject classification) table                       
*******************************************************************************/

create table msc (
 id varchar(6) not null unique,                              /* msc id string */
 uid int8 not null,
 parent varchar(6),      /* parent msc class, if any (only -XX dont have one) */
 comment varchar(128),                              /* human-readable comment */
 primary key(id)    
);

--create index msc_id_idx on msc using hash(id);
--create index msc_uid_idx on msc using hash(uid);
create index msc_uid_idx on msc (uid);
--create index msc_parent_idx on msc using hash(parent);
create index msc_parent_idx on msc (parent);

/******************************************************************************
 user table
*******************************************************************************/
CREATE SEQUENCE users_uid_seq;

CREATE TABLE users (
 uid int8 DEFAULT nextval('users_uid_seq'),                /*unique id of user*/
 username varchar(32) NOT NULL UNIQUE,                /*username in PM, unique*/
 password varchar(32) NOT NULL,                             /*password of user*/
 email varchar(128) NOT NULL,                     /*email address, is verified*/
 joined timestamp DEFAULT CURRENT_TIMESTAMP,                /*date user joined*/
 /*add optional fields here as desired*/
 forename varchar(64) default '',                         /*given name of user*/
 surname varchar(64) default '',                         /*family name of user*/
 city varchar(128) default '',                            /*city user lives in*/
 state varchar(128) default '',                          /*state user lives in*/
 country varchar(128) default '',                      /*country user lives in*/
 score int DEFAULT 0,                                            /*users score*/
 homepage varchar(255) default '',	                         /*url to homepage*/
 access int DEFAULT 10,                                         /*access level*/
 sig text default '',                                              /*signature*/
 prefs text default '',                                   /*preferences string*/
 last timestamp,                                                 /*last access*/
 bio text default '',                                             /* bio text */
 preamble text default '',                               /* TeX preamble text */
 active int default 1,                         /* is user allowed to log in ? */
 lastip varchar(15),
 PRIMARY KEY(uid)
);

--create index users_uid_idx on users using hash(uid);
--create index users_username_idx on users using hash(username);
create index users_username_idx on users (username);
create index users_lowerusername_idx on users (lower(username));

/******************************************************************************
 news table
*******************************************************************************/

CREATE SEQUENCE news_uid_seq;

create table news( 
 uid int8 default nextval('news_uid_seq'),
 userid int8 not null,
 created timestamp default CURRENT_TIMESTAMP,
 modified timestamp default CURRENT_TIMESTAMP,
 title varchar(128) not null,
 intro text default '',
 body text default '',
 hits int8 default 0,
 primary key(uid)
);

create index news_created_idx on news(created);

/******************************************************************************
 forum table
*******************************************************************************/

create sequence forums_uid_seq;

create table forums (
 uid int8 default nextval('forums_uid_seq'),
 userid int8 not null,
 created timestamp default CURRENT_TIMESTAMP,
 modified timestamp default CURRENT_TIMESTAMP,
 parentid int8,
 title varchar(128) not null,
 data text not null,
 primary key(uid)
);

/******************************************************************************
 papers table 
*******************************************************************************/

create sequence papers_uid_seq;

create table papers (
 uid int8 default nextval('papers_uid_seq'),
 userid int8 not null,
 created timestamp default CURRENT_TIMESTAMP,
 modified timestamp default CURRENT_TIMESTAMP,
 title varchar(255) not null,
 data text not null,
 keywords varchar(128) default '',
 authors varchar(255),
 comments varchar(128),
 hits int8 default 0,
 msc varchar(16),
 rights varchar(255) default '',
 primary key(uid)
);

--create index papers_uid_idx on papers using hash(uid);
--create index papers_userid_idx on papers using hash(userid);
create index papers_userid_idx on papers (userid);

/******************************************************************************
 books table 
*******************************************************************************/

create sequence books_uid_seq;

create table books(
 uid int8 default nextval('books_uid_seq'),                     
 userid int8 not null,                                 /* user id of uploader */
 created timestamp default CURRENT_TIMESTAMP,
 modified timestamp default CURRENT_TIMESTAMP,
 title varchar(255) not null,                            /* title of the work */
 data text not null,                                  /* description/abstract */
 urls text,                                                  /* urls of files */
 keywords varchar(128) default '',            /* keywords to describe content */
 authors varchar(255),                                 /* authors of the book */
 comments varchar(128),                     /* comments (pages, edition, etc) */
 hits int8 default 0,                                                 /* hits */
 msc varchar(16),                              /* math subject classification */
 loc varchar(32),                                   /* library of congress id */
 primary key(uid)
);

--create index books_uid_idx on books using hash(uid);
--create index books_userid_idx on books using hash(userid);
create index books_userid_idx on books (userid);

/******************************************************************************
 lecture notes table 
*******************************************************************************/

create sequence lec_uid_seq;

create table lec (
 uid int8 default nextval('lec_uid_seq'),                     
 userid int8 not null,                                 /* user id of uploader */
 created timestamp default CURRENT_TIMESTAMP,
 modified timestamp default CURRENT_TIMESTAMP,
 title varchar(255) not null,                            /* title of the work */
 data text not null,                                  /* description/abstract */
 urls text,                                                  /* urls of files */
 keywords varchar(128) default '',            /* keywords to describe content */
 authors varchar(255),                                /* authors of the notes */
 comments varchar(128),                     /* comments (pages, edition, etc) */
 hits int8 default 0,                                                 /* hits */
 msc varchar(16),                              /* math subject classification */
 rights varchar(255) default '',
 primary key(uid)
);

--create index lec_uid_idx on lec using hash(uid);
--create index lec_userid_idx on lec using hash(userid);
create index lec_userid_idx on lec (userid);

/******************************************************************************
 main (math) objects table
*******************************************************************************/

CREATE SEQUENCE objects_uid_seq;

CREATE TABLE objects (
 uid int8 DEFAULT nextval('objects_uid_seq'),            /*unique id of object*/
 type int NOT NULL,                                           /*type of object*/
 userid int8 NOT NULL,                        /*unique id of creator of object*/
 created timestamp DEFAULT CURRENT_TIMESTAMP,        /*date object was created*/
 modified timestamp DEFAULT CURRENT_TIMESTAMP,       /*date object was created*/
 parentid int8,                     /*unique id of object this object is under*/
 title varchar(255) NOT NULL,                                /*title of object*/
 data text NOT NULL,                                       /*content of object*/
 preamble text default '',                                     /*preamble data*/
 name varchar(255) NOT NULL,                   /* canonical name of the object*/
 related text DEFAULT '',           
 synonyms text DEFAULT '',             
 defines text DEFAULT '',  
 keywords text DEFAULT '',
 hits int8 default 0,
 self int default 0,                           /* object contains own proof? */
 version int default 1,
 pronounce varchar(255) default '',
 PRIMARY KEY(uid)
);

--create index objects_name_idx on objects using hash(name);
create index objects_name_idx on objects (name);
create index objects_lowertitle_idx on objects (lower(title));
--create index objects_uid_idx on objects using hash(uid);
--create index objects_userid_idx on objects using hash(userid);
create index objects_userid_idx on objects (userid);

/******************************************************************************
 cache table - holds information about caching of encyclopedia objects
*******************************************************************************/
create table cache (
 objectid int8 not null,                  /* object id caching info refers to */
 tbl varchar(16) not null,                              /* table object is in */
 valid int default 0,                /* 1 if the object is valid, 0 otherwise */
 build int default 0,             /* 1 if the object is building, 0 otherwise */
 rrequests int defualt 0,                /* number of pending render requests */
 method varchar(3),                   /* rendering method this info refers to */
 touched timestamp default CURRENT_TIMESTAMP,
 bad int default 0			/* bad entry flag, for skipping */
);

CREATE INDEX cache_objectid_idx on cache (objectid);
CREATE UNIQUE INDEX cache_id_idx on cache (objectid, tbl, method);

/******************************************************************************
 score table - holds information about change in scores 
*******************************************************************************/

create sequence score_uid_seq;

create table score (
  uid int8 default nextval('score_uid_seq'),     /* unique id of score change */
  userid int8 not null,                                      /* the user's id */
  delta int not null default 0,                     /* change in user's score */
  occured timestamp default CURRENT_TIMESTAMP       /* when the score changed */
);

create index score_occured_idx on score(occured);
--create index score_userid_idx on score using hash(userid); 
create index score_userid_idx on score (userid); 

/******************************************************************************
 messages
*******************************************************************************/

create sequence messages_message_seq;

create table messages (
 uid int8 DEFAULT nextval('messages_message_seq'),               /* unique id */
 threadid bigint,                        /* thread id (= uid for non-replies) */
 visible tinyint default 1,				 /* is the message visible in public? */
 tbl varchar(16) not null,                          /* table the object is in */
 objectid int8 NOT NULL,               /* id of object message is attached to */
 replyto int8 default -1,                 /* id of message this is a reply to */
 created timestamp DEFAULT CURRENT_TIMESTAMP,         /* timestamp of created */
 userid int8 NOT NULL,                               /* id of user who posted */
 subject varchar(128) DEFAULT 'none',                      /* message subject */
 body text DEFAULT ''                                              /* message */
);

--create index messages_uid_idx on messages using hash(uid);
--create index messages_userid_hidx on messages using hash(userid);
create index messages_userid_hidx on messages (userid);
--create index messages_objectid_hidx on messages using hash(objectid);
create index messages_objectid_hidx on messages (objectid);

/******************************************************************************
 actions (gives persistance to things a user does: for now, just voting)
*******************************************************************************/

CREATE SEQUENCE actions_uid_seq;

CREATE TABLE actions (
 uid int8 DEFAULT nextval('actions_uid_seq'),            /*unique id of action*/
 userid int8,                               /*user id of user action refers to*/
 type int NOT NULL,                                          /*type of action */
 objectid int8,                  /*unique id of object action was performed on*/
 data text,                               /*any data that went with the action*/
 created timestamp DEFAULT CURRENT_TIMESTAMP,            /*date action occured*/
 score int NOT NULL DEFAULT 0,                /*change in score to user (or 0)*/
 PRIMARY KEY(uid)
);

create index actions_objectid_idx on actions (objectid);
--create index actions_userid_idx on actions using hash(userid);
create index actions_userid_idx on actions (userid);

/******************************************************************************
 polls
*******************************************************************************/

create sequence polls_uid_seq;

create table polls ( 
 uid int8 default nextval('polls_uid_seq'),                            /* uid */
 userid int8 NOT NULL,                                  /* id of poll creator */
 start timestamp default CURRENT_TIMESTAMP,          /* starting date of poll */
 finish timestamp default CURRENT_TIMESTAMP+'7 days', /* closing date of poll */
 options varchar(255) NOT NULL,            /* comma separated list of options */
 title varchar(128) NOT NULL,                                /* title of poll */
 PRIMARY KEY(uid)
);

/******************************************************************************
 collaborations
*******************************************************************************/

create sequence collab_uid_seq;

CREATE TABLE collab (
  uid int8 default nextval('collab_uid_seq'),
  userid int8 NOT NULL default 0,
  title varchar(255) NOT NULL default '',
  abstract text,
  data text,
  _lock int8 default 0,
  created datetime default NULL,
  locktime datetime default NULL,
  lockuser int8 default NULL,
  published tinyint default 0,
  modified datetime default NULL,
  version int8 default 1,
  hits int8 default 0,
  sitedoc tinyint default 0,
  PRIMARY KEY  (uid),
  KEY userid (userid),
  KEY collab_userid_idx (userid)
);

/******************************************************************************
 Table structure for table 'ownerlog'
******************************************************************************/

CREATE TABLE ownerlog (
  objectid int8 NOT NULL,
  tbl varchar(16) NOT NULL,
  userid int8 NOT NULL,
  action char(1),
  ts timestamp,
  key ownerlog_objectid_idx (objectid),
  key ownerlog_userid_idx (userid)
);

-- invalidation document frequency table

create table inv_dfs (
	id int NOT NULL,
	word_or_phrase tinyint default 0,
	count tinyint default 0,
	key(id)
);

-- invalidation index

create table inv_idx (

	id int NOT NULL,
	word_or_phrase tinyint default 0,
	objectid int NOT NULL,
	key(id),
	key(objectid)
);

-- invalidation words dictionary

create sequence inv_words_seq;

create table inv_words (
	id mediumint unsigned NOT NULL PRIMARY KEY default nextval('inv_words_seq'),
	word char(32) NOT NULL UNIQUE INDEX
);

-- invalidation phrases dictionary (word tuples)

create sequence inv_phrases_seq;

create table inv_phrases (

	phrase char(255) NOT NULL,
	id mediumint unsigned NOT NULL PRIMARY KEY default nextval('inv_phrases_seq'),
	key(phrase)
);

/******************************************************************************
* 
*                            SECTION 1 : INITIALIZATION 
*
******************************************************************************/

INSERT INTO tdesc VALUES ('lec','Expositions',0);
INSERT INTO tdesc VALUES ('papers','Papers',1);
INSERT INTO tdesc VALUES ('books','Books',2);
INSERT INTO tdesc VALUES ('objects','Encyclopedia',3);
INSERT INTO tdesc VALUES ('messages','Messages',4);
INSERT INTO tdesc VALUES ('corrections','corrections',5);
INSERT INTO tdesc VALUES ('forums','Forums',6);
INSERT INTO tdesc VALUES ('users','Users',7);
INSERT INTO tdesc VALUES ('requests','Requests',8);
INSERT INTO tdesc VALUES ('polls','Polls',9);
INSERT INTO tdesc VALUES ('collab','Collaborations',10);

INSERT INTO users (uid, username) VALUES (0, 'nobody');
