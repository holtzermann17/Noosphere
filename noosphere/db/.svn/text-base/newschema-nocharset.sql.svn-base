-- MySQL dump 10.11
--
-- Host: localhost    Database: pmdev
-- ------------------------------------------------------
-- Server version	5.0.75-0ubuntu10.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `acl`
--

DROP TABLE IF EXISTS `acl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `acl` (
  `uid` int(11) NOT NULL default '0',
  `tbl` varchar(16) NOT NULL default '',
  `objectid` int(11) NOT NULL default '0',
  `subjectid` int(11) NOT NULL default '0',
  `_read` int(11) default '1',
  `_write` int(11) default '0',
  `_acl` int(11) default '0',
  `user_or_group` char(1) default 'u',
  `default_or_normal` char(1) default 'n',
  PRIMARY KEY  (`uid`),
  KEY `acl_objectid_idx` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `acl_default`
--

DROP TABLE IF EXISTS `acl_default`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `acl_default` (
  `uid` int(11) NOT NULL auto_increment,
  `userid` int(11) default '0',
  `subjectid` int(11) default '0',
  `_read` tinyint(4) default '1',
  `_write` tinyint(4) default '0',
  `_acl` tinyint(4) default '0',
  `user_or_group` char(1) default 'u',
  `default_or_normal` char(1) default 'n',
  PRIMARY KEY  (`uid`),
  KEY `userid` (`userid`)
) ENGINE=MyISAM AUTO_INCREMENT=46306 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `acl_default_uid_seq`
--

DROP TABLE IF EXISTS `acl_default_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `acl_default_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=46306 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `acl_uid_seq`
--

DROP TABLE IF EXISTS `acl_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `acl_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=42969 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `actions` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) default NULL,
  `type` int(11) NOT NULL default '0',
  `objectid` int(11) default NULL,
  `data` text,
  `created` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `score` int(11) NOT NULL default '0',
  PRIMARY KEY  (`uid`),
  KEY `actions_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `actions_uid_seq`
--

DROP TABLE IF EXISTS `actions_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `actions_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=212 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `authors`
--

DROP TABLE IF EXISTS `authors`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `authors` (
  `tbl` varchar(16) NOT NULL default '',
  `objectid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `ts` datetime default NULL,
  KEY `authors_userid_idx` (`userid`),
  KEY `authors_ts_idx` (`ts`),
  KEY `authors_objectid_idx` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `blacklist`
--

DROP TABLE IF EXISTS `blacklist`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `blacklist` (
  `uid` int(11) NOT NULL default '0',
  `mask` varchar(128) NOT NULL default '',
  PRIMARY KEY  (`uid`),
  KEY `blacklist_uid_idx` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `blacklist_uid_seq`
--

DROP TABLE IF EXISTS `blacklist_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `blacklist_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `books`
--

DROP TABLE IF EXISTS `books`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `books` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `title` varchar(255) NOT NULL default '',
  `data` text NOT NULL,
  `keywords` varchar(128) default '',
  `authors` varchar(255) default NULL,
  `comments` varchar(128) default NULL,
  `hits` int(11) default '0',
  `msc` varchar(16) default NULL,
  `loc` varchar(32) default NULL,
  `isbn` varchar(32) default NULL,
  `rights` text,
  `urls` text,
  PRIMARY KEY  (`uid`),
  KEY `books_uid_idx` (`uid`),
  KEY `books_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `books_uid_seq`
--

DROP TABLE IF EXISTS `books_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `books_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=264 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cache` (
  `objectid` int(11) NOT NULL default '0',
  `method` char(3) default NULL,
  `valid` int(11) default '0',
  `build` int(11) default '0',
  `tbl` char(16) default NULL,
  `touched` datetime default NULL,
  `rrequests` int(11) default '0',
  `bad` int(11) default '0',
  `valid_html` int(11) default NULL,
  UNIQUE KEY `cache_id_idx` (`objectid`,`tbl`,`method`),
  KEY `cache_objectid_idx` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `catlinks`
--

DROP TABLE IF EXISTS `catlinks`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `catlinks` (
  `a` int(11) default NULL,
  `b` int(11) default NULL,
  `nsa` int(11) default NULL,
  `nsb` int(11) default NULL,
  KEY `catlinks_a_idx` (`a`),
  KEY `catlinks_b_idx` (`b`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `classification`
--

DROP TABLE IF EXISTS `classification`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `classification` (
  `tbl` varchar(32) NOT NULL default '',
  `objectid` int(11) NOT NULL default '0',
  `ns` varchar(16) NOT NULL default '',
  `catid` int(11) NOT NULL default '0',
  `ord` int(11) default NULL,
  `nsid` int(11) default NULL,
  KEY `classification_catid_idx` (`catid`),
  KEY `classification_objectid_idx` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `collab`
--

DROP TABLE IF EXISTS `collab`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `collab` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `title` varchar(255) NOT NULL default '',
  `abstract` text,
  `data` text,
  `_lock` int(11) default '0',
  `created` datetime default NULL,
  `locktime` datetime default NULL,
  `lockuser` int(11) default NULL,
  `published` tinyint(4) default '0',
  `modified` datetime default NULL,
  `version` int(11) default '1',
  `hits` int(11) default '0',
  `sitedoc` int(11) default '0',
  PRIMARY KEY  (`uid`),
  KEY `userid` (`userid`),
  KEY `collab_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `collab_uid_seq`
--

DROP TABLE IF EXISTS `collab_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `collab_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=160 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `concepts`
--

DROP TABLE IF EXISTS `concepts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `concepts` (
  `id` int(11) NOT NULL default '0',
  `objectid` int(11) NOT NULL default '0',
  `isprimary` int(11) NOT NULL default '0',
  `istitle` int(11) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  KEY `concepts_id_idx` (`id`),
  KEY `concepts_objectid_idx` (`objectid`),
  KEY `concepts_name_idx` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `concepts_id_seq`
--

DROP TABLE IF EXISTS `concepts_id_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `concepts_id_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=6151 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `corrections`
--

DROP TABLE IF EXISTS `corrections`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `corrections` (
  `uid` int(11) NOT NULL default '0',
  `objectid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `type` char(3) NOT NULL default '',
  `title` varchar(128) default NULL,
  `data` text NOT NULL,
  `filed` datetime default NULL,
  `closed` datetime default NULL,
  `accepted` int(11) default NULL,
  `comment` text,
  `graceint` int(11) default NULL,
  `closedbyid` int(11) NOT NULL default '0',
  PRIMARY KEY  (`uid`),
  KEY `corrections_objectid_idx` (`objectid`),
  KEY `corrections_userid_idx` (`userid`),
  KEY `corrections_uid_idx` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `corrections_uid_seq`
--

DROP TABLE IF EXISTS `corrections_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `corrections_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=14592 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `corstat`
--

DROP TABLE IF EXISTS `corstat`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `corstat` (
  `objectid` int(11) NOT NULL default '0',
  `cnt` bigint(21) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `forums`
--

DROP TABLE IF EXISTS `forums`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `forums` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `parentid` int(11) default NULL,
  `title` varchar(128) NOT NULL default '',
  `data` text NOT NULL,
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `forums_uid_seq`
--

DROP TABLE IF EXISTS `forums_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `forums_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=238 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `group_members`
--

DROP TABLE IF EXISTS `group_members`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `group_members` (
  `groupid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  KEY `group_members_groupid_idx` (`groupid`),
  KEY `group_members_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `groups` (
  `groupid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `groupname` varchar(128) default NULL,
  `description` text,
  PRIMARY KEY  (`groupid`),
  KEY `groups_groupname_idx` (`groupname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `groups_groupid_seq`
--

DROP TABLE IF EXISTS `groups_groupid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `groups_groupid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=23498 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `hits`
--

DROP TABLE IF EXISTS `hits`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `hits` (
  `uid` int(11) NOT NULL auto_increment,
  `objectid` int(11) NOT NULL default '0',
  `tblid` int(11) NOT NULL default '0',
  `at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM AUTO_INCREMENT=46754703 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inv_dfs`
--

DROP TABLE IF EXISTS `inv_dfs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `inv_dfs` (
  `id` int(11) default NULL,
  `word_or_phrase` tinyint(4) default NULL,
  `count` tinyint(4) default NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inv_idx`
--

DROP TABLE IF EXISTS `inv_idx`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `inv_idx` (
  `id` int(11) default NULL,
  `word_or_phrase` tinyint(4) default NULL,
  `objectid` int(11) default NULL,
  KEY `id` (`id`),
  KEY `objectid` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inv_phrases`
--

DROP TABLE IF EXISTS `inv_phrases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `inv_phrases` (
  `phrase` char(255) NOT NULL default '',
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  PRIMARY KEY  (`id`),
  KEY `phrase` (`phrase`)
) ENGINE=MyISAM AUTO_INCREMENT=563604 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inv_words`
--

DROP TABLE IF EXISTS `inv_words`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `inv_words` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `word` char(32) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `word` (`word`)
) ENGINE=MyISAM AUTO_INCREMENT=154730 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `lastmsg`
--

DROP TABLE IF EXISTS `lastmsg`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `lastmsg` (
  `tbl` varchar(32) NOT NULL default '',
  `objid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `lastmsg` int(11) NOT NULL default '0',
  KEY `lastmsg_tbl_idx` (`tbl`),
  KEY `lastmsg_objid_id` (`objid`),
  KEY `lastmsg_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `lec`
--

DROP TABLE IF EXISTS `lec`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `lec` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `title` varchar(255) NOT NULL default '',
  `data` text NOT NULL,
  `keywords` varchar(128) default '',
  `authors` varchar(255) default NULL,
  `comments` varchar(128) default NULL,
  `hits` int(11) default '0',
  `msc` varchar(16) default NULL,
  `urls` text,
  `rights` varchar(255) default '',
  PRIMARY KEY  (`uid`),
  KEY `lec_uid_idx` (`uid`),
  KEY `lec_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `lec_uid_seq`
--

DROP TABLE IF EXISTS `lec_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `lec_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=189 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `links`
--

DROP TABLE IF EXISTS `links`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `links` (
  `fromid` int(11) NOT NULL default '0',
  `fromtbl` varchar(16) NOT NULL default '',
  `toid` int(11) NOT NULL default '0',
  `totbl` varchar(16) NOT NULL default '',
  KEY `links_fromid_idx` (`fromid`),
  KEY `links_toid_idx` (`toid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mail`
--

DROP TABLE IF EXISTS `mail`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mail` (
  `uid` int(11) NOT NULL default '0',
  `userto` int(11) NOT NULL default '0',
  `userfrom` int(11) NOT NULL default '0',
  `subject` varchar(128) NOT NULL default '',
  `body` text NOT NULL,
  `sent` datetime default NULL,
  `_read` int(11) default NULL,
  PRIMARY KEY  (`uid`),
  KEY `mail_userto_idx` (`userto`),
  KEY `mail_userfrom_idx` (`userfrom`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mail_uid_seq`
--

DROP TABLE IF EXISTS `mail_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mail_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=10572 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `messages` (
  `uid` int(11) NOT NULL default '0',
  `objectid` int(11) NOT NULL default '0',
  `replyto` int(11) default '-1',
  `created` datetime default NULL,
  `userid` int(11) NOT NULL default '0',
  `subject` varchar(128) default 'none',
  `body` text,
  `tbl` varchar(16) default NULL,
  `threadid` int(11) default NULL,
  `visible` int(11) default '1',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `messages_uid_idx` (`uid`),
  KEY `messages_objectid_idx` (`objectid`),
  KEY `messages_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `messages_tmp`
--

DROP TABLE IF EXISTS `messages_tmp`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `messages_tmp` (
  `uid` int(11) NOT NULL default '0',
  `objectid` int(11) NOT NULL default '0',
  `replyto` int(11) default '-1',
  `created` datetime default NULL,
  `userid` int(11) NOT NULL default '0',
  `subject` varchar(128) default 'none',
  `body` text,
  `tbl` varchar(16) default NULL,
  `threadid` int(11) default NULL,
  `visible` int(11) default '1',
  `secret_key` varchar(45) NOT NULL default '',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `messages_tmp_uid_idx` (`uid`),
  KEY `messages_tmp_objectid_idx` (`objectid`),
  KEY `messages_tmp_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `messages_uid_seq`
--

DROP TABLE IF EXISTS `messages_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `messages_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=21702 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `msc`
--

DROP TABLE IF EXISTS `msc`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `msc` (
  `id` varchar(6) NOT NULL default '',
  `comment` varchar(128) default NULL,
  `parent` varchar(6) default NULL,
  `uid` int(11) NOT NULL default '0',
  PRIMARY KEY  (`uid`),
  KEY `msc_id_idx` (`id`),
  KEY `msc_parent_idx` (`parent`),
  KEY `msc_uid_idx` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `nag`
--

DROP TABLE IF EXISTS `nag`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `nag` (
  `cid` int(11) default NULL,
  `lastnag` datetime default NULL,
  KEY `nag_cid_index` (`cid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `news`
--

DROP TABLE IF EXISTS `news`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `title` varchar(128) NOT NULL default '',
  `hits` int(11) default '0',
  `intro` text,
  `body` text,
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `news_uid_seq`
--

DROP TABLE IF EXISTS `news_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=352 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `notices`
--

DROP TABLE IF EXISTS `notices`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `notices` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `userfrom` int(11) default NULL,
  `title` varchar(128) default NULL,
  `created` datetime default NULL,
  `viewed` int(11) default '0',
  `data` text,
  `choice_title` text,
  `choice_action` text,
  `choice_default` int(11) default NULL,
  PRIMARY KEY  (`uid`),
  KEY `notices_userid_hidx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `notices_uid_seq`
--

DROP TABLE IF EXISTS `notices_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `notices_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=60208 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ns`
--

DROP TABLE IF EXISTS `ns`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ns` (
  `name` varchar(16) NOT NULL default '',
  `shortdesc` varchar(64) NOT NULL default '',
  `longdesc` varchar(255) NOT NULL default '',
  `link` varchar(255) default NULL,
  `id` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `object_rating`
--

DROP TABLE IF EXISTS `object_rating`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `object_rating` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `value` double NOT NULL default '0',
  `userid` int(10) unsigned default NULL,
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM AUTO_INCREMENT=11568 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `object_rating_all`
--

DROP TABLE IF EXISTS `object_rating_all`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `object_rating_all` (
  `oid` int(10) unsigned NOT NULL default '0',
  `ratid` int(10) unsigned NOT NULL default '0',
  `answer` int(10) unsigned NOT NULL default '0',
  `weight` int(11) default NULL,
  `userid` int(10) unsigned NOT NULL default '0',
  `date` varchar(20) NOT NULL default '',
  `comment` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `objects`
--

DROP TABLE IF EXISTS `objects`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `objects` (
  `uid` int(11) NOT NULL default '0',
  `type` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `parentid` int(11) default NULL,
  `title` varchar(255) NOT NULL default '',
  `data` text NOT NULL,
  `preamble` text,
  `name` varchar(255) NOT NULL default '',
  `related` text,
  `synonyms` text,
  `defines` text,
  `keywords` text,
  `hits` int(11) default '0',
  `self` int(11) default NULL,
  `pronounce` varchar(255) default NULL,
  `version` int(11) default NULL,
  `linkpolicy` text,
  KEY `objects_ino_uid_idx` (`uid`),
  KEY `objects_ino_parentid_idx` (`parentid`),
  KEY `objects_ino_title_idx` (`title`),
  KEY `objects_ino_name_idx` (`name`),
  KEY `objects_ino_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `objects_uid_seq`
--

DROP TABLE IF EXISTS `objects_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `objects_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=11682 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `objindex`
--

DROP TABLE IF EXISTS `objindex`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `objindex` (
  `objectid` int(11) NOT NULL default '0',
  `tbl` varchar(16) NOT NULL default '',
  `userid` int(11) NOT NULL default '0',
  `title` varchar(128) NOT NULL default '',
  `cname` varchar(128) NOT NULL default '',
  `type` int(11) NOT NULL default '1',
  `ichar` char(1) default NULL,
  `source` varchar(16) default NULL,
  KEY `objindex_cnameidx` (`cname`),
  KEY `objindex_ichar_idx` (`ichar`),
  KEY `objindex_title_idx` (`title`),
  KEY `objindex_userid_idx` (`userid`),
  KEY `objindex_objectid_idx` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `objlinks`
--

DROP TABLE IF EXISTS `objlinks`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `objlinks` (
  `uid` int(11) NOT NULL auto_increment,
  `srctbl` varchar(32) NOT NULL default '',
  `desttbl` varchar(32) NOT NULL default '',
  `srcid` varchar(32) NOT NULL default '',
  `destid` varchar(32) NOT NULL default '',
  `note` varchar(128) default NULL,
  PRIMARY KEY  (`uid`),
  KEY `objlinks_destid_hidx` (`destid`),
  KEY `objlinks_srcid_hidx` (`srcid`)
) ENGINE=MyISAM AUTO_INCREMENT=98283 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ownerlog`
--

DROP TABLE IF EXISTS `ownerlog`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ownerlog` (
  `objectid` int(11) NOT NULL default '0',
  `tbl` varchar(16) NOT NULL default '',
  `userid` int(11) NOT NULL default '0',
  `action` char(1) NOT NULL default '',
  `ts` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  KEY `userid` (`userid`),
  KEY `objectid` (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `papers`
--

DROP TABLE IF EXISTS `papers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `papers` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `title` varchar(255) NOT NULL default '',
  `data` text NOT NULL,
  `keywords` varchar(128) default '',
  `authors` varchar(255) default NULL,
  `comments` varchar(128) default NULL,
  `hits` int(11) default '0',
  `msc` varchar(16) default NULL,
  `rights` varchar(255) default '',
  PRIMARY KEY  (`uid`),
  KEY `papers_uid_idx` (`uid`),
  KEY `papers_userid_idx` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `papers_uid_seq`
--

DROP TABLE IF EXISTS `papers_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `papers_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=530 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `polls`
--

DROP TABLE IF EXISTS `polls`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `polls` (
  `uid` int(11) NOT NULL default '0',
  `userid` int(11) NOT NULL default '0',
  `start` datetime default NULL,
  `finish` datetime default NULL,
  `options` varchar(255) NOT NULL default '',
  `title` varchar(128) NOT NULL default '',
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `polls_uid_seq`
--

DROP TABLE IF EXISTS `polls_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `polls_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `relsuggest`
--

DROP TABLE IF EXISTS `relsuggest`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `relsuggest` (
  `objectid` int(11) NOT NULL default '0',
  `tbl` varchar(16) NOT NULL default '',
  `related` varchar(255) NOT NULL default '',
  KEY `relsuggest_objectid_idx` (`objectid`),
  KEY `relsuggest_related_idx` (`related`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `rendered_images`
--

DROP TABLE IF EXISTS `rendered_images`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `rendered_images` (
  `uid` int(11) NOT NULL auto_increment,
  `imagekey` varchar(128) NOT NULL default '',
  `variant` varchar(16) NOT NULL default '',
  `image` blob NOT NULL,
  `align` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `imagekey` (`imagekey`,`variant`)
) ENGINE=MyISAM AUTO_INCREMENT=5407 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `requests`
--

DROP TABLE IF EXISTS `requests`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `requests` (
  `uid` int(11) NOT NULL default '0',
  `creatorid` int(11) NOT NULL default '0',
  `fulfillerid` int(11) default NULL,
  `title` varchar(128) NOT NULL default '',
  `data` text,
  `created` datetime default NULL,
  `closed` datetime default NULL,
  `fulfilled` datetime default NULL,
  PRIMARY KEY  (`uid`),
  KEY `requests_uid_idx` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `requests_uid_seq`
--

DROP TABLE IF EXISTS `requests_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `requests_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=914 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `roles` (
  `objectid` int(11) default NULL,
  `userid` int(11) default NULL,
  `role` varchar(32) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `score`
--

DROP TABLE IF EXISTS `score`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `score` (
  `uid` int(11) NOT NULL auto_increment,
  `userid` int(11) NOT NULL default '0',
  `delta` int(11) NOT NULL default '0',
  `occured` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`uid`),
  KEY `score_occured_idx` (`occured`),
  KEY `score_userid_idx` (`userid`)
) ENGINE=MyISAM AUTO_INCREMENT=107741 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `searchresults`
--

DROP TABLE IF EXISTS `searchresults`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `searchresults` (
  `objectid` int(11) NOT NULL default '0',
  `tbl` varchar(16) NOT NULL default '',
  `ts` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `rank` double NOT NULL default '0',
  `token` int(11) NOT NULL default '0',
  KEY `searchresults_rank_idx` (`rank`),
  KEY `searchresults_token_idx` (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `source`
--

DROP TABLE IF EXISTS `source`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `source` (
  `uid` int(11) NOT NULL auto_increment,
  `nickname` varchar(16) NOT NULL default '',
  `name` varchar(255) NOT NULL default '',
  `url` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`uid`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `storage`
--

DROP TABLE IF EXISTS `storage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `storage` (
  `_key` varchar(64) NOT NULL default '',
  `_val` text,
  `valid` int(11) default '1',
  `lastupdate` varchar(32) default NULL,
  `timeout` varchar(32) default NULL,
  `callback` varchar(32) default NULL,
  KEY `storage_key_idx` (`_key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tags` (
  `objectid` int(11) default NULL,
  `tag` varchar(100) default NULL,
  `userid` int(11) default NULL,
  UNIQUE KEY `objectid` (`objectid`,`tag`,`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tdesc`
--

DROP TABLE IF EXISTS `tdesc`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tdesc` (
  `tname` varchar(32) NOT NULL default '',
  `description` varchar(128) NOT NULL default '',
  `uid` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users` (
  `uid` int(11) NOT NULL default '0',
  `username` varchar(32) NOT NULL default '',
  `password` varchar(32) NOT NULL default '',
  `email` varchar(255) NOT NULL default '',
  `joined` datetime default NULL,
  `forename` varchar(64) default '',
  `surname` varchar(64) default '',
  `city` varchar(128) default '',
  `state` varchar(128) default '',
  `country` varchar(128) default '',
  `score` int(11) default '0',
  `homepage` varchar(255) default '',
  `access` int(11) default '10',
  `sig` text,
  `prefs` text,
  `last` datetime default NULL,
  `bio` text,
  `preamble` text,
  `active` int(11) default '1',
  `lastip` varchar(15) default NULL,
  `karma` int(11) default '0',
  `approved` tinyint(1) default NULL,
  `middlename` varchar(64) default NULL,
  `displayrealname` tinyint(1) default NULL,
  `institution` varchar(64) default NULL,
  `institutionalrole` varchar(64) default NULL,
  PRIMARY KEY  (`uid`),
  KEY `users_username_idx` (`username`),
  KEY `users_uid_idx` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users_clique`
--

DROP TABLE IF EXISTS `users_clique`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users_clique` (
  `rated_user` int(10) unsigned NOT NULL default '0',
  `rating_user` int(10) unsigned NOT NULL default '0',
  `probability` double unsigned zerofill default '0000000000000000000000',
  PRIMARY KEY  (`rated_user`,`rating_user`),
  KEY `Index_1` (`rated_user`),
  KEY `Index_2` (`rating_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users_rating`
--

DROP TABLE IF EXISTS `users_rating`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users_rating` (
  `userid` int(11) NOT NULL default '0',
  `value` double NOT NULL default '0',
  `ranking` int(11) NOT NULL default '99999',
  PRIMARY KEY  (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users_uid_seq`
--

DROP TABLE IF EXISTS `users_uid_seq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users_uid_seq` (
  `val` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`val`)
) ENGINE=MyISAM AUTO_INCREMENT=23189 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `watches`
--

DROP TABLE IF EXISTS `watches`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `watches` (
  `uid` int(11) NOT NULL auto_increment,
  `objectid` int(11) NOT NULL default '0',
  `tbl` varchar(16) NOT NULL default '',
  `userid` int(11) NOT NULL default '0',
  PRIMARY KEY  (`uid`),
  KEY `watches_objectid_idx` (`objectid`)
) ENGINE=MyISAM AUTO_INCREMENT=45381 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-09-20 18:29:00
