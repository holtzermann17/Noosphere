/*
 * confhelper.h - class to parse and deal with configuration files
 */

#if !defined( __CONFHELPER_H__ )
#define __CONFHELPER_H__

#include <string>
#include <map>
#include <vector>

#include "config.h"

using namespace std;

const string CONF_MAIN =
	string( "ListenUnix,bool,true\n" ) +
	string( "ListenInet,bool,true\n" ) +
	string( "UnixSocket,string,\"/var/run/searchd/searchd.sock\"\n" ) + 
	/*string( "UnixSocket,string,\"/tmp/classd.sock\"\n" ) + */
	string( "BindAddress,string,\"0.0.0.0\"\n" ) +
	string( "ListenPort,int,1723\n" ) +
	string( "PidFile,string,\"/var/run/searchd/searchd.pid\"\n" ) + 
	string( "User,string,\"searchd\"\n" ) +
	string( "Group,string,\"searchd\"\n" ) +
	
	string( "LogFile,string,\"/var/log/searchd.log\"" ); 

class confhelper {
	public:
	private:
		enum {
			BOOL = 0,
			INT = 1,
			STRING = 2,
			SUBSECTION = 3
		};

		map<string,int> _typeof;
		map<string,string> _value;
	public:
		confhelper( string const &conffile, string const &format );

		bool get_bool( string const &key ) const;
		int get_int( string const &key ) const;
		string get_string( string const &key ) const;
};

#endif
