/******************************************************************************
 
 A hashed associative array.  This version is string-keyed.

 Features:

 - values are templated and hence generic
 - smart sizing and linear probing, based on optimal primes as described at
   http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
 - comes with iterator
 - exists() and defined() calls, a-la perl
 - resizing, both upwards and downwards

******************************************************************************/

#ifndef _STRINGMAP_H__
#define _STRINGMAP_H__

#include <iostream>
#include <cassert>
#include <vector>
#include <string>

#include "hash.h"

using namespace std;

// string key special values 
//
#define VACATED "???"
#define EMPTY "!!!"

// the following expects a string argument x
//
#define OCCUPIED(x) ((x != EMPTY) && (x != VACATED))

// the stringmap class
// 
template <class _Tp> class stringmap {
protected:
	vector<string> _keys;
	vector<_Tp> _values;
	
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
	
	unsigned int hash_func( string );	// the hash function
	
	// hash table position getter (w/probing).  _set = 1 if the goal is to 
	// set a value (changes behavior for vacated tombstones). basically
	// all of this fanciness enables us to avoid scanning the entire table 
	// when looking for a non-stored key.
	//
	unsigned int index_of( string _key, int _set);	

	void grow();			// grow the table up to the next level
	void shrink();			// shrink the table down to the next level
	
public:

	unsigned int index_of( string );	// this version assumes _set = 0

	// an iterator
	//
	class iterator {

	protected:

		// container we are connected to
		stringmap<_Tp>* parent;

		int index;	// index into the stringmap

		// increment index to next populated hash entry (or end)
		void increment() {
			if (!parent) return;

			if (index == parent->last_index()) 
				index++;
			else 
				for (string key = EMPTY; index < parent->last_index() && !OCCUPIED(key); ++index, key = parent->key_real(index));
		}
				
		// decrement index to next populated hash entry (stops at begin)
		void decrement () {

			if (!parent) return;

			int i = index;
			for (string key = EMPTY; i > 0 && !OCCUPIED(key); --i, key = parent->key_real(i));

			// only change index if stopping point is populated.
			if (OCCUPIED(key_real(i))) {
				index = i;
			}
		}
				
		
	public:

		// constructors
		iterator() : parent(NULL), index(0) {}	
		iterator(int _index) : parent(NULL), index(_index) {}	
		iterator(stringmap<_Tp>* _parent) : parent(_parent), index(0) {}
		iterator(stringmap<_Tp>* _parent, int _index) : parent(_parent), index(_index) {}

		// iterator scan operations
		void operator+=(int _n) { for (int i = 0; i < _n; i++) increment(); }
		void operator-=(int _n) { for (int i = 0; i < _n; i--) decrement(); }
		void operator--() { decrement(); }
		void operator--(int) { decrement(); }
		void operator++() { increment(); }
		void operator++(int) { increment(); }
		
		// comparisons
		int operator==(const stringmap<_Tp>::iterator& a) { return index == a.index; }
		int operator!=(const stringmap<_Tp>::iterator& a) { return index != a.index; }
		int operator<(const stringmap<_Tp>::iterator& a) { return index < a.index; }
		int operator>(const stringmap<_Tp>::iterator& a) { return index > a.index; }
		int operator<=(const stringmap<_Tp>::iterator& a) { return index <= a.index; }
		int operator>=(const stringmap<_Tp>::iterator& a) { return index >= a.index; }
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

		// get the key of the current index (or EMPTY)
		string get_key() {
			string key = parent->key_real(index);

			if (OCCUPIED(key)) return key;

			return EMPTY;
		}

		// copy
		void operator=(const stringmap<_Tp>::iterator& a) { 
			index = a.index; 
			parent = a.parent;
		}

		// misc
		void set_parent(stringmap<_Tp>* _parent) { parent = _parent; }

	};

	/* iterator ENDS */

	friend class iterator; // iterators can see our privates

	// copy constructor
	//
	stringmap(const stringmap<_Tp>& from) {

		_keys = from._keys;
		_values = from._values;
	
		probe = from.probe;
		size = from.size;
		size_idx = from.size_idx;
		minsize = from.minsize;
		maxsize = from.maxsize;

		filled = from.filled;
		undef_val = from.undef_val;

		// start efficiency off anew
		total_lookups = 0;
		total_attempts = 0;
	}

	// almost do-nothing constructor. just init to sane defaults.
	stringmap(_Tp _undef_val) :
		_keys(PRIMES[0], EMPTY),				
		_values(PRIMES[0], _undef_val),
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

		// initialize probe interval
		//
		probe = int(size/4) + 1;
	}
	
	// constructor without max or min size
	stringmap(int _startsize, _Tp _undef_val) : 
		_keys(0, EMPTY),				
		_values(0 , _undef_val),
		minsize(PRIMES[0]),
		maxsize(PRIMES[MAX_PRIME_IDX]),
		undef_val(_undef_val),
		filled(0) { 

		// init size stuff
		// 
		size_idx = nearest_prime_index(_startsize);
		size = PRIMES[size_idx];

		// init vectors
		//
		_keys.resize(size, EMPTY);
		_values.resize(size, _undef_val);

		// initialize probe interval
		//
		probe = int(size/4) + 1;

		// init statistics stuff
		//
		total_attempts = 0;
		total_lookups = 0;
	}

	// full constructor
	stringmap(int _minsize, int _maxsize, int _startsize, _Tp _undef_val) : 
		_keys(0, EMPTY),				
		_values(0 , _undef_val),
		minsize(_minsize),
		maxsize(_maxsize),
		undef_val(_undef_val),
		filled(0) { 

		// init size stuff
		// 
		size_idx = nearest_prime_index(_startsize);
		size = PRIMES[size_idx];

		// init vectors
		//
		_keys.resize(size, EMPTY);
		_values.resize(size, _undef_val);

		// initialize probe interval
		//
		probe = int(size/4) + 1;

		// init statistics stuff
		//
		total_attempts = 0;
		total_lookups = 0;
	}

	_Tp& get( string );			// get the value at a string key index
	_Tp& set( string, _Tp ); 	// set the value at a string key index

	// remove an element by its id, and return it (or undef)
	_Tp remove( string );

	// remove an element pointed to by iterator. 
	_Tp remove( stringmap<_Tp>::iterator );

	// remove an element given by real array location
	_Tp remove_real ( int );

	// "real" array accessors for key and value.  
	//
	string key_real( int idx ) { assert(idx < size && idx >= 0); return _keys[idx]; }
	_Tp& value_real( int idx ) { assert(idx < size && idx >= 0); return _values[idx]; }

	// see if a key exists
	//
	int exists( string key ) { return ( OCCUPIED(_keys[index_of(key)])); }

	// see if a value exists
	//
	int defined( string key ) { return (exists(key) && (_values[index_of(key)] != undef_val)); }

	// get the value at a string key index.  actually, this gets a value 
	// ref, and even more importantly, if you try to get a non-existant 
	// location, it will be created and set to undef_val! this allows you to
	// do things like map[new_key] = blah instead of calling set() !!
	//
	_Tp& operator[]( string );	// takes key, returns template object type (ref)

	// the only thing "tricky" this has to do is copy the vectors.  all other 
	// variables carry straight over.
	stringmap<_Tp>& operator=(stringmap<_Tp> from) {

		_keys = from._keys;
		_values = from._values;
	
		probe = from.probe;
		size = from.size;
		size_idx = from.size_idx;
		minsize = from.minsize;
		maxsize = from.maxsize;

		filled = from.filled;
		undef_val = from.undef_val;

		// start efficiency off anew
		total_lookups = 0;
		total_attempts = 0;

		return *this;
	}

	// some useful accessors
	// 
	int get_size() { return size; }
	int get_filled() { return filled; }

	// get the capacity of the underlying vectors
	//
	int get_capacity() { return _keys.capacity(); }

	// first and last occupied indices.  the iterator makes use of this.
	//
	int first_index();
	int last_index();

	// see how efficient this stringmap is. optimal return value is 1. if you 
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

	stringmap<_Tp>::iterator begin();
	stringmap<_Tp>::iterator end();
};

// find the first occupied index (or 0 if none)
//
template <class _Tp> 
int stringmap<_Tp>::first_index( ) {

	if (filled > 0) {
		for (int i = 0; i < size; i++)
			if (OCCUPIED(_keys[i])) return i;
	} 
		
	return 0;
}

// find the last occupied index (or 0 if none)
//
template <class _Tp> 
int stringmap<_Tp>::last_index( ) {

	if (filled > 0) {
		for (int i = size - 1; i > 0; i--) 
			if (OCCUPIED(_keys[i])) return i;
	} 
	
	return 0;
}

// return a begin iterator
//
template <class _Tp> 
typename stringmap<_Tp>::iterator stringmap<_Tp>::begin( ) {
	
	if (filled == 0) {
		return stringmap<_Tp>::iterator(this, -1);
	} else {
		return stringmap<_Tp>::iterator(this, first_index());
	}
}

// return an end iterator
//
template <class _Tp> 
typename stringmap<_Tp>::iterator stringmap<_Tp>::end( ) {
	
	if (filled == 0) {
		return stringmap<_Tp>::iterator(this, -1);
	} else {
		return stringmap<_Tp>::iterator(this, last_index() + 1);
	}
}

// the string hash function.  stolen from Kevin's code.
//
template <class _Tp>
unsigned int stringmap<_Tp>::hash_func( string k) {
	unsigned long h = 0;
	char const *p = k.c_str();

	while( *p ) {
		h = (h<<4) + *p++;
		unsigned long g = h & 0xF0000000L;
		if( g ) h ^= g >> 24;
		h &= ~g;
	}

	return h % size;
}

// get the index of a key in the hash table, taking into account
// collisions. performs linear probing.
//
template <class _Tp> 
unsigned int stringmap<_Tp>::index_of ( string _key ) {

	return index_of(_key, 0);	// this is only a "get" lookup
}

// actual implementation of above, with the following addition:
// if we are setting, we stop at vacated tombstones (-2) in addition to just
// tombstones (-1)
//
template <class _Tp> 
unsigned int stringmap<_Tp>::index_of ( string _key, int set ) {

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
		while (_keys[index] != _key && _keys[index] != EMPTY && attempts < size) {

			// if we found a vacated spot, "bookmark" it
			if (_keys[index] == VACATED && vacated == -1) vacated = index;

			// keep going
			index = (index + probe) % size;
			attempts++;
		}

		// if we didn't find the key but found a vacated position, use the 
		// vacated position.
		//
		if (attempts < size && !OCCUPIED(_keys[index]) && vacated != -1) {

			index = vacated;
		}

	} else {
		while (_keys[index] != _key && _keys[index] != EMPTY && attempts < size) {
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
// keys which are not found
//
template <class _Tp>
_Tp& stringmap<_Tp>::get ( string _key ) {

	unsigned int index = index_of(_key);

	return _values[index];
}

// []-style get, which also does a set for accessing un-defined "indices"
//
template <class _Tp>
_Tp& stringmap<_Tp>::operator[]( string _key ) {

	unsigned int index = index_of(_key);

	if (!OCCUPIED(_keys[index])) {

		// have to return this, as set could be setting at a different index
		// and we need a ref to the value at the correct index
		//
		return set(_key, undef_val);
	}

	return _values[index];
}

// remove an entry from the hash vector
//
template <class _Tp>
_Tp stringmap<_Tp>::remove ( string _key ) {
	
	unsigned int index = index_of(_key);

	return remove_real(index);
}

// remove an entry from the hash vector by table index, rather than key
//
template <class _Tp>
_Tp stringmap<_Tp>::remove_real( int index ) {
	
	string key = _keys[index];
	_Tp value = undef_val;

	// make sure something is here
	if (OCCUPIED(key)) {

		// grab the value
		value = _values[index];
	
		// clear the spot
		//
		_values[index] = undef_val;
		_keys[index] = VACATED;			// "vacated" tombstone
		
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
_Tp& stringmap<_Tp>::set ( string _key, _Tp _val ) {

	unsigned int index = index_of(_key, 1);
		
	string key = _keys[index];

	// overwrite old value
	// 
	_values[index] = _val;

	// if new spot, see if we should grow. (EMPTY or VACATED)
	// 
	if ( !OCCUPIED(key) ) { 
		
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
void stringmap<_Tp>::grow() {

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
	
	// copy the old vectors
	//
	vector <string> old_keys = _keys;
	vector <_Tp> old_values = _values;

	// resize keys and vals; set new half to defaults
	//	
	_keys.resize(size, EMPTY);
	_values.resize(size, undef_val);

	// clear out old portion (~ 1st half)
	//
	unsigned int i;
	for (i = 0; i < old_size; i++) {
		_keys[i] = EMPTY;
		_values[i] = undef_val;
	}
	
	// new probe interval
	//
	probe = int(size/4) + 1;

	// hash old keys and values into resized vector
	//
	for (i = 0; i < old_size; i++) {
		
		if (OCCUPIED(old_keys[i])) {  // ignore all tombstoned entries
			unsigned int index = index_of(old_keys[i]);
			_keys[index] = old_keys[i];
			_values[index] = old_values[i];
		}
	}

	// unquote this to care about resizing overhead in efficiency stats
	//
	total_attempts += old_size; // at least this many ops in the copying
	total_lookups -= old_size;	// these aren't "external" lookups
}

// shrink the hash vector
// 
template <class _Tp> 
void stringmap<_Tp>::shrink () {

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
	
	// copy the old vectors
	//
	vector <string> old_keys = _keys;
	vector <_Tp> old_values = _values;

	// resize keys and vals
	//	
	_keys.resize(size, EMPTY);
	_values.resize(size, undef_val);

	// set to defaults
	//
	unsigned int i;
	for (i = 0; i < size; i++) {
		_keys[i] = EMPTY;
		_values[i] = undef_val;
	}
	
	// new probe interval
	//
	probe = int(size/4) + 1;

	// hash old keys and values into resized vector
	//
	for (i = 0; i < old_size; i++) {
		
		if (OCCUPIED(old_keys[i])) {  // ignore all tombstoned entries
			unsigned int index = index_of(old_keys[i]);
			_keys[index] = old_keys[i];
			_values[index] = old_values[i];
		}
	}

	// unquote this to care about resizing overhead in efficiency stats
	//
	total_attempts += old_size; // at least this many ops in the copying
	total_lookups -= old_size;	// these aren't "external" lookups
}



#endif
