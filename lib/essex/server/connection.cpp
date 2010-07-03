#include <strstream>
#include <vector>

#include <sys/types.h>
#include <sys/socket.h>

#include "connection.h"

#define BUFFSIZE 4096

void connection::send_message( int code, string msg ) {
	char buf[BUFFSIZE+1] = {0};
	ostrstream os( buf, BUFFSIZE );
	os << code << " " << msg << endl;
	send( _s, buf, strlen( buf ), 0 );
}

vector<string> connection::get_response() {
	/* !todo: this is horrible, rewrite it */
	/* !todo: timeouts? */
	vector<string> r;
	string cur = "";
	char c;
	while( true ) {
		if( recv( _s, &c, sizeof( c ), 0 )<1 ) {
			// send message to the connection we dont have? HAH!
			//send_message( DEADCONN, "Connection died during read" );

			r.push_back(string("DISCON"));
			return r;

			//exit( 0 );
		}

		if( c=='\n' ) {
			if( cur.length() > 0 ) r.push_back( cur );
			return r;
		}

		if( isspace( c ) ) {
			if( cur.length() > 0 ) r.push_back( cur );
			cur = "";
		} else {
			cur.push_back( tolower( c ) );
		}
	}
}

string connection::get_line() {
	string r = "";
	char c;
	recv( _s, &c, sizeof( c ), 0 );
	while( c != '\n' ) {
		r.push_back( c );
		recv( _s, &c, sizeof( c ), 0 );
	}
	return r;
}

vector<string> connection::get_words() {
	vector<string> r;
	string t = get_line();
	while( t != "." ) {
		string cur = "";
		for( int i=0; i < t.length(); ++i ) {
			if( isspace( t[i] ) ) {
				if( cur!="" ) r.push_back( cur );
				cur = "";
			} else {
				cur.push_back( t[i] );
			}
		}
		if( cur!="" ) r.push_back( cur );
		t = get_line();
	}

	return r;
}

void connection::send_search_result(query_result result) {

	char buf[BUFFSIZE+1] = {0};

	// APK- change to use string (Rather than int) docId.  also change
	// to use tab separation of identifier string and weight, since we can
	// guarantee this is not in OAI identifiers
	//
	snprintf( buf, BUFFSIZE+1, "%s\t%f\n", result.docID.c_str(), result.sim );
	send( _s, buf, strlen( buf ), 0 );
}

vector<string> connection::get_index_IDs() {

	int idx;
	vector<string> q;
	for (idx=0; idx<2; idx++) {
		string r = "";
		char c;
		recv( _s, &c, sizeof( c ), 0 );
		while( c != '\n') {
			r.push_back( c );
			recv( _s, &c, sizeof( c ), 0 );
		}
		q.push_back(r);
	}
	return q;
}

string connection::get_unindex_ID() {

	string r = "";
	char c;
	recv( _s, &c, sizeof( c ), 0 );
	while( c != '\n') {
		r.push_back( c );
		recv( _s, &c, sizeof( c ), 0 );
	}
	return r;
}

// get the limit number for a limited search
//
int connection::get_limit() {

	return atoi(get_line().c_str());
}

// APK - rewritten to use Kevin's nice split routines, and a query formatted
// like :
//
// +tag1:term1 -tag2:term2 tag3:term3 term4 ...
//
vector<query_node> connection::get_query() {

	vector<query_node> r;
	vector<string> clauses; // query clauses (+/-tag:term) triplets
	int i;
	vector<string> clause;

	string t = get_line();
	
	// split into search clauses
	// 
	clauses = splitwhite(t);
	
	// parse each chunk into 
	for (i = 0; i < clauses.size(); i++) {
		
		string term = "";
		string tag = "";
		char qualifier = 0;
		query_node temp_node;

		clause = split(':', clauses[i]);
		
		// pull out qualifier
		//
		if (clause[0][0] == '+' || clause[0][0] == '-') {
		
			qualifier = clause[0][0];
			clause[0].erase(0, 1);		// remove first char
		}

		// no tag specified
		// 
		if (clause.size() == 1) {
		
			term = clause[0];
		} 
		
		// tag was specified
		//
		else {

			term = clause[1];
			tag = clause[0];
		}
		
		// add query node
		//
		temp_node.queryTerm = term;
		temp_node.elemName = tag;
		temp_node.qualifier = qualifier;

		r.push_back(temp_node);
	}

	return r;
}

