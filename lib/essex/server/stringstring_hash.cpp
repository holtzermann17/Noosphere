/******************************************************************************
 
 Implementation for string=>string hashed associative map.

******************************************************************************/
 
#include "stringstring_hash.h"
#include "global.h"

int stringstring_hash::hash_func( string word ) {
	unsigned long h = 0;
	char const *p = word.c_str();

	while( *p ) {
		h = (h<<4) + *p++;
		unsigned long g = h & 0xF0000000L;
		if( g ) h ^= g >> 24;
		h &= ~g;
	}

	return h % capacity;
}

int stringstring_hash::index_of( string key ) {

	assert( key.length() > 0 );

	//locate hashed position in table - break when find key or empty slot
	int pos = hash_func( key );
	/*WHY IS THIS HERE???
	int orig = pos;*/
	while( _keys[pos] != key && _keys[pos].length() > 0 )
		pos = (pos+1) % capacity;


	//if no value in slot, its a unique addition
	if( _keys[pos].length()==0 ) {
		size++;

		//check for resizing - do so if 75% full
		if ((float)size/(float)capacity > 0.75) {
			resize_up();

			//now rehash key into newly sized array
			pos = hash_func( key );
			while(_keys[pos] != key && _keys[pos].length()>0)
				pos = (pos+1) % capacity;
			_keys[pos] = key;
		} 
		else 
			_keys[pos]=key;
	}
			
	return pos;
}

int stringstring_hash::remove_key(string key) {

	assert( key.length() > 0 );

	//locate hashed position in table - break when find key or empty slot
	int pos = hash_func( key );

	// position to stop searching at (if the key isn't really there, we have
	// to search the entire table)
	int last = (2*pos - 1) % capacity;
	while( _keys[pos] != key && pos != last)
		pos = (pos+1) % capacity;

	// if the desired key is in the slot, remove the entry
	if( _keys[pos] == key) {
		size--;

		// check for resizing - do so if < 35% full
		if ((float)size/(float)capacity < 0.35) {
			resize_down();

			// now rehash key into newly sized array
			pos = hash_func( key );
			while(_keys[pos] != key)
				pos = (pos+1) % capacity;
			_keys[pos] = "";
		} 
		else 
			_keys[pos] = "";

	}

	return pos;
}

void stringstring_hash::resize_up() {

	int old_capacity = capacity;
	capacity *= 2;

	vector<string> temp_keys(capacity, "");
	vector<string> temp_values(capacity, "!!!");

	//copy old values into new hashed positions in new table
	int idx;
	for (idx=0; idx<old_capacity; idx++) {
		
		if (_keys[idx].length()>0) {

		
			//locate hashed position in new table - break when find key or empty slot
			int pos = hash_func(_keys[idx]);
			while(temp_keys[pos] != _keys[idx] && temp_keys[pos].length() > 0)
				pos = (pos+1) % capacity;


			//if no value in slot, its a unique addition
			if(temp_keys[pos].length()==0 ) {
				string in=_keys[idx];
				temp_keys[pos] = _keys[idx];
				string out=(*values_ptr)[idx];
				temp_values[pos]=(*values_ptr)[idx];
			}
		}
	}

	_keys=temp_keys;
	*values_ptr=temp_values;
}

void stringstring_hash::resize_down() {

	assert((float)size/(float)capacity < 0.35);

	int old_capacity=capacity;
	capacity/=2;

	vector<string> temp_keys(capacity, "");
	vector<string> temp_values(capacity, "");

	//copy old values into new hashed positions in new table
	int idx;
	for (idx=0; idx<old_capacity; idx++) {
		
		if (_keys[idx].length()>0) {

		
			//locate hashed position in new table - break when find key or empty slot
			int pos = hash_func(_keys[idx]);
			while(temp_keys[pos] != _keys[idx] && temp_keys[pos].length() > 0)
				pos = (pos+1) % capacity;


			//if no value in slot, its a unique addition
			if(temp_keys[pos].length()==0 ) {
				temp_keys[pos] = _keys[idx];
				temp_values[pos] = (*values_ptr)[idx];
			}
		}
	}

	_keys=temp_keys;
	*values_ptr=temp_values;
}

/*
int stringstring_hash::writeHash(int start_pos, fstream& file) {

	char buf[20];
	char* dum = new char[capacity*sizeof(string)];
	char* temp;
	char* pos = dum;
	int word_size = 0;

	int idx;
	for (idx=0; idx<capacity; idx++) {
		
		temp = (char*)_keys[idx].c_str();		//read in string at from[idx]
		//count letters in string	
		int word_size;
		for (word_size=0; temp[word_size]!='\0'; word_size++) {}
		word_size++;			//for null_char

		memcpy((void*)pos, (void*)temp, word_size);		//add word to buffer
		pos+=word_size;

	}
	
	int file_size=pos-dum;

	//find starting point in file
	file.seekp(start_pos);

	//write the number of bytes in the buffer
	file.write((char*)_itoa(file_size, buf, 10), sizeof(string));

	//write capacity of vector
	file.write((char*)_itoa(capacity, buf, 10), sizeof(string));

	//write size of vector
	file.write((char*)_itoa(size, buf, 10), sizeof(string));

	//write the contents
	file.write((char*)dum, file_size);

	//return the new position at which to begin writing
	return start_pos+file_size+(3*sizeof(string));
}

int stringstring_hash::readHash(int start_pos, fstream& file) {

	char* temp;
	char buf[20];
	int file_size=0;
	int vector_size;
	
	file.seekg(start_pos);				//find start of entry

	file.read((char*)buf, sizeof(string));		//read file_size in as a string
	file_size=atoi(buf);				//convert to int

	file.read((char*)buf, sizeof(string));		//read vector_size in as a string
	capacity=atoi(buf);				//convert to int

	file.read((char*)buf, sizeof(string));		//read vector_size in as a string
	size=atoi(buf);				//convert to int

	//create new dummy vectors
	vector<string> temp_keys(capacity, "");
	vector<string> temp_values(capacity, "");

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
		temp_keys[idx]=(string)word_buf;		//add to to
				
		pos+=(word_size);		//increment pos, ignore null_char

	}

	_keys=temp_keys;
	*values_ptr=temp_values;

	//return point at which the next entry begins
	return start_pos+file_size+(3*sizeof(string));	
}
*/

