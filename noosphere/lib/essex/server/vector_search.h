/******************************************************************************
 
 The vector space search engine class.  Contains inverted index, and routines
 for accessing it.

 - Essentially completely rewritten, spring '03 by Aaron Krowne.  now based 
   almost entire on custom hash maps (intmap and stringmap).
 - Originally by Matt Gracey, fall '02
 
******************************************************************************/

#ifndef VECTOR_SEARCH_H 
#define VECTOR_SEARCH_H

#include <string>
#include <vector>
#include <iostream>
#include <math.h>
#include <fstream>
#include <map>
#include <pthread.h>

#include "logger.h"
#include "stemmer.h"
#include "stringmap.h"
#include "intmap.h"
#include "global.h"
#include "query.h"
#include "docrec.h"
#include "posting_list.h"

class vector_search {
private:

	/* vector of postings lists, the core of the inverted index */
	intmap<posting_list*>* inverted_index;

	/* dictionaries for tags, words, and doc ids */
	stringmap<short> tagid_lookup;
	stringmap<int> wordid_lookup;
	stringmap<int> docid_lookup;

	/* a reverse lookup for docids, so we can get doc name from id */
	intmap<string> docid_reverse;

	/* document records, for fast removal and magnitude calculation 
	 * (this is essentially a forward index) */
	intmap<docrec*> doc_list;

	int wordid_counter;
	int tagid_counter;
	int docid_counter;

	/* stemmer */
	stemmer stem;
	
	/* miscellany */
	int num_docs;
	int num_words;
	int num_tags;
	
	/* logger */
	logger* _log;

	/* index access mutex */
	/* this is very coarse-grained control.  really we should do some 
	 * read/write mutexing.  */

	pthread_mutex_t index_access_mutex;
	
	/* make (or get) the id of a word */
	int make_wordid(string _word);

	/* can only get (not make) a word id */
	int get_wordid(string _word);

	/* get the id of a document name, which may also assign an id */
	int get_docid(string _docname);

	/* get the name of a document, given its id */
	string get_docname(int _docid);

	/* make (or get) id of a tag name */
	int make_tagid(string _tagname);

	/* can only get (not make) a tag id) */
	int get_tagid(string _tagname);

public:
	/* core functions */

	/* constructor */
	vector_search() : 
		tagid_lookup(-1), 
		wordid_lookup(-1), 
		docid_lookup(-1), 
		docid_reverse("UNKNOWN"),
		stem(),
		num_docs(0), 
		num_words(0), 
		num_tags(0), 
		doc_list(NULL), 
		wordid_counter(0),
		docid_counter(0), 
		tagid_counter(0),
		_log(NULL)
		{
		
			inverted_index = new intmap<posting_list*> (NULL);
		}
		
	/* initialize mutex stuff */
	void initmutex();

	/* remove a document from the index */
	void remove_doc(string _docname);

	/* index the text of a single element of the document */
	void add_element(vector<string> words, const string _docname, const string _tagname);

	/* execute a search for a query, get a result set. unlimited */
	vector<query_result> search(vector<query_node>);

	/* version of search that limits # of results for efficiency. this is the
	 * actual core version */
	vector<query_result> search(vector<query_node>, int& limit);

	/* print some statistics */
	void stats();

	/* clean up wasted space */
	void compactify();

	/* set a logger */
	void setlogger(logger* log) { _log = log; }

	/*void print();*/
	
	/* persistance */

	/*
	void writeDisk();
	void readDisk();
	void revision_add(vector<string>, const string, const string);
	void revision_remove(const string, const string);
	int process_revision(fstream&, int);
	int read_add(fstream& file, int);
	int read_remove(fstream& file, int);
	*/
};

#endif
