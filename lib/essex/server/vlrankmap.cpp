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

#include "vlrankmap.h"

// hash function, optimized for float ranks.
//
unsigned int vlrankmap::hash_func( float k ) {

	return (int)(k*(float)size) % size;
}

// get the table index of a rank
//
int vlrankmap::index_of ( float _key ) {

	// run the key through the hash function to get the starting index
	//
	int index = hash_func(_key);

	// increment while the current index is not free or does not have 
	// the given key stored at it
	//
	int attempts = 1;

	while (_keys[index] != _key && _keys[index] != -1 && attempts < size) {
		index = (index + probe) % size;
		attempts++;
	}

	// full hash table if this is false!
	assert(attempts <= size);

	return index;
}

// get the list of set ranks 
//
vector<float> vlrankmap::get () {
	
	vector<float> setkeys;

	for (int i = 0; i < size; i++) {
		if (_keys[i] >= 0) {
			setkeys.push_back(_keys[i]);
		}
	}

	return setkeys;
}

// occupy a position in the rank map
// 
void vlrankmap::add ( float _key ) {

	int index = index_of(_key);
		
	float key = _keys[index];

	// if new spot, see if we should grow. 
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

// grow the map
//
void vlrankmap::grow() {

	int size_idx = prime_index(size);

	// do nothing if there is no larger prime
	//
	if (PRIMES[size_idx+1] == 0) return;

	int nextsize = PRIMES[size_idx+1];

	// otherwise do the resize
	// 
	int old_size = size;
	size = nextsize;
	
	// make the current table the old one.  allocate a new one.
	//
	float* old_keys = _keys;

	init_table();

	// new probe interval
	//
	probe = int(size/4) + 1;

	// hash old keys into resized vector
	//
	for (int i = 0; i < old_size; i++) {
		
		if (old_keys[i] >= 0) {  // ignore all tombstoned entries
			int index = index_of(old_keys[i]);
			_keys[index] = old_keys[i];
		}
	}

	// free the old table arrays
	//
	delete [] old_keys;
}
