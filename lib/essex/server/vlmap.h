/******************************************************************************
 
 A valueless map, based on a hash.  This only stores keys; not values,
 so it is most useful for efficiently keeping track of the existence of keyed
 objects.

 Features:

 - key is parameter type (must be char, int, long, or short)
 - smart sizing and linear probing, based on optimal primes as described at
   http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
 - exists() provided.
 - resizing, both upwards and downwards

******************************************************************************/

#ifndef __VLMAP_H_
#define __VLMAP_H_

#include <iostream>
#include <cassert>
#include <vector>

#include <string.h>

#include "hash.h"

using namespace std;

// the vlmap class
// 
template <class KEYTYPE> class vlmap {
protected:

	/* data */

	KEYTYPE* _keys;
	
	KEYTYPE probe;		// linear probing increment

	KEYTYPE size;		// array size allocated for storage
	KEYTYPE size_idx;	// index of current size in hash primes table

	KEYTYPE filled;	// used cells in the array

	/* methods */

	KEYTYPE hash_func( int );	// the hash function
	
	// hash table position getter (w/probing).  _set = 1 if the goal is to 
	// set a value (changes behavior for vacated tombstones). basically
	// all of this fanciness enables us to avoid scanning the entire table 
	//
	KEYTYPE index_of( KEYTYPE _key, int _set);	

	void grow();			// grow the table up to the next level
	void shrink();			// shrink the table down to the next level
	
public:

	KEYTYPE index_of( KEYTYPE );	// this version assumes _set = 0

	// destructor-- free memory
	//
	~vlmap() { delete [] _keys; }

	// do-nothing constructor. just init to sane defaults.
	vlmap() :
		filled(0), size_idx(0) {  
			
		// init size stuff
		// 
		size = PRIMES[0];

		// initialize table array
		//
		init_table();	
		
		// initialize probe interval
		//
		probe = KEYTYPE(size/4) + 1;
	}
	
	// constructor without max or min size
	vlmap(KEYTYPE _startsize) : 
		filled(0) { 

		// init size stuff
		// 
		size_idx = nearest_prime_index(_startsize);
		size = PRIMES[size_idx];

		// initialize table arrays
		//
		//
		init_table();

		// initialize probe interval
		//
		probe = KEYTYPE(size/4) + 1;
	}

	// initialize the hash table arrays
	//
	void init_table() { 

		// allocate memory for key and value arrays
		//
		_keys = new KEYTYPE[size]; 

		// fill with default values
		//
		for (int i = 0; i < size; i++) {
			_keys[i] = -1;
		}
	}

	// set a key to taken
	int set( KEYTYPE );
		
	// remove an element by its id
	int remove( KEYTYPE );
	
	// remove an element by its table index
	int remove_real( KEYTYPE );

	// "real" array accessors for key and value. 
	//
	KEYTYPE key_real( KEYTYPE idx ) { assert(idx < size && idx >= 0); return _keys[idx]; }

	// see if a key exists
	//
	int exists( KEYTYPE key ) { return ( _keys[index_of(key)] >= 0); }

	// copy constructor. the only thing "tricky" this has to do is copy the
	// vectors.  all other variables carry straight over.
	vlmap& operator=(vlmap from) {

		// copy over simple member data
		//
		probe = from.probe;
		size = from.size;

		filled = from.filled;

		// copy table
		//
		delete [] _keys;
		_keys = new KEYTYPE[size];
		memcpy(_keys, from._keys, sizeof(KEYTYPE)*size);
	
		return *this;
	}

	// some useful accessors
	// 
	KEYTYPE get_size() { return size; }
	KEYTYPE get_filled() { return filled; }

	// get the capacity of the underlying vectors (same as get_size)
	//
	KEYTYPE get_capacity() { return size; }
};

/******************************************************************************
 
 (implementation)
  
******************************************************************************/

// the integer hash function.  uses knuth method.
//
template <class KEYTYPE>
KEYTYPE vlmap<KEYTYPE>::hash_func( int k ) {

	return (k * (k + 3)) % size;
}

// get the index of a key in the hash table, taking into account
// collisions. performs linear probing.
//
template <class KEYTYPE>
KEYTYPE vlmap<KEYTYPE>::index_of ( KEYTYPE _key ) {

	return index_of(_key, 0);	// this is only a "get" lookup
}

// actual implementation of above, with the following addition:
// if we are setting, we stop at vacated tombstones (-2) in addition to just
// tombstones (-1)
//
template <class KEYTYPE>
KEYTYPE vlmap<KEYTYPE>::index_of ( KEYTYPE _key, int set ) {

	// run the key through the hash function to get the starting index
	//
	KEYTYPE index = hash_func(_key);

	// increment while the current index is not free or does not have 
	// the given key stored at it
	//
	int attempts = 1;

	// our chaining depends on whether or not we are seeking to add a new 
	// element to the hash.
	//
	if (set) {
		int vacated = -1;
		while (_keys[index] != _key && _keys[index] != -1 && attempts < size) {

			// if we found a vacated spot, "bookmark" it
			if (_keys[index] == -2 && vacated == -1) vacated = index;

			// keep going
			index = (index + probe) % size;
			attempts++;
		}

		// if we didn't find the key but found a vacated position, use the 
		// vacated position.
		//
		if (attempts < size && _keys[index] < 0 && vacated != -1) {

			index = vacated;
		}

	} else {
		while (_keys[index] != _key && _keys[index] >= 0 && attempts < size) {
			index = (index + probe) % size;
			attempts++;
		}
	}

	// full hash table if this is false!
	assert(attempts <= size);

	return index;
}

// remove an entry from the hash vector by key
//
template <class KEYTYPE>
int vlmap<KEYTYPE>::remove ( KEYTYPE _key ) {
	
	KEYTYPE index = index_of(_key);

	return remove_real(index);
}

// remove an entry from the hash vector by its real table index
//
template <class KEYTYPE>
int vlmap<KEYTYPE>::remove_real ( KEYTYPE index ) {
	
	KEYTYPE key = _keys[index];

	// make sure something is here
	if (key >= 0) {

		// clear the spot
		//
		_keys[index] = -2;			// "vacated" tombstone
		
		// decrease filled count
		filled--;

		// check for table resize
		if (((float)filled/(float)size) < 0.25) {
			shrink();
		}

		return 1;
	}

	return 0;
}

// occupy a position in the lvintmap. return value is 1 if a position was empty.
// 
template <class KEYTYPE>
int vlmap<KEYTYPE>::set ( KEYTYPE _key ) {

	KEYTYPE index = index_of(_key, 1);
		
	KEYTYPE key = _keys[index];

	// if new spot, see if we should grow. (-1 or -2)
	// 
	if ( key < 0 ) { 
		
		// first mark this spot with our key
		_keys[index] = _key;

		// increase filled count
		filled++;

		// check for table resize
		//
		if (((float)filled/(float)size) > 0.75) {
		
			grow();

			// calculate a new index for returning ref
			index = index_of(_key);
		}

		return 1;
	} 
		
	return 0;
}

// grow the hash vector
//
template <class KEYTYPE>
void vlmap<KEYTYPE>::grow() {

	int size_idx = prime_index(size);

	// do nothing if there is no larger prime
	//
	if (PRIMES[size_idx+1] == 0) return;

	KEYTYPE nextsize = PRIMES[size_idx+1];

	// otherwise do the resize
	// 
	KEYTYPE old_size = size;
	size = nextsize;
	
	// make the current table the old one.  allocate a new one.
	//
	KEYTYPE* old_keys = _keys;

	init_table();

	// new probe interval
	//
	probe = KEYTYPE(size/4) + 1;

	// hash old keys into resized vector
	//
	for (int i = 0; i < old_size; i++) {
		
		if (old_keys[i] >= 0) {  // ignore all tombstoned entries
			KEYTYPE index = index_of(old_keys[i]);
			_keys[index] = old_keys[i];
		}
	}

	// free the old table arrays
	//
	delete [] old_keys;
}

// shrink the hash vector
// 
template <class KEYTYPE>
void vlmap<KEYTYPE>::shrink () {

	int size_idx = prime_index(size);

	// do nothing if there is no smaller prime
	//
	if (size_idx == 0) return;

	KEYTYPE nextsize = PRIMES[size_idx-1];

	// otherwise do the resize
	// 
	KEYTYPE old_size = size;
	size = nextsize;
	
	// save pointers to current table arrays. allocate new ones.
	//
	KEYTYPE* old_keys = _keys;

	init_table();

	// new probe interval
	//
	probe = KEYTYPE(size/4) + 1;

	// hash old keys into resized vector
	//
	for (int i = 0; i < old_size; i++) {
		
		if (old_keys[i] >= 0) {  // ignore all tombstoned entries
			KEYTYPE index = index_of(old_keys[i]);
			_keys[index] = old_keys[i];
		}
	}

	// free old table
	//
	delete [] old_keys;
}

#endif
