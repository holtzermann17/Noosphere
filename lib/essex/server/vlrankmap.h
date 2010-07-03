/******************************************************************************
 
 A valueless rank map, based on a hash.  This really is only useful for keeping
 track of whether or not we've seen a specific search engine similarity rank
 (a number between 0 and 1).

 Features:

 - key is float, assumed between 0 and 1 
 - smart sizing and linear probing, based on optimal primes as described at
   http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
 - exists() provided.
 - resizing upwards

******************************************************************************/

#ifndef __VLRANKMAP_H_
#define __VLRANKMAP_H_

#include <iostream>
#include <cassert>
#include <vector>

#include <string.h>

#include "hash.h"

using namespace std;

// the vlrankmap
// 
class vlrankmap {
protected:

	/* data */

	float* _keys;
	
	int probe;		// linear probing increment

	int size;		// array size allocated for storage
	int size_idx;	// index of current size in hash primes table

	int filled;		// used cells in the array

	/* methods */

	unsigned int hash_func( float );	// the hash function
	
	void grow();			// grow the table up to the next level
	
public:

	int index_of( float );	// get table index of a key

	// destructor-- free memory
	//
	~vlrankmap() { delete [] _keys; }

	// do-nothing constructor. just init to sane defaults.
	vlrankmap() :
		filled(0), size_idx(0) {  
			
		// init size stuff
		// 
		size = PRIMES[0];

		// initialize table array
		//
		init_table();	
		
		// initialize probe interval
		//
		probe = int(size/4) + 1;
	}
	
	// constructor without max or min size
	vlrankmap(int _startsize) : 
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
		probe = int(size/4) + 1;
	}

	// initialize the hash table arrays
	//
	void init_table() { 

		// allocate memory for key and value arrays
		//
		_keys = new float[size]; 

		// fill with default values
		//
		for (int i = 0; i < size; i++) {
			_keys[i] = -1;
		}
	}

	// set a key to taken
	void add( float );

	// get the list of ranks
	vector<float> get();
		
	// see if a key exists
	//
	int exists( float key ) { return ( _keys[index_of(key)] >= 0); }

	// some useful accessors
	// 
	int get_size() { return size; }
	int get_filled() { return filled; }

	// get the capacity of the underlying vectors (same as get_size)
	//
	int get_capacity() { return size; }
};

#endif
