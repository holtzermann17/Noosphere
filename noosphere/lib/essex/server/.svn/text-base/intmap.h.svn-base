/******************************************************************************
 
 A hashed associative array.  This version is integer-keyed and hence looks 
 like a vector to the outside world.

 Features:

 - values are templated and hence generic
 - smart sizing and linear probing, based on optimal primes as described at
   http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
 - comes with iterator
 - exists() and defined() calls, a-la perl
 - resizing, both upwards and downwards

******************************************************************************/

#ifndef __INTMAP_H_ 
#define __INTMAP_H_ 

#include <iostream>
#include <cassert>
#include <vector>

#include <string.h>

#include "hash.h"

using namespace std;

// the intmap class
// 
template <class _Tp> class intmap {
protected:
	int* _keys;
	_Tp* _values;
	
	unsigned int probe;		// linear probing increment

	unsigned int size;		// array size allocated for storage
	unsigned int size_idx;	// index of current size in hash primes table
	unsigned int minsize;	// min and max array size
	unsigned int maxsize;				

	unsigned int filled;	// used cells in the array

	_Tp undef_val;			// value of template type to return for undefined
							// index value.

	unsigned int total_lookups;
	unsigned int total_attempts;
	
	unsigned int hash_func( int );	// the hash function
	
	// hash table position getter (w/probing).  _set = 1 if the goal is to 
	// set a value (changes behavior for vacated tombstones). basically
	// all of this fanciness enables us to avoid scanning the entire table 
	//
	unsigned int index_of( int _key, int _set);	

	void grow();			// grow the table up to the next level
	void shrink();			// shrink the table down to the next level
	
public:

	unsigned int index_of( int );	// this version assumes _set = 0

	// an iterator
	//
	class iterator {

	protected:

		// container we are connected to
		intmap<_Tp>* parent;

		int index;	// index into the intmap

		// increment index to next populated hash entry (or end)
		void increment() {
			if (!parent) return;
	
			if (index == parent->last_index())
				index++;
			else 
				for (int key = -1; index < parent->last_index() && key < 0; ++index, key = parent->key_real(index));
		}
				
		// decrement index to next populated hash entry (stops at begin)
		void decrement () {

			if (!parent) return;

			int i = index;
			for (int key = -1; i > 0 && key < 0; --i, key = parent->key_real(i));
			// only change index if stopping point is populated.
			if (key_real(i) >= 0) {
				index = i;
			}
		}
				
		
	public:

		// constructors
		iterator() : parent(NULL), index(0) {}	
		iterator(int _index) : parent(NULL), index(_index) {}	
		iterator(intmap<_Tp>* _parent) : parent(_parent), index(0) {}
		iterator(intmap<_Tp>* _parent, int _index) : parent(_parent), index(_index) {}

		// iterator scan operations
		void operator+=(int _n) { for (int i = 0; i < _n; i++) increment(); }
		void operator-=(int _n) { for (int i = 0; i < _n; i--) decrement(); }
		void operator--() { decrement(); }
		void operator--(int) { decrement(); }
		void operator++() { increment(); }
		void operator++(int) { increment(); }
		
		// comparisons
		int operator==(const intmap<_Tp>::iterator& a) { return index == a.index; }
		int operator!=(const intmap<_Tp>::iterator& a) { return index != a.index; }
		int operator<(const intmap<_Tp>::iterator& a) { return index < a.index; }
		int operator>(const intmap<_Tp>::iterator& a) { return index > a.index; }
		int operator<=(const intmap<_Tp>::iterator& a) { return index <= a.index; }
		int operator>=(const intmap<_Tp>::iterator& a) { return index >= a.index; }
		int operator==(int _index) { return index == _index; }
		int operator!=(int _index) { return index != _index; }
		int operator<(int _index) { return index < _index; }
		int operator>(int _index) { return index > _index; }
		int operator<=(int _index) { return index <= _index; }
		int operator>=(int _index) { return index >= _index; }

		// value reference (retrieve value from parent class at this pos)
		_Tp& operator*() {
			return parent->value_real(index);
		}

		// get the key of the current index (or -1)
		int get_key() {
			int key = parent->key_real(index);

			if (key >= 0) return key;

			return -1;
		}

		// copy
		void operator=(const intmap<_Tp>::iterator& a) { 
			index = a.index; 
			parent = a.parent;
		}

		// misc
		void set_parent(intmap<_Tp>* _parent) { parent = _parent; }

		// reveal the internal index
		int get_index() { return index; }

	};

	/* iterator ENDS */

	friend class iterator; // iterators can see our privates

	// destructor-- free memory
	//
	~intmap() { delete [] _keys; delete [] _values; }

	// almost do-nothing constructor. just init to sane defaults.
	intmap(_Tp _undef_val) :
		//_keys(PRIMES[0], -1),				
		//_values(PRIMES[0], _undef_val),
		size_idx(0),
		minsize(PRIMES[0]),
		maxsize(PRIMES[MAX_PRIME_IDX]),
		undef_val(_undef_val),
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
	intmap(int _startsize, _Tp _undef_val) : 
		//_keys(0, -1),				
		//_values(0 , _undef_val),
		minsize(PRIMES[0]),
		maxsize(PRIMES[MAX_PRIME_IDX]),
		undef_val(_undef_val),
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
	intmap(int _minsize, int _maxsize, int _startsize, _Tp _undef_val) : 
		//_keys(0, -1),				
		//_values(0 , _undef_val),
		minsize(_minsize),
		maxsize(_maxsize),
		undef_val(_undef_val),
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
		_keys = new int[size]; 
		_values = new _Tp[size];

		// fill with default values
		// TODO: optimize this with doubling memcpy?
		//
		for (int i = 0; i < size; i++) {
			_keys[i] = -1;
			_values[i] = undef_val;
		}
	}
		
	// get the value at an integer key index. 
	//
	_Tp& get( int );		

	_Tp& set( int, _Tp ); 	// set the value at an integer key index

	// remove an element by its id, and return it (or undef)
	_Tp remove( int );
	
	// remove an element by its table index, and return it (or undef)
	_Tp remove_real( int );

	// remove an element pointed to by iterator. 
	_Tp remove( intmap<_Tp>::iterator );

	// "real" array accessors for key and value. 
	//
	int key_real( int idx ) { assert(idx < size && idx >= 0); return _keys[idx]; }
	_Tp& value_real( int idx ) { assert(idx < size && idx >= 0); return _values[idx]; }

	// see if a key exists
	//
	int exists( int key ) { return ( _keys[index_of(key)] >= 0); }

	// see if a value exists
	//
	int defined( int key ) { return (exists(key) && (_values[index_of(key)] != undef_val)); }

	// get the value at an integer key index.  actually, this gets a value 
	// ref, and even more importantly, if you try to get a non-existant 
	// location, it will be created and set to _undef_val! this allows you to
	// do things like map[new_key] = blah instead of calling set() !!
	//
	_Tp& operator[]( int );	// takes index, returns template object type

	// copy constructor
	//
	intmap(const intmap<_Tp>& from) {

		// copy over simple member data
		//
		probe = from.probe;
		size = from.size;
		size_idx = from.size_idx;
		minsize = from.minsize;
		maxsize = from.maxsize;

		filled = from.filled;
		undef_val = from.undef_val;

		// start efficiency off anew
		// 
		total_lookups = 0;
		total_attempts = 0;

		// copy table
		//
		_keys = new int[size];
		_values = new _Tp[size];
		memcpy(_keys, from._keys, sizeof(int)*size);
		memcpy(_values, from._values, sizeof(_Tp)*size);
	}

	// the only thing "tricky" this has to do is copy the vectors.  all other
	// variables carry straight over.
	intmap<_Tp>& operator=(intmap<_Tp> from) {

		// copy over simple member data
		//
		probe = from.probe;
		size = from.size;
		size_idx = from.size_idx;
		minsize = from.minsize;
		maxsize = from.maxsize;

		filled = from.filled;
		undef_val = from.undef_val;

		// start efficiency off anew
		// 
		total_lookups = 0;
		total_attempts = 0;

		// copy table
		//
		delete [] _keys;
		_keys = new int[size];
		delete [] _values;
		_values = new _Tp[size];

		memcpy(_keys, from._keys, sizeof(int)*size);
		memcpy(_values, from._values, sizeof(_Tp)*size);
	
		return *this;
	}

	// some useful accessors
	// 
	int get_size() { return size; }
	int get_filled() { return filled; }

	// get the capacity of the underlying vectors
	// APK 2003-03-28 : vectors gone, now actual mem usage is size.
	//
	int get_capacity() { return size; }

    // first and last occupied indices.  the iterator makes use of this.
	//
	int first_index();
	int last_index();

	// see how efficient this intmap is. optimal return value is 1. if you 
	// have properly initialized the size, then you should get a value 
	// somehere around 1.7.
	//
	float get_efficiency() {
		if (total_lookups) {
			return ((float)total_attempts/(float)total_lookups); 
		}

		return 1;
	}

	/* iterator accessors */

	intmap<_Tp>::iterator begin();
	intmap<_Tp>::iterator end();
};

// find the first occupied index (or 0 if none)
//
template <class _Tp> 
int intmap<_Tp>::first_index( ) {

	if (filled > 0) {
		for (int i = 0; i < size; i++) 
			if (_keys[i] >= 0) return i;

	}
		
	return 0;
}

// find the last occupied index (or 0 if none)
//
template <class _Tp> 
int intmap<_Tp>::last_index( ) {

	if (filled > 0) {
		for (int i = size - 1; i > 0; i--)
			if (_keys[i] >= 0) return i;
	}
		
	return 0;
}

// return a begin iterator
//
template <class _Tp> 
typename intmap<_Tp>::iterator intmap<_Tp>::begin( ) {
	
	if (filled == 0) {
		return intmap<_Tp>::iterator(this, -1);
	} else {
		return intmap<_Tp>::iterator(this, first_index());
	}
}

// return an end iterator
//
template <class _Tp> 
typename intmap<_Tp>::iterator intmap<_Tp>::end( ) {
	
	if (filled == 0) {
		return intmap<_Tp>::iterator(this, -1);
	} else {
		return intmap<_Tp>::iterator(this, last_index() + 1);
	}
}

// the integer hash function.  uses knuth method.
//
template <class _Tp>
unsigned int intmap<_Tp>::hash_func( int k ) {

	return (k * (k + 3)) % size;
}

// get the index of a key in the hash table, taking into account
// collisions. performs linear probing.
//
template <class _Tp> 
unsigned int intmap<_Tp>::index_of ( int _key ) {

	return index_of(_key, 0);	// this is only a "get" lookup
}

// actual implementation of above, with the following addition:
// if we are setting, we stop at vacated tombstones (-2) in addition to just
// tombstones (-1)
//
template <class _Tp> 
unsigned int intmap<_Tp>::index_of ( int _key, int set ) {

	// run the key through the hash function to get the starting index
	//
	unsigned int index = hash_func(_key);

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
		while (_keys[index] != _key && _keys[index] != -1 && attempts < size) {
			index = (index + probe) % size;
			attempts++;
		}
	}

	// full hash table if this is false!
	assert(attempts <= size);

	// keep track of lookup statistics
	//
	total_lookups++;
	total_attempts += attempts;

	return index;
}

// get a value from the hash vector.  returns the _Tp-typed undef value for 
// keys which are not found. 
//
template <class _Tp>
_Tp& intmap<_Tp>::get ( int _key ) {

	unsigned int index = index_of(_key);

	return _values[index];
}

// like the above, except does a set() to undef if the key doesn't exist.
//
template <class _Tp>
_Tp& intmap<_Tp>::operator[]( int _key ) {

	unsigned int index = index_of(_key);

	// if the position is empty, do a set.  if you want to avoid this, you
	// will have to use get() or call exists() before using the [] accessor.
	//
	if (_keys[index] < 0) {

		// have to do this return because set() could put the value in a
		// different index than index (due to resizing or a VACANT spot) and
		// so we need to return a ref of the value at this possibly different
		// index
		//
		return set(_key, undef_val);
	}

	return _values[index];
}

// remove an entry from the hash vector by key
//
template <class _Tp>
_Tp intmap<_Tp>::remove ( int _key ) {
	
	unsigned int index = index_of(_key);

	return remove_real(index);
}

// remove an entry from the hash vector by its real table index
//
template <class _Tp>
_Tp intmap<_Tp>::remove_real ( int index ) {
	
	int key = _keys[index];
	_Tp value = undef_val;

	// make sure something is here
	if (key >= 0) {

		// grab the value
		value = _values[index];
	
		// clear the spot
		//
		_values[index] = undef_val;
		_keys[index] = -2;			// "vacated" tombstone

		// decrease filled count
		filled--;

		// check for table resize
		if (((float)filled/(float)size) < 0.25) {
			shrink();

			// calculate a new index for returning ref
			index = index_of(key);
		}
	}

	return value;
}

// set a value in the hash vector
// 
template <class _Tp>
_Tp& intmap<_Tp>::set ( int _key, _Tp _val ) {

	unsigned int index = index_of(_key, 1);
		
	int key = _keys[index];

	// overwrite old value
	// 
	_values[index] = _val;

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
	} 
		
	return _values[index];
}

// grow the hash vector
//
template <class _Tp>
void intmap<_Tp>::grow() {

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
	int* old_keys = _keys;
	_Tp* old_values = _values;

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

// shrink the hash vector
// 
template <class _Tp> 
void intmap<_Tp>::shrink () {

	// do nothing if there is no smaller prime
	//
	if (size_idx == 0) return;

	unsigned int nextsize = PRIMES[size_idx-1];

	// do nothing if we've hit our size limit
	if (nextsize < minsize) return;

	// otherwise do the resize
	// 
	size_idx--;
	unsigned int old_size = size;
	size = nextsize;
	
	// save pointers to current table arrays. allocate new ones.
	//
	int* old_keys = _keys;
	_Tp* old_values = _values;

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

	// free old tables
	//
	delete [] old_keys;
	delete [] old_values;
}



#endif
