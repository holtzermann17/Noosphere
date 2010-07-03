-- MySQL dump 8.22
--
-- Host: localhost    Database: pm
---------------------------------------------------------
-- Server version	3.23.50-log

--
-- Table structure for table 'acl'
--

CREATE TABLE acl (
  uid int(11) NOT NULL default '0',
  tbl varchar(16) NOT NULL default '',
  objectid int(11) NOT NULL default '0',
  subjectid int(11) NOT NULL default '0',
  _read int(11) default '1',
  _write int(11) default '0',
  _acl int(11) default '0',
  user_or_group char(1) default 'u',
  default_or_normal char(1) default 'n',
  PRIMARY KEY  (uid),
  KEY acl_objectid_idx (objectid)
) TYPE=MyISAM;

--
-- Table structure for table 'acl_default'
--

CREATE TABLE acl_default (
  uid int(11) NOT NULL AUTO_INCREMENT,
  userid int(11) NOT NULL default '0',
  subjectid int(11) NOT NULL default '0',
  _read tinyint(4) NOT NULL default '1',
  _write tinyint(4) NOT NULL default '0',
  _acl tinyint(4) NOT NULL default '0',
  user_or_group char(1) NOT NULL default 'u',
  default_or_normal char(1) NOT NULL default 'n',
  PRIMARY KEY  (uid),
  KEY acl_default_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'acl_default_uid_seq'
--

CREATE TABLE acl_default_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'acl_uid_seq'
--

CREATE TABLE acl_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'actions'
--

CREATE TABLE actions (
  uid int(11) NOT NULL default '0',
  userid int(11) default NULL,
  type int(11) NOT NULL default '0',
  objectid int(11) default NULL,
  data text,
  created timestamp(14) NOT NULL,
  score int(11) NOT NULL default '0',
  PRIMARY KEY  (uid),
  KEY actions_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'actions_uid_seq'
--

CREATE TABLE actions_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'authors'
--

CREATE TABLE authors (
  tbl varchar(16) NOT NULL default '',
  objectid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  ts datetime default NULL,
  KEY authors_userid_idx (userid),
  KEY authors_ts_idx (ts)
) TYPE=MyISAM;

--
-- Table structure for table 'blacklist'
--

CREATE TABLE blacklist (
  uid int(11) NOT NULL default '0',
  mask varchar(128) NOT NULL default '',
  PRIMARY KEY  (uid),
  KEY blacklist_uid_idx (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'blacklist_uid_seq'
--

CREATE TABLE blacklist_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'books'
--

CREATE TABLE books (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  created datetime default NULL,
  modified datetime default NULL,
  title varchar(255) NOT NULL default '',
  data text NOT NULL,
  keywords varchar(128) default '',
  authors varchar(255) default NULL,
  comments varchar(128) default NULL,
  hits int(11) default '0',
  msc varchar(16) default NULL,
  loc varchar(32) default NULL,
  isbn varchar(32) default NULL,
  rights text,
  urls text,
  PRIMARY KEY  (uid),
  KEY books_uid_idx (uid),
  KEY books_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'books_uid_seq'
--

CREATE TABLE books_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'cache'
--

CREATE TABLE cache (
  objectid int(11) NOT NULL default '0',
  method char(3) default NULL,
  valid int(11) default '0',
  build int(11) default '0',
  rrequests int(11) default '0',
  tbl varchar(16) default NULL,
  touched datetime default NULL,
  bad int default 0,
  KEY cache_objectid_idx (objectid),
  UNIQUE KEY cache_id_idx (objectid, tbl, method)
) TYPE=MyISAM;

--
-- Table structure for table 'catlinks'
--

CREATE TABLE catlinks (
  a int(11) default NULL,
  b int(11) default NULL,
  nsa int(11) default NULL,
  nsb int(11) default NULL,
  KEY catlinks_a_idx (a),
  KEY catlinks_b_idx (b)
) TYPE=MyISAM;

--
-- Table structure for table 'classification'
--

CREATE TABLE classification (
  tbl varchar(32) NOT NULL default '',
  objectid int(11) NOT NULL default '0',
  ns varchar(16) NOT NULL default '',
  catid int(11) NOT NULL default '0',
  ord int(11) default NULL,
  nsid int(11) default NULL,
  KEY classification_catid_idx (catid),
  KEY classification_objectid_idx (objectid)
) TYPE=MyISAM;

--
-- Table structure for table 'collab'
--

CREATE TABLE collab (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  title varchar(255) NOT NULL default '',
  abstract text,
  data text,
  _lock int(11) default '0',
  created datetime default NULL,
  locktime datetime default NULL,
  lockuser int(11) default NULL,
  published tinyint(4) default '0',
  modified datetime default NULL,
  version int(11) default '1',
  hits int(11) default '0',
  sitedoc tinyint(4) default '0',
  PRIMARY KEY  (uid),
  KEY userid (userid),
  KEY collab_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'collab_uid_seq'
--

CREATE TABLE collab_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'concepts'
--

CREATE TABLE concepts (
  id int(11) NOT NULL default '0',
  objectid int(11) NOT NULL default '0',
  isprimary int(11) NOT NULL default '0',
  istitle int(11) NOT NULL default '0',
  name varchar(255) NOT NULL default '',
  KEY concepts_id_idx (id),
  KEY concepts_objectid_idx (objectid),
  KEY concepts_name_idx (name)
) TYPE=MyISAM;

--
-- Table structure for table 'concepts_id_seq'
--

CREATE TABLE concepts_id_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'corrections'
--

CREATE TABLE corrections (
  uid int(11) NOT NULL default '0',
  objectid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  type char(3) NOT NULL default '',
  title varchar(128) default NULL,
  data text NOT NULL,
  filed datetime default NULL,
  closed datetime default NULL,
  closedbyid int(11) NOT NULL default '0',
  accepted int(11) default NULL,
  comment text,
  grace datetime default NULL,
  graceint int(11) default NULL,
  PRIMARY KEY  (uid),
  KEY corrections_objectid_idx (objectid),
  KEY corrections_userid_idx (userid),
  KEY corrections_uid_idx (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'corrections_uid_seq'
--

CREATE TABLE corrections_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'forums'
--

CREATE TABLE forums (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  created datetime default NULL,
  modified datetime default NULL,
  parentid int(11) default NULL,
  title varchar(128) NOT NULL default '',
  data text NOT NULL,
  PRIMARY KEY  (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'forums_uid_seq'
--

CREATE TABLE forums_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'group_members'
--

CREATE TABLE group_members (
  groupid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  KEY group_members_groupid_idx (groupid),
  KEY group_members_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'groups'
--

CREATE TABLE groups (
  groupid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  groupname varchar(128) default NULL,
  description text,
  PRIMARY KEY  (groupid),
  KEY groups_groupname_idx (groupname)
) TYPE=MyISAM;

--
-- Table structure for table 'groups_groupid_seq'
--

CREATE TABLE groups_groupid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'hits'
--

CREATE TABLE hits (
  uid int(11) NOT NULL auto_increment,
  objectid int(11) NOT NULL default '0',
  tblid int(11) NOT NULL default '0',
  at timestamp(14) NOT NULL,
  PRIMARY KEY  (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'lastmsg'
--

CREATE TABLE lastmsg (
  tbl varchar(32) NOT NULL default '',
  objid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  lastmsg int(11) NOT NULL default '0',
  KEY lastmsg_tbl_idx (tbl),
  KEY lastmsg_objid_id (objid),
  KEY lastmsg_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'lec'
--

CREATE TABLE lec (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  created datetime default NULL,
  modified datetime default NULL,
  title varchar(255) NOT NULL default '',
  data text NOT NULL,
  keywords varchar(128) default '',
  authors varchar(255) default NULL,
  comments varchar(128) default NULL,
  hits int(11) default '0',
  msc varchar(16) default NULL,
  urls text,
  rights varchar(255) default '',
  PRIMARY KEY  (uid),
  KEY lec_uid_idx (uid),
  KEY lec_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'lec_uid_seq'
--

CREATE TABLE lec_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'links'
--

CREATE TABLE links (
  fromid int(11) NOT NULL default '0',
  fromtbl varchar(16) NOT NULL default '',
  toid int(11) NOT NULL default '0',
  totbl varchar(16) NOT NULL default '',
  KEY links_fromid_idx (fromid),
  KEY links_toid_idx (toid)
) TYPE=MyISAM;

--
-- Table structure for table 'mail'
--

CREATE TABLE mail (
  uid int(11) NOT NULL default '0',
  userto int(11) NOT NULL default '0',
  userfrom int(11) NOT NULL default '0',
  subject varchar(128) NOT NULL default '',
  body text NOT NULL,
  sent datetime default NULL,
  _read int(11) default NULL,
  PRIMARY KEY  (uid),
  KEY mail_userto_idx (userto),
  KEY mail_userfrom_idx (userfrom)
) TYPE=MyISAM;

--
-- Table structure for table 'mail_uid_seq'
--

CREATE TABLE mail_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'messages'
--

CREATE TABLE messages (
  uid int(11) NOT NULL default '0',
  visible tinyint(4) not null default '1',
  objectid int(11) NOT NULL default '0',
  replyto int(11) default '-1',
  created datetime default NULL,
  userid int(11) NOT NULL default '0',
  subject varchar(128) default 'none',
  body text,
  tbl varchar(16) default NULL,
  threadid int(11) default NULL,
  PRIMARY KEY  (uid),
  UNIQUE KEY messages_uid_idx (uid),
  KEY messages_objectid_idx (objectid),
  KEY messages_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'messages_uid_seq'
--

CREATE TABLE messages_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'msc'
--

CREATE TABLE msc (
  id varchar(6) NOT NULL default '',
  comment varchar(128) default NULL,
  parent varchar(6) default NULL,
  uid int(11) NOT NULL default '0',
  PRIMARY KEY  (uid),
  KEY msc_id_idx (id),
  KEY msc_parent_idx (parent),
  KEY msc_uid_idx (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'nag'
--

CREATE TABLE nag (
  cid int(11) default NULL,
  lastnag datetime default NULL,
  KEY nag_cid_index (cid)
) TYPE=MyISAM;

--
-- Table structure for table 'news'
--

CREATE TABLE news (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  created datetime default NULL,
  modified datetime default NULL,
  title varchar(128) NOT NULL default '',
  hits int(11) default '0',
  intro text,
  body text,
  PRIMARY KEY  (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'news_uid_seq'
--

CREATE TABLE news_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'notices'
--

CREATE TABLE notices (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  userfrom int(11) default NULL,
  title varchar(128) default NULL,
  created datetime default NULL,
  viewed int(11) default '0',
  data text,
  choice_title text,
  choice_action text,
  choice_default int(11) default NULL,
  PRIMARY KEY  (uid),
  KEY notices_userid_hidx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'notices_uid_seq'
--

CREATE TABLE notices_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'ns'
--

CREATE TABLE ns (
  name varchar(16) NOT NULL default '',
  shortdesc varchar(64) NOT NULL default '',
  longdesc varchar(255) NOT NULL default '',
  link varchar(255) default NULL,
  id int(11) default NULL
) TYPE=MyISAM;

--
-- Table structure for table 'objects'
--

CREATE TABLE objects (
  uid int(11) NOT NULL default '0',
  type int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  created datetime default NULL,
  modified datetime default NULL,
  parentid int(11) default NULL,
  title varchar(255) NOT NULL default '',
  data text NOT NULL,
  preamble text,
  name varchar(255) NOT NULL default '',
  related text,
  synonyms text,
  defines text,
  keywords text,
  hits int(11) default '0',
  self int(11) default NULL,
  pronounce varchar(255) default NULL,
  version int(11) default NULL,
  KEY objects_ino_uid_idx (uid),
  KEY objects_ino_parentid_idx (parentid),
  KEY objects_ino_title_idx (title),
  KEY objects_ino_name_idx (name),
  KEY objects_ino_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'objects_uid_seq'
--

CREATE TABLE objects_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'objindex'
--

CREATE TABLE objindex (
  objectid int(11) NOT NULL default '0',
  tbl varchar(16) NOT NULL default '',
  userid int(11) NOT NULL default '0',
  title varchar(128) NOT NULL default '',
  cname varchar(128) NOT NULL default '',
  type int(11) NOT NULL default '1',
  ichar char(1) default NULL,
  source varchar(16) default NULL,
  KEY objindex_cnameidx (cname),
  KEY objindex_ichar_idx (ichar),
  KEY objindex_title_idx (title),
  KEY objindex_userid_idx (userid),
  KEY objindex_objectid_idx (objectid)
) TYPE=MyISAM;

--
-- Table structure for table 'objlinks'
--

CREATE TABLE objlinks (
  uid int(11) NOT NULL auto_increment,
  srctbl varchar(32) NOT NULL default '',
  desttbl varchar(32) NOT NULL default '',
  srcid varchar(32) NOT NULL default '',
  destid varchar(32) NOT NULL default '',
  note varchar(128) default NULL,
  PRIMARY KEY  (uid),
  KEY objlinks_destid_hidx (destid),
  KEY objlinks_srcid_hidx (srcid)
) TYPE=MyISAM;

--
-- Table structure for table 'papers'
--

CREATE TABLE papers (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  created datetime default NULL,
  modified datetime default NULL,
  title varchar(255) NOT NULL default '',
  data text NOT NULL,
  keywords varchar(128) default '',
  authors varchar(255) default NULL,
  comments varchar(128) default NULL,
  hits int(11) default '0',
  msc varchar(16) default NULL,
  rights varchar(255) default '',
  PRIMARY KEY  (uid),
  KEY papers_uid_idx (uid),
  KEY papers_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'papers_uid_seq'
--

CREATE TABLE papers_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'polls'
--

CREATE TABLE polls (
  uid int(11) NOT NULL default '0',
  userid int(11) NOT NULL default '0',
  start datetime default NULL,
  finish datetime default NULL,
  options varchar(255) NOT NULL default '',
  title varchar(128) NOT NULL default '',
  PRIMARY KEY  (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'polls_uid_seq'
--

CREATE TABLE polls_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'relsuggest'
--

CREATE TABLE relsuggest (
  objectid int(11) NOT NULL default '0',
  tbl varchar(16) NOT NULL default '',
  related varchar(255) NOT NULL default '',
  KEY relsuggest_objectid_idx (objectid),
  KEY relsuggest_related_idx (related)
) TYPE=MyISAM;

--
-- Table structure for table 'rendered_images'
--

CREATE TABLE rendered_images (
  uid int(11) NOT NULL auto_increment,
  imagekey varchar(128) NOT NULL,
  variant varchar(16) NOT NULL,
  image blob,
  align varchar(10) default NULL,
  PRIMARY KEY  (uid),
  UNIQUE KEY rendered_images_imagekey_idx (imagekey, variant)
) TYPE=MyISAM;

--
-- Table structure for table 'requests'
--

CREATE TABLE requests (
  uid int(11) NOT NULL default '0',
  creatorid int(11) NOT NULL default '0',
  fulfillerid int(11) default NULL,
  title varchar(128) NOT NULL default '',
  data text,
  created datetime default NULL,
  closed datetime default NULL,
  fulfilled datetime default NULL,
  PRIMARY KEY  (uid),
  KEY requests_uid_idx (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'requests_uid_seq'
--

CREATE TABLE requests_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'score'
--

CREATE TABLE score (
  uid int(11) NOT NULL auto_increment,
  userid int(11) NOT NULL default '0',
  delta int(11) NOT NULL default '0',
  occured timestamp(14) NOT NULL,
  PRIMARY KEY  (uid),
  KEY score_occured_idx (occured),
  KEY score_userid_idx (userid)
) TYPE=MyISAM;

--
-- Table structure for table 'searchresults'
--

CREATE TABLE searchresults (
  objectid int(11) NOT NULL default '0',
  tbl varchar(16) NOT NULL default '',
  ts timestamp(14) NOT NULL,
  rank double NOT NULL default '0',
  token int(11) NOT NULL default '0',
  KEY searchresults_rank_idx (rank),
  KEY searchresults_token_idx (token)
) TYPE=MyISAM;

--
-- Table structure for table 'storage'
--

CREATE TABLE storage (
  _key varchar(64) NOT NULL default '',
  _val text,
  valid int(11) default '1',
  lastupdate varchar(32) default NULL,
  timeout varchar(32) default NULL,
  callback varchar(32) default NULL,
  KEY storage_key_idx (_key)
) TYPE=MyISAM;

--
-- Table structure for table 'tdesc'
--

CREATE TABLE tdesc (
  tname varchar(32) NOT NULL default '',
  description varchar(128) NOT NULL default '',
  uid int(11) default NULL
) TYPE=MyISAM;

--
-- Table structure for table 'users'
--

CREATE TABLE users (
  uid int(11) NOT NULL default '0',
  username varchar(32) NOT NULL default '',
  password varchar(32) NOT NULL default '',
  email varchar(255) NOT NULL default '',
  joined datetime default NULL,
  forename varchar(64) default '',
  surname varchar(64) default '',
  city varchar(128) default '',
  state varchar(128) default '',
  country varchar(128) default '',
  score int(11) default '0',
  homepage varchar(255) default '',
  access int(11) default '10',
  sig text,
  prefs text,
  last datetime default NULL,
  bio text,
  preamble text,
  active int(11) default '1',
  PRIMARY KEY  (uid),
  lastip varchar(15),
  KEY users_username_idx (username),
  KEY users_uid_idx (uid)
) TYPE=MyISAM;

--
-- Table structure for table 'users_uid_seq'
--

CREATE TABLE users_uid_seq (
  val int(11) NOT NULL auto_increment,
  PRIMARY KEY  (val)
) TYPE=MyISAM;

--
-- Table structure for table 'watches'
--

CREATE TABLE watches (
  uid int(11) NOT NULL auto_increment,
  objectid int(11) NOT NULL default '0',
  tbl varchar(16) NOT NULL default '',
  userid int(11) NOT NULL default '0',
  PRIMARY KEY  (uid),
  KEY watches_objectid_idx (objectid)
) TYPE=MyISAM;

--
-- Table structure for table 'ownerlog'
--

CREATE TABLE ownerlog (
  objectid int(11) NOT NULL,
  tbl varchar(16) NOT NULL,
  userid int(11) NOT NULL,
  action char(1),
  ts timestamp,
  key(objectid),
  key(userid)
) TYPE=MyISAM;

--
-- Table structure for table 'inv_dfs' -- invalidation document
-- frequencies.
--
CREATE TABLE inv_dfs (
  id int(11) NOT NULL,
  word_or_phrase tinyint(4) NOT NULL,
  count tinyint(4) NOT NULL,
  key(id)
) TYPE=MyISAM;

--
-- Table structure for table 'inv_idx' -- invalidation word-doc
-- occurrence index.
--
CREATE TABLE inv_idx (
  id int(11) NOT NULL,
  word_or_phrase tinyint(4) NOT NULL,
  objectid int(11) NOT NULL,
  key(id),
  key(objectid)
) TYPE=MyISAM;


-- Table structure for table 'inv_phrases' -- invalidation phrase
-- dictionary.

create table inv_phrases (
  phrase char(255) not null, 
  id mediumint(8) unsigned not null auto_increment, 
  primary key(id), 
  key(phrase)
) TYPE=MyISAM;

-- invalidation words dictionary

create table inv_words (
	id mediumint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	word char(32) NOT NULL UNIQUE 
);


-- ****************************************************************************
--  
--                            SECTION 1 : INITIALIZATION 
--
-- ****************************************************************************

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
