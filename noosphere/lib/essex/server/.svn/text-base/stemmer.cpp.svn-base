#include <cctype>
#include <strstream>

#include "stemmer.h"

using namespace std;

vector<string> split( string list, char delim ) {
	vector<string> r;
	string cur = "";

	for( int i=0; i < list.length(); ++i ) {
		if( list[i]==delim ) {
			r.push_back( cur );
			cur = "";
		} else cur+=( list[i] );
	}
	r.push_back( cur );

	return r;
}

stemmer::stemmer() :
	stringstring_hash( STEM_HASH_SIZE, &_values ),
	_values( STEM_HASH_SIZE, EMPTY ) {
		//vector<string> stopwords = split( "a has same about have several among however some all such an and are if as in than at into that is the it their its these be they been this between those both made through but make to by many toward more most must do upon during used using no not each was either were of what on which or while for who found will from with further within would i", ' ' );
		vector<string> stopwords = split( "a about above according accordingly across actual added after against ahead all almost alone along already also although among amongst an and and-or and/or anon another any anyone apparently are arise as asaside at award away be became because become becomes been before behind being below best better between beyond birthday both briefly but by came can cannot certain certainly come comes coming completely concerning consider considered considering consisting could de department der despite did different discussion do does doesn't doing done down dr du due during each either else enough especially et etc ever every few following for forward found from further gave get gets give given gives giving gone got had hardly has have having here his honor how however i if immediately in inside instead into is it items its itself just keep kept largely let lets like little look looks made mainly make makes making many meet meets might more most mostly much mug must my near nearly necessarily next no none nor nos not noted now obtain obtained of off often on only onto or other ought our out outside over overall owing particularly past per perhaps please possibly predominantly present previously probably prompt promptly pt put quite rather ready really regarding regardless relatively reprinted respectively said same seem seen several shall should show showed shown shows similarly since slightly so so-called some sometime sometimes somewhat soon spp strongly studies study substantially successfully such take taken takes taking than that the their theirs them then there therefore therefrom these they this those though through throughout thus to together too toward towards under undergoing unless until up upon upward used usefully using usually various versus very via vol vols vs was way ways we were what whats when where whether which while whither who whom whos whose why widely will with within without would", ' ' );

		for( int i=0; i < stopwords.size(); ++i )
			_values[index_of(stopwords[i])] = "";
}

bool stemmer::isvowel( char c ) {
	return c=='a'||c=='e'||c=='i'||c=='o'||c=='u';
}

string stemmer::vowelize( string word ) {
	// aeiou are vowels
	// y preceded by a consonant is considered a vowel
	for( int i=0; i < word.length(); ++i ) {
		if( isvowel( word[i] ) ) word[i] = 'v';
		else if( word[i]=='y' && i>0 ) {
			if( word[i-1]=='v' ) word[i] = 'c';
			else word[i] = 'v';
		} else word[i] = 'c'; 
	}

	return word;
}

bool stemmer::isLetter(char c) {
	return (toascii(c)>=A_ASCII && toascii(c)<=z_ASCII);
}

//MG - removes any punctuation that may have been grabbed
string stemmer::removePunc(string word) {
	string r="";

	int idx;
	for (idx=0; idx<word.length(); idx++) {
		if (isLetter(word[idx]))
			r+=word[idx];
	}
	return r;
}

bool stemmer::suffix( string const &word, string const &suffix ) {
	if( suffix.length() > word.length() ) return false;
	for( int i=1; i <= suffix.length(); ++i )
		if( word[word.length()-i] != suffix[suffix.length()-i] )
			return false;
	return true;
}

// count the vowel-consonant transitions in a word 
int stemmer::porterm( string word ) {
	if( word.length() < 1 ) return 0;

	int c = 0;

	word = vowelize( word );
	bool vowel = word[0]=='v';
	bool next;

	for( int i=1; i < word.length(); ++i ) {
		next = word[i]=='v';
		if( vowel && !next ) ++c;
		vowel = next;
	}

	return c;
}

string stemmer::stem_and_stop( string word, int add ) {
	for( int i = 0; i < word.length(); ++i )
		word[i] = tolower( word[i] );

	word = removePunc(word);
	if (word.length() == 0)
		return word;

	// APK - cache this
	string original_word = word;

	int pos = index_of(word);

	// "!!!" is used to indicate an empty slot, since "" is a valid
	// output
	if( _values[pos] == EMPTY && add == 1 ) {
		// step 1A: remove common plural suffices
		vector<string> suffices = split( "sses,ies,ss,','s,s", ',' );
		vector<string> replace = split( "ss,i,ss,,,", ',' );

		for( int i = 0; i < suffices.size(); ++i )
			if( suffix( word, suffices[i] ) ) {
				string t = word;
				t.resize( t.length() - suffices[i].length() );
				t += replace[i];
				word = t;
				//word.replace( word.length() - suffices[i].length(), replace[i].length(), replace[i] );
				break;
			}

		// step 1B: remove the suffices 'eed', 'ing', and 'ed'
		bool secondorthird = false;
		if( suffix( word, "eed" ) ) {
			string t = word;
			t.resize( t.length() - 3 );
			if( porterm( t ) > 0 ) word = t + "ee";
		} else if( suffix( word, "ing" ) ) {
			string t = word;
			t.resize( t.length() - 3 );
			string vowels = vowelize( word );
			for( int i=0; i < vowels.length() && !secondorthird; ++i )
				if( vowels[i]=='v' ) {
					word = t;
					secondorthird = true;
				}
		} else if( suffix( word, "ed" ) ) {
			string t = word;
			t.resize( t.length() - 2 );
			string vowels = vowelize( word );
			for( int i=0; i < vowels.length() && !secondorthird; ++i )
				if( vowels[i]=='v' ) {
					word = t;
					secondorthird = true;
				}
		}
		// then fix words that drop a slient 'e' (e.g. abate -> abating)
		if( secondorthird ) {
			if( suffix( word, "at" ) ) word += "e";
			else if( suffix( word, "bl" ) ) word += "e";
			else if( suffix( word, "iz" ) ) word += "e";
			else if( false ) {
				// the perl here is $aword =~ /((?<=[aeiou])y|[^aeioulsz]){2}$/
				word.resize( word.length() - 1 );
			} else if( (porterm( word )==1) && false ) {
				// ($aword =~ /((?<=[aeiou])y|[^aeiou])((?<=[^aeiou])y|[aeiou])([^aeiouwxy])$/
				word += "e";
			}
		}

		// step 1C: replace final 'y' with 'i', if appropriate
		if( suffix( word, "y" ) ) {
			string t = word;
			t.resize( t.length() - 1 );
			string vowels = vowelize( t );
			for( int i=0; i < vowels.length(); ++i )
				if( vowels[i] = 'v' ) {
					word = t + "i";
					break;
				}
		}

		// determine if we should use stemmed or original.  the criteria is 
		// that if a word is stemmed to less than half of its original size, 
		// we leave it alone. 
		if ( ((float)word.length()/(float)original_word.length()) < 0.5) {
			_values[pos] = original_word;
		} else {
			return _values[pos] = word;
		}
	}

	return _values[pos];
}

/* calls the above, but assumes add = 1 */
string stemmer::stem_and_stop( string word) {

	return stem_and_stop(word, 1);
}

/*
void stemmer::print() {

	int idx;
	for (idx=0; idx<TERM_HASH_SIZE; idx++) 
		if (_keys[idx] != "") 
			cout << "stemmer:_keys[" << idx << "] = " << _keys[idx] << ", stemmer::_values[" 
			     << idx << "] = " << _values[idx] << "\n";
}


int stemmer::writeDisk(int start_pos, fstream& file) {

	//first, write out string_hash member
	int new_start = writeHash(start_pos, file);

	char buf[20];
	char* dum = new char[capacity*sizeof(string)];
	char* temp;
	char* pos = dum;
	int word_size = 0;

	int idx;
	for (idx=0; idx<capacity; idx++) {
		
		temp = (char*)_values[idx].c_str();		//read in string at from[idx]
		//count letters in string	
		int word_size;
		for (word_size=0; temp[word_size]!='\0'; word_size++) {}
		word_size++;			//for null_char

		memcpy((void*)pos, (void*)temp, word_size);		//add word to buffer
		pos+=word_size;

	}
	
	int file_size=pos-dum;

	//find starting point in file
	file.seekp(new_start);

	//write the number of bytes in the buffer
	file.write((char*)_itoa(file_size, buf, 10), sizeof(string));

	//write the contents
	file.write((char*)dum, file_size);

	//return the new position at which to begin writing
	return new_start+file_size+(2*sizeof(string));
}

int stemmer::readDisk(int start_pos, fstream& file) {

	//first, read in string_hash portion
	int new_start = readHash(start_pos, file);

	char* temp;
	char buf[20];
	int file_size=0;
	
	file.seekg(new_start);				//find start of entry

	file.read((char*)buf, sizeof(string));		//read file_size in as a string
	file_size=atoi(buf);				//convert to int

	//make buffer to store data
	char* dum = new char[file_size];
	char* pos = dum;

	file.read(dum, file_size);			//read in data to dum

	int idx;
	for (idx=0; idx<capacity; idx++) {
	
		int word_size;
		for (word_size=0; *(pos+word_size)!='\0'; word_size++) {}	//count letters in this word
		word_size++;				//to count null_char

		char* word_buf = new char[word_size];			
		memcpy((void*)word_buf, (void*)pos, word_size);	//copy word into word_buf
		_values[idx]=(string)word_buf;		//add to to
				
		pos+=(word_size);		//increment pos, ignore null_char

	}

	//return point at which the next entry begins
	return new_start+file_size+(2*sizeof(string));	
}

*/
