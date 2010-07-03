#ifndef __STEM_H__
#define __STEM_H__

#include <string>
#include <vector>
#include <iostream>		//MG
#include <fstream>

#include "global.h"		//MG
#include "stringstring_hash.h"

using namespace std;

string const EMPTY = "!!!";
const int A_ASCII = 65;
const int z_ASCII = 122;
/*
 * stemmer: stem and stop words
 * the stemmer class will cache past results
 *
 * much of this code is adapted from Hussein Suleman's Perl stemmer
 */
class stemmer : public stringstring_hash {
	private:
		/*the following gives an "illegal pure syntax" error*/
		//static int const TERM_HASH_SIZE = 1000;

		//static string const STOP =
		//	"a has same about have several among however some all such an and are if as in than at into that is the it their its these be they been this between those both made through but make to by many toward more most must do upon during used using no not each was either were of what on which or while for who found will from with further within would i";

		vector<string> _values;

		bool isvowel( char c );
		string vowelize( string );
		bool suffix( string const &word, string const &suffix );
		bool isLetter(char);
		string removePunc(string);

		int porterm( string word );

	public:
		stemmer(); 

		/* stem and stop a word. if add is 1, new words are added to cache */
		string stem_and_stop( string word, int add );

		/* same as above but assumes add = 1 */
		string stem_and_stop( string word );

		/*
		void print();		//MG
		int writeDisk(int, fstream&);	//MG
		int readDisk(int, fstream&);	//MG
		*/
};

#endif
