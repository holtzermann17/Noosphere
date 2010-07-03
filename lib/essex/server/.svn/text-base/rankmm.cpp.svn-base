/******************************************************************************
 
 A rank multimap.  Takes key values (0, 1.0] and can store more than one value
 per key (handy for storing search results with the same rank!)

 Features:

 - smart sizing and linear probing, based on optimal primes as described at
   http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
 - exists() and defined() calls, a-la perl
 - resizing, both upwards and downwards

******************************************************************************/

#include <iostream>
#include <cassert>
#include <vector>

#include <string.h>

#include "hash.h"
#include "rankmm.h"

#define absf(x) ((x)>0?(x):-(x))

// the hash function.  pretty simple considering our values are between 0
// and 1.
//
unsigned int rankmm::hash_func( float k ) {

	return (int)(k*(float)size) % size;
}

// get the index for a key
//
unsigned int rankmm::index_of ( float _key ) {

	// run the key through the hash function to get the starting index
	//
	unsigned int index = hash_func(_key);

	// increment while the current index is not free or does not have 
	// the given key stored at it
	//
	int attempts = 1;

	//while ( absf(_keys[index]-_key) >= 1.0/size && _keys[index] != -1 && attempts < size) {
	while ( _keys[index] != _key && _keys[index] != -1 && attempts < size) {
		index = (index + probe) % size;
		attempts++;
	}

	// full hash table if this is false!
	assert(attempts <= size);

	// keep track of lookup statistics
	//
	total_lookups++;
	total_attempts += attempts;

	return index;
}

// get a vector of docids for a rank key.  will be NULL if nothing there.
//
vector<int>* rankmm::get ( float _key ) {

	unsigned int index = index_of(_key);

	return _values[index];
}

// add a value to rank multimap 
// 
void rankmm::add ( float _key, int _val ) {

	unsigned int index = index_of(_key);
		
	float key = _keys[index];

	// add value, possibly allocating a new vector
	// 
	if (_values[index] == NULL) {
		_values[index] = new vector<int>(1, _val);
	}
	else {
		_values[index]->push_back(_val);
	}

	// if new spot, see if we should grow
	// 
	if ( key == -1 ) { 
		
		// first mark this spot with our key
		_keys[index] = _key;

		// increase filled count
		filled++;

		// check for table resize
		//
		if (((float)filled/(float)size) > 0.75) {
		
			grow();
		}
	} 
}

// grow the rank multimap
//
void rankmm::grow() {

	// do nothing if there is no larger prime
	//
	if (PRIMES[size_idx+1] == 0) return;

	unsigned int nextsize = PRIMES[size_idx+1];

	// do nothing if we've hit our size limit
	if (nextsize > maxsize) return;

	// otherwise do the resize
	// 
	size_idx++;
	unsigned int old_size = size;
	size = nextsize;
	
	// make the current table the old one.  allocate a new one.
	//
	float* old_keys = _keys;
	vector<int>** old_values = _values;

	init_table();

	// new probe interval
	//
	probe = int(size/4) + 1;

	// hash old keys and values into resized vector
	//
	for (int i = 0; i < old_size; i++) {
		
		if (old_keys[i] >= 0) {  // ignore all tombstoned entries
			unsigned int index = index_of(old_keys[i]);
			_keys[index] = old_keys[i];
			_values[index] = old_values[i];
		}
	}

	// unquote this to care about resizing overhead in efficiency stats
	//
	total_attempts += old_size; // at least this many ops in the copying
	total_lookups -= old_size;	// these aren't "external" lookups

	// free the old table arrays
	//
	delete [] old_keys;
	delete [] old_values;
}
