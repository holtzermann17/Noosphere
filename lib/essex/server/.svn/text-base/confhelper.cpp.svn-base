/*
 * confhelper.cpp
 */

#include <cassert>
#include <fstream>
#include <iostream>

#include "confhelper.h"
#include "util.h"

using namespace std;

confhelper::confhelper( string const &conffile, string const &format ) {
	/* temporary: just use the defaults */
	vector<string> fields = split( '\n', format );

	for( int i=0; i < fields.size(); ++i ) {
		/* @BUG: won't work with quoted , probably */
		vector<string> fieldinfo = split( ',', fields[i] );

		/* fail gracelessly if there are not 3 pieces */
		assert( fieldinfo.size()==3 );
		string key = fieldinfo[0];
		string type = fieldinfo[1];
		string def = fieldinfo[2];

		/* fail gracelessly if a key is duplicated */
		assert( _typeof.count( key )==0 );

		/* now set the key; die if the definition is invalid */
		if( type=="bool" ) _typeof[key] = BOOL;
		else if( type=="int" ) _typeof[key] = INT;
		else if( type=="string" ) _typeof[key] = STRING;
		else assert( 0 );

		/* set the value (values are converted to their native type when read) */
		_value[key] = def;
	}

	/* now read the conffile */
	ifstream inf( conffile.c_str() );
	if( inf.bad() ) {
		cerr << "Couldn't open config file " << conffile << endl;
		exit(1);
	}

	char tmp[4096];
	while( inf.getline( tmp, 4096 ) ) {
		/* remove comments */
		for( int i=0; i < strlen(tmp); ++i )
			if( tmp[i]=='#' ) {
				tmp[i] = 0; 
				break;
			}
		vector<string> tokens = splitwhite( string( tmp ) );
		if( tokens.size()==2 ) {
			string key = tokens[0];
			string val = tokens[1];
			/*cerr << key << " = '" << val << "'" << endl;*/
			assert( _typeof.count( key )==1 );
			_value[key] = val;
		}
	}
}

bool confhelper::get_bool( string const &key ) const {
	assert( _typeof.count( key )==1 );
	/* use find() instead of [] because find() is const */
	assert( (*_typeof.find( key )).second==BOOL );
	return ((*_value.find( key )).second=="true")?true:false;
}

int confhelper::get_int( string const &key ) const {
	assert( _typeof.count( key )==1 );
	assert( (*_typeof.find( key )).second==INT );
	return atoi( (*_value.find( key )).second.c_str() );
}

string confhelper::get_string( string const &key ) const {
	assert( _typeof.count( key )==1 );
	assert( (*_typeof.find( key )).second==STRING );
	/* chop off leading and trailing " */
/*
	string v = (*_value.find( key)).second;
	string t; 
	t.assign( v, 1, v.length() - 2 );
	return t;
*/
	return (*_value.find( key )).second;
}
