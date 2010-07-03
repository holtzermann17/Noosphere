/******************************************************************************

 Class definition for a single postings list.

******************************************************************************/

#ifndef POSTING_LIST_H
#define POSTING_LIST_H 

#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <map>
#include <cassert>

#include "global.h"
#include "intmap.h"
#include "vlmap.h"

using namespace std;

/* postings list entry struct */

#ifdef RELAX_POSTINGS

/* 6-byte version */ 

typedef struct postent {
	unsigned int docid;			// the id of the document 
	unsigned char count;		// an occurrence count. total over all tags. 
	unsigned char tagid;		// tagid the word occurs in
} postentry;

const struct postent EMPTY_ENTRY = {0, 0, 0};

#else

/* super-compact version... only 4 bytes per posting entry. */

/* unfortunately this limits us to 16.7 million documents, 16 unique tags,
 * and 16 different term counts, but this should suffice for many 
 * purposes. */

typedef struct postent {

	unsigned short docid;		// docid, low 2 bytes
	unsigned char docid_high;	// high byte
	
	// count and tagid; low nibble is count, high is tagid. 
	unsigned char count_and_tagid;
} postentry;

const struct postent EMPTY_ENTRY = {0, 0, 0};

#endif


/* new postings list class */

class posting_list {

private:

	// the postings list
	vector<postentry> list;

#ifdef SUPER_FAST_UNINDEXING
	// keep track of index of last removed record and check it first for next
	// unindexed record. this removes the need to do a binary search when
	// unindexing in order.
	int last;	
#endif

public:
	// don't have to do anything for constructor
	//
	posting_list() 
#ifdef SUPER_FAST_UNINDEXING
	:
		last (-1) 
#endif
	{  }

	// unless you want to allocate a specifically-sized vector
	//
	posting_list(int _init_size) : list(_init_size, EMPTY_ENTRY)
#ifdef SUPER_FAST_UNINDEXING
	, last(-1)  
#endif
	{ }

	// copy constructor
	//
	posting_list(posting_list& from) : list(from.get_filled(), EMPTY_ENTRY) {
		for (int i = 0; i < from.get_filled(); i++) {
			list.push_back(from[i]);
		}
	}

	// compact postings list accessors
	inline int get_docid(postentry&);
	inline void set_docid(postentry&, int);
	inline int get_count(postentry&);
	inline void set_count(postentry&, int);
	inline int get_tagid(postentry&);
	inline void set_tagid(postentry&, int);

	// get the percentage of records using their tag lists
	float get_taglist_frac();

	// get the allocated memory size
	int get_size() { return list.capacity(); }

	// get the underlying vector capacity
	int get_capacity() { return list.capacity(); }

	// get the filled posting entry count 
	int get_filled() { return list.size(); }
	
	// add a word instance to the postings list
	void add(int _docid, int _tagid);
	
	// remove list entry for a docid (incl. deallocating its tag list)
	void remove(int _docid);

	// get a posting entry at a specific index
	postentry operator[](int index) {
		
		return list[index];
	}

	// is the postings list empty?
	//
	bool is_empty() { return !list.size(); }

	void print() { } // implement later

	// get a "list" (really a map) of the postings list with just docid=>count
	// collection_size should be approx the number of documents
	// num_tags should be approx the number of distinct tags in the collection
	intmap<short>* get_list(int collection_size, int num_tags, int _tagid, intmap<intmap<short>*>& field_counts);

};

#endif
	

	
