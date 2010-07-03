#!/usr/bin/perl
use strict;

#use Apache2;
use Apache::DBI;
use Apache2::Request;
use Apache2::RequestIO;
use Apache2::RequestUtil;
use Apache2::RequestRec;
use Apache2::Upload;

#use DBI();
use XML::LibXML;
use XML::LibXSLT;

# allow deep-recursive XSL template functions
#
XML::LibXSLT->max_depth(65535);

# search engine communication
#

# use base Noosphere modules
#
use Noosphere;
use Noosphere::baseconf;
use Noosphere::Config;
use Noosphere::DB;

# search engine library
# 
use lib $Noosphere::baseconf::base_config{SEARCH_ENGINE_LIB};
use SearchClient;

# ratings module
#
if ($Noosphere::baseconf::base_config{RATINGS_MODULE}) {
	    use Noosphere::Ratings::Ratings;
}

# preload all the rest of the Noosphere modules
#
use Noosphere::Dispatch;
use Noosphere::Util;
use Noosphere::Charset;
use Noosphere::Cookies;
use Noosphere::Layout;
use Noosphere::Login;
use Noosphere::Ticket;
use Noosphere::News;
use Noosphere::NewUser;
use Noosphere::Docs;
use Noosphere::GetObj;
use Noosphere::EditObj;
use Noosphere::DelObj;
use Noosphere::Encyclopedia;
use Noosphere::StatCache;
use Noosphere::Stats;
use Noosphere::UserData;
use Noosphere::Messages;
use Noosphere::Polls;
use Noosphere::Forums;
use Noosphere::Latex;
use Noosphere::Admin;
use Noosphere::Users;
use Noosphere::Spell;
use Noosphere::Search;
use Noosphere::Filebox;
use Noosphere::Msc;
use Noosphere::Params;
use Noosphere::Cache;
use Noosphere::Corrections;
use Noosphere::Mail;
use Noosphere::Morphology;
use Noosphere::Collection;
use Noosphere::Crossref;
use Noosphere::Indexing;
use Noosphere::Notices;
use Noosphere::Classification;
use Noosphere::Help;
use Noosphere::Requests;
use Noosphere::Watches;
use Noosphere::IR;
use Noosphere::Template;
use Noosphere::FileCache;
use Noosphere::Pronounce;
use Noosphere::Orphan;
use Noosphere::Authors;
use Noosphere::XSLTemplate;
use Noosphere::XML;
use Noosphere::Versions;
use Noosphere::Password;
use Noosphere::GenericObject;
use Noosphere::Collab;
use Noosphere::Owners;
use Noosphere::Linkpolicy;

1;

