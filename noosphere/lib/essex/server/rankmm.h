/******************************************************************************
 
 A rank multimap.  Takes key values (0, 1.0] and can store more than one value
 per key (handy for storing search results with the same rank!)

 Features:

 - smart sizing and linear probing, based on optimal primes as described at
   http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
 - exists() and defined() calls, a-la perl
 - resizing, both upwards and downwards

******************************************************************************/

#ifndef __RANKMM_H_ 
#define __RANKMM_H_ 

#include <iostream>
#include <cassert>
#include <vector>

#include <string.h>

#include "hash.h"

using namespace std;

// the rank multimap class
// 
class rankmm {
protected:
	float* _keys;
	vector<int>** _values;
	
	unsigned int probe;		// linear probing increment

	unsigned int size;		// array size allocated for storage
	unsigned int size_idx;	// index of current size in hash primes table
	unsigned int minsize;	// min and max array size
	unsigned int maxsize;				

	unsigned int filled;	// used cells in the array

	unsigned int total_lookups;
	unsigned int total_attempts;
	
	unsigned int hash_func( float );	// the hash function
	
	void grow();			// grow the table up to the next level
	void shrink();			// shrink the table down to the next level
	
public:

	// return the index of a rank key in the table
	//
	unsigned int index_of( float );	

	// destructor-- free memory
	//
	~rankmm() { 

		// free vectors
		for (int i = 0; i < filled; i++) {
			if (_values[i]) delete _values[i];
		}
		
		delete [] _keys; 
		delete [] _values; 
	}

	// zero-info constructor. just init to sane defaults.
	rankmm() :
		size_idx(0),
		minsize(PRIMES[0]),
		maxsize(PRIMES[MAX_PRIME_IDX]),
		filled(0),
		total_attempts(0),
		total_lookups(0) {  
			
		// init size stuff
		// 
		size = PRIMES[size_idx];

		// initialize table arrays
		//
		init_table();	
		
		// initialize probe interval
		//
		probe = int(size/4) + 1;
	}
	
	// constructor without max or min size
	rankmm(int _startsize) : 
		minsize(PRIMES[0]),
		maxsize(PRIMES[MAX_PRIME_IDX]),
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

		// init statistics stuff
		//
		total_attempts = 0;
		total_lookups = 0;
	}

	// full constructor
	rankmm(int _minsize, int _maxsize, int _startsize) : 
		minsize(_minsize),
		maxsize(_maxsize),
		filled(0) { 

		// init size stuff
		// 
		size_idx = nearest_prime_index(_startsize);
		size = PRIMES[size_idx];

		// init tables arrays
		//
		init_table();

		// initialize probe interval
		//
		probe = int(size/4) + 1;

		// init statistics stuff
		//
		total_attempts = 0;
		total_lookups = 0;
	}

	// initialize the hash table arrays
	//
	void init_table() { 

		// allocate memory for key and value arrays
		//
		_keys = new float[size]; 
		_values = new vector<int>*[size];

		// fill with default values
		// TODO: optimize this with doubling memcpy?
		//
		for (int i = 0; i < size; i++) {
			_keys[i] = -1;
			_values[i] = NULL;
		}
	}
		
	// get the vector of ids for a rank (or null)
	//
	vector<int>* get( float );		

	// add a docid at a rank
	void add( float _rank, int _docid ); 	

	// see if a key exists
	//
	int exists( float key ) { return ( _keys[index_of(key)] >= 0); }

	// see if a vector is defined for a key (this should always be true)
	//
	int defined( float key ) { return (exists(key) && (_values[index_of(key)] != NULL)); }

	// get the value at an rank.   same as get.
	//
	vector<int>* operator[]( float _key ) { return get(_key); }

	// some useful accessors
	// 
	int get_capacity() { return size; }
	int get_size() { return size; }
	int get_filled() { return filled; }

	// see how efficient this rankmm is. optimal return value is 1. if you 
	// have properly initialized the size, then you should get a value 
	// somehere around 1.7.
	//
	float get_efficiency() {
		if (total_lookups) {
			return ((float)total_attempts/(float)total_lookups); 
		}

		return 1;
	}
};

#endif
