/******************************************************************************
 
 An associative map keyed by strings and with string values (albeit, only 
 pointed to here).

 ChangeLog

 - some bug fixes in remove(), persistence removed by Aaron Krowne, spring '03
 - persistence and slight modifications by Matt Gracey fall '02
 - originally written summer '02 by Kevin Fergusen

******************************************************************************/
 
#ifndef STRINGSTRING_HASH_H 
#define STRINGSTRING_HASH_H 

#include <cassert>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>

using namespace std;

class stringstring_hash {

protected:
	vector<string> _keys;
	vector<string>* values_ptr;
	
	int capacity;			// size allocated for storage
	int size;				// used cells in the array
	int hash_func( string );

public:
	int index_of( string );

	stringstring_hash(int table_size, vector<string>* _v_ptr ) : 
				  _keys( table_size, "" ), 
				  size(0), 
				  capacity(table_size), 
				  values_ptr(_v_ptr) { } 

	vector<string> get_keys() {return _keys;}
	void resize_up();
	void resize_down();
	int remove_key(string);
	int get_size() {return size;}
	int get_capacity() {return capacity;}

	/*
	int writeHash(int, fstream&);
	int readHash(int, fstream&);
	*/
};

#endif
