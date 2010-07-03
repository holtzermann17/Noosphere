/*
 * util.cpp - random utility functions
 */

#include <cctype>
#include "util.h"

using namespace std;

// split a list of terms based on certain separators
//
vector<string> split_for_indexing ( vector<string> &inlist ) {

	char splitchars[] = {'-', ',', 0};

	vector <string> outlist = inlist;
	vector <string> temp;

	int i, c, j;

	// loop through chars we will split terms on
	//
	for (c = 0; splitchars[c] != 0; c++) {

		char thischar = splitchars[c];

		// loop through the list of terms
		//
		for (i = 0; i < outlist.size(); i++) {
		
			temp = split(thischar, outlist[i]);	

			// erase the current string and replace it with split strings if
			// a split occurred.
			//
			if (temp.size() > 1) {
				outlist.erase(outlist.begin() + i);
				outlist.insert(outlist.begin() + i, temp.begin(), temp.end());

				// dont re-process added elements
				i += temp.size() - 1;
			}
		}
	}

	return outlist;
}

// do the above, but for a single string (wraps it in a vector)
//
vector<string> split_for_indexing ( string const &s ) {

	vector<string> vec;

	vec.push_back(s);

	return split_for_indexing(vec);
}

vector<string> split( char c, string const &s ) {
	bool quote = false;
	vector<string> r;
	string t = "";
	for( int i=0; i < s.length(); ++i ) {
		if( quote ) {
			if( s[i]=='"' ) quote = false;
			else t.push_back( s[i] );
		} else {
			if( s[i]=='"' ) quote = true;
			else if( s[i]==c ) {
				r.push_back( t );
				t = "";
			} else {
				t.push_back( s[i] );
			}
		}
	}
	r.push_back( t );

	return r;
}

vector<string> splitwhite( string const &s ) {
	bool quote = false;
	vector<string> r;
	string t = "";

	for( int i=0; i < s.length(); ++i ) {
		if( quote ) {
			if( s[i]=='"' ) quote = false;
			else t.push_back( s[i] );
		} else {
			if( s[i]=='"' ) quote = true;
			else if( isspace( s[i] ) ) {
				if( t.length() > 0 ) r.push_back( t );
				t = "";
			} else t.push_back( s[i] );
		}
	}
	if( t.length() > 0 )
		r.push_back( t );

	return r;
}
