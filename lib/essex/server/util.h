/*
 * util.h - random utility fucntions
 */

#include <string>
#include <vector>

using namespace std;

vector<string> split_for_indexing( vector<string> &inlist );
vector<string> split_for_indexing ( string const &s );
vector<string> split( char c, string const &s );
vector<string> splitwhite( string const &s );
