/******************************************************************************

 Vector space search engine routines, implemented.

******************************************************************************/

#include <algorithm>
#include <string.h>

#include "vector_search.h"
#include "util.h"
#include "intmap.h"
#include "rankmm.h"
//#include "vlrankmap.h"

// not sure why we need these... there is some goofy problem with bool and 
// STL
#define MYBOOL unsigned char
#define MYTRUE 1
#define MYFALSE 0

#define SQUARE(x) ((x)*(x))

void vector_search::initmutex() {
	
	// init our index mutex
	pthread_mutexattr_t ma;
	pthread_mutexattr_init(&ma);
	pthread_mutex_init(&index_access_mutex, &ma);
}

/* make (or get) an integer id for a word (in the "dictionary") */
int vector_search::make_wordid(string _word) {
		
	int id = wordid_lookup[_word];

	// new doc
	if (id == -1) {
		wordid_lookup[_word] = wordid_counter;
		id = wordid_counter;
		wordid_counter++;
		num_words++;
	}

	return id;
}

/* only get, not make, a word id */
int vector_search::get_wordid(string _word) {
		
	return wordid_lookup[_word];
}

/* get the id of a document name, which may also assign an id */
int vector_search::get_docid(string _docname) {
		
	int id = docid_lookup[_docname];

	// new doc
	if (id == -1) {
		docid_lookup[_docname] = docid_counter;
		id = docid_counter;
		
		docid_counter++;
		num_docs++;

		// also add to reverse lookup map
		//
		docid_reverse[id] = _docname;
	}

	return id;
}

/* get the name of a document, given id. if not found, returns "UNKNOWN" */
string vector_search::get_docname(int _docid) {
		
	string docname;

	if (docid_reverse.exists(_docid)) {
		docname = docid_reverse[_docid];
	} else {
		docname = "UNKNOWN";
	}

	return docname;
}

/* make (or get) the id of a tag name, which may also assign an id */
int vector_search::make_tagid(string _tagname) {
		
	int id = tagid_lookup[_tagname];

	if (id == -1) {
		tagid_lookup[_tagname] = tagid_counter;
		id = tagid_counter;
		tagid_counter++;
		num_tags++;
	}

	return id;
}

/* can only get, not make, a tag id from a tag name */
int vector_search::get_tagid(string _tagname) {

	return tagid_lookup[_tagname];
}

/* remove a document from the index, given its string identifier/name */
void vector_search::remove_doc(string _docname) {
	
	assert (pthread_mutex_lock(&index_access_mutex) == 0);
	
	int docid = get_docid(_docname);

	docrec* doc_record = doc_list[docid];

	// access the doc record for the document. this is a list of word ids 
	// indexed for the document.  step through this and remove postings list
	// data for this document for each words
	//
	if (doc_record != NULL) {

		intmap<char>::iterator it;
		for (it = doc_record->words->begin(); it != doc_record->words->end(); it++) {

			int wordid = it.get_key();

			// get the postings list for the word
			// 
			posting_list* plist = (*inverted_index)[wordid];

			// remove any traces of the document from the postings list
			//
			if (plist != NULL) {
				plist->remove(docid);

				// if the postings list is empty, remove it
				//
				if (plist->is_empty()) {
					
					inverted_index->remove(wordid);
					delete plist;
				}
			}
		}

		// remove the doc record and deallocate it
		//
		delete doc_record->words;
		delete doc_list.remove(docid);

		// remove the docname lookup data
		//
		docid_lookup.remove(_docname);
		docid_reverse.remove(docid);
	}

	assert (pthread_mutex_unlock(&index_access_mutex) == 0);
}

/* clean up wasted space. this is done by re-allocating everything. */
void vector_search::compactify() {

	assert (pthread_mutex_lock(&index_access_mutex) == 0);

	intmap<posting_list*>* new_index = new intmap<posting_list*>(inverted_index->get_size(), NULL);	

	intmap<posting_list*>::iterator it;

	// for each postings list
	for (it = inverted_index->begin(); it != inverted_index->end(); it++) {

		// create a postings list with the memory allocated precisely and
		// the values from the old list
		// 
		posting_list* new_posting = new posting_list(*(*it));

		new_index[it.get_key()] = new_posting;
	}

	// clear out old index
	//
	for (it = inverted_index->begin(); it != inverted_index->end(); it++) {
		delete &(*it);
		*it = NULL;
	}
	delete inverted_index;

	// switch over to new index
	//
	inverted_index = new_index;

	assert (pthread_mutex_unlock(&index_access_mutex) == 0);
}

/* print out some statistics */ 
void vector_search::stats() {
	
	intmap<posting_list*>::iterator iii;
	
	int n = 0;
	int tag_n = 0;
	float tagfrac = 0;
	float filledfrac = 0;
	float avgfilled = 0;
	float avgcap = 0;
	
	// get index statistics
	// 
	for (iii = inverted_index->begin(); iii != inverted_index->end(); iii++) {
		
		if (!(*iii)->is_empty()) {
			float avg = (*iii)->get_taglist_frac();
			tag_n++;

			tagfrac = (tagfrac*(tag_n-1) + avg)/tag_n;
		}

		n++;

		int size = (*iii)->get_size();
		int filled = (*iii)->get_filled();
		int capacity = (*iii)->get_capacity();
		float frac =  ((float)filled)/((float)size);

		filledfrac = (filledfrac*(n-1) + frac)/n;
		avgfilled = (avgfilled*(n-1) + filled)/n;
		avgcap = (avgcap*(n-1) + capacity)/n;
	}

	// get doc record statistics
	//
	float avgwords = 0;
	int totalwords = 0;
	n = doc_list.get_filled();
	intmap<docrec*>::iterator it;
	for (it = doc_list.begin(); it != doc_list.end(); it++) {
		docrec* doc_record = *it;
		totalwords += doc_record->words->get_filled();
	}

	avgwords = (float)totalwords/n;

	// print out statistics
	//
	cout << "vector_search::stats : dictionary size is " << wordid_counter+1 << endl;
	cout << "vector_search::stats : tag dictionary size size is " << tagid_counter+1 << endl;
	cout << "vector_search::stats : number of indexed documents is " << docid_counter+1 << endl;
	//cout << "vector_search::stats : average fraction of tag lists used is " << tagfrac << endl;
	cout << "vector_search::stats : average posting list filled fraction is " << filledfrac << endl;
	cout << "vector_search::stats : average posting list filled is " << avgfilled << endl;
	cout << "vector_search::stats : average posting list vector capacity is " << avgcap << endl;
	cout << "vector_search::stats : average unique words per document is " << avgwords << endl;
}

/* index an element of a document (list of words within the element) */
void vector_search::add_element(vector<string> _text, const string _docName, const string _tagName) {

	assert (pthread_mutex_lock(&index_access_mutex) == 0);

	int idx;
	vector<string> text;	// final output list of terms to index

	// get internal identifiers
	//
	int docid = get_docid(_docName);
	int tagid = make_tagid(_tagName);

	// do some more splitting (like hyphenated terms)
	text = split_for_indexing(_text);

	// grab/create doc record for the document. this contains wordids of all
	// words that appear in the document
	//
	docrec* doc_record = doc_list[docid];
	if (doc_record == NULL) {
		doc_record = new docrec;
		doc_record->words = new intmap<char>(0);
		doc_record->mag = 0.0;
		doc_list[docid] = doc_record;
	}

	// build a hash of what's currently in the doc record, so we can avoid
	// duplicates as we add to the list.  try to init this hash to an 
	// intelligent size.
	//
/*	intmap<int> temp_record(2*doc_record->size(), -1);
	for (int i = 0; i < doc_record->size(); i++) {
		temp_record[(*doc_record)[i]] = 1;
	}
*/
	// we want to also avoid duplicates in the new text, but we should keep
	// this hash separate so we know only things here need to be updated 
	// in the doc record when we're done.
	//
/*	intmap<int> new_record(2*_text.size(), -1); */
	
	intmap<char>* docwords = doc_record->words;		// for convenience

	// iterate over words
	//
	for (idx = 0; idx < text.size(); idx++) {

		// get stemmed version of text[idx]
		string stemmed_word = stem.stem_and_stop(text[idx]);

		// if word didn't get stopped, index it
		//
		if (stemmed_word.length() > 0) {
			
			// get/create a word id for this stemmed word
			//
			int wordid = make_wordid(stemmed_word);

#ifdef VS_DEBUG
			cout << "vector_search::add_element : adding occurrence of (docid=" << docid << ", tagid=" << tagid << ", wordid=" << wordid << ", word=" << stemmed_word << ") to postings list" << endl;
#endif

			// get postings list for this word
			//
			posting_list* plist = (*inverted_index)[wordid];

			// create a new postings list if we need to
			// 
			if (plist == NULL) {
				plist = new posting_list();
				(*inverted_index)[wordid] = plist;	
			}

			// add to the postings list
			//
			plist->add(docid, tagid);

			// add to temp doc record, if needed.
			//
			/*if (!temp_record.exists(wordid) && !new_record.exists(wordid)) {
				new_record[wordid] = wordid;
			}*/

			// add to doc record.  if new slot for wordid, the position will 
			// be initialized to zero then incremented to 1.
			int count = (*docwords)[wordid];
			if (count < 255) {
				(*docwords)[wordid] = count + 1;
			}
		}
	}

	// update the document record with new words
	//
/*	intmap<int>::iterator it;
	for (it = new_record.begin(); it != new_record.end(); it++) {
		doc_record->push_back(*it);
	}*/

	// update the document magnitude
	//
	intmap<char>::iterator it;
	float sum = 0;
	for (it = docwords->begin(); it != docwords->end(); it++) {
		sum += SQUARE(*it);
	}
	doc_record->mag = sqrt(sum);

	assert (pthread_mutex_unlock(&index_access_mutex) == 0);
}

/* search version that sets limit to unlimited */
vector<query_result> vector_search::search(vector<query_node> query) {
	int limit = -1;

	return search(query, limit);
}

/* our main feature-- the search method */
vector<query_result> vector_search::search(vector<query_node> query, int& limit) {

	// Try to predict a good size intelligently here. 
	// this probably needs work, but shouldn't be catastrophically wrong.
	//
	int predicted_docs = int(0.5 * sqrt((float)num_docs) + 0.5);
	int hash_max = num_docs * 2;
	int hash_init = (50 > predicted_docs ? 50 : predicted_docs);

	intmap<MYBOOL> found_docs(hash_init, MYFALSE);
	intmap<MYBOOL> these_docs(hash_init, MYFALSE);

	// final vectors will go in here, and used for similarity computation
	vector<intmap<float> > docVectors;

	// field weights will go here
	intmap<float> field_weights(2*num_tags, 1);
	
	int num_terms = 0;

	// first build field weights hash based on query.  remove them from the
	// query
	//
	int i;	
	float maxweight = -1;
	for (i = 0; i < query.size(); i++) {

		// look for '=' delimiter, as in field=weight
		//
		if (strchr(query[i].queryTerm.c_str(),'=')) {

			vector<string> field_weight = split('=', query[i].queryTerm);

			int fieldid = get_tagid(field_weight[0]);
			float weight = (float)strtod(field_weight[1].c_str(), NULL);		

			// set the weight in the field_weights map
			//
			if (fieldid != -1) {

				// only set the weight the first time we see it.  this allows
				// a digital library to append some default weights, but when
				// a user manually specifies other weights, they will take
				// precendent.
				//
				if (!field_weights.exists(fieldid)) {
					field_weights[fieldid] = weight;

					// keep track of max weight for normalization later
					if (weight > maxweight) maxweight = weight;
				}
			}
			
			// erase this node, since its a directive, not a real query term
			query.erase(query.begin() + i);
			i--;
		}
	}

	// add in unspecified weights
	for (int i = 0; i < num_tags; i++) {
		if (!field_weights.exists(i)) {
			field_weights[i] = 1.0;
			if (1.0 > maxweight) maxweight = 1.0;
		}
	}

	// normalize the field weights
	for (intmap<float>::iterator fwi = field_weights.begin(); fwi != field_weights.end(); fwi++) *fwi = *fwi/maxweight;

	// split query terms.  for a term that is split, we copy the 
	// metadata tag and qualifier fields into all of the split terms.
	// 
	for (i = 0; i < query.size(); i++) {
		vector<string> split_terms = split_for_indexing(query[i].queryTerm);

		// make new query nodes
		if (split_terms.size() > 1) {
			
			// remove (but save) old node
			query_node old_node = query[i];
			query.erase(query.begin() + i);

			int j;
			for (j=0; j<split_terms.size(); j++) {
				query_node tempq;

				// build a new node with old metadata but new term
				tempq = old_node;
				tempq.queryTerm = split_terms[j];

				// add the current node
				query.insert(query.begin() + i, tempq);
			}

			// don't analyze the new nodes we just added
			i += split_terms.size() - 1;
		}
	}
	
	// stem and uniquify query terms to remove unecessary information
	// 
	int ct;
	stringmap<MYBOOL> qunique(i, MYFALSE);
	for (ct = 0; ct < query.size(); ct++) {
		string old = query[ct].queryTerm;

		query[ct].queryTerm = stem.stem_and_stop(query[ct].queryTerm, 0);

		// word was stopped or isn't in index, remove the query condition 
		// 
		if (query[ct].queryTerm.length() == 0 || 
			query[ct].queryTerm == EMPTY) {
			
			query.erase(query.begin() + ct);
			
			ct--;		// look at this index again
		}

		// check for uniqueness 
		//
		else {
			// remove dupes
			if (qunique.exists(query[ct].queryTerm)) {

				query.erase(query.begin() + ct);

				ct--;	// look at this index again
			}
			
			// add non-dupes (first occurrence of anything)
			else { 
				qunique[query[ct].queryTerm] = MYTRUE;
			}
		}
	}

	// this will hold the "slices" of the postings list for each document.
	// the intmap<short> is of the form docid=>weight
	//
	// weight is made up of a sum of occurrence count times a field weight.
	//
	vector<intmap<short>*> doc_postings;
	
	// pointer to posting list "slice" for a term
	intmap<short>* this_term;

	// map of maps; field counts for each document. we will build this so that
	// we can determine a field weighting multiplier later.
	//
	intmap<intmap<short>*> field_counts(hash_init, NULL);

	assert (pthread_mutex_lock(&index_access_mutex) == 0);

	// Walk through each query term, retrieve postings lists
	// 
	ct=0;
	vector<query_node>::iterator _i;
	for (_i = query.begin(); _i != query.end(); _i++, ct++) {

		int tagid = -1; 

		if (_i->elemName.length() > 0) {
			tagid = get_tagid(_i->elemName);
		}

		int wordid = get_wordid(_i->queryTerm);

#ifdef VS_DEBUG
		cout << "vector_search::search: got word id " << wordid << " for word " << _i->queryTerm << endl;
#endif

		// if there is posting list associated with this term
		// 
		if (wordid != -1 && inverted_index->exists(wordid)) {

			// get a slice of it and update field counts
			//
			this_term = (*inverted_index)[wordid]->get_list(num_docs, num_tags, tagid, field_counts);

			if (this_term->get_filled() > 0) {
				// add to the list of candidate documents
				doc_postings.push_back(this_term);
#ifdef VS_DEBUG
				cout << "populated postings list found for word " << _i->queryTerm << endl;
#endif
			} else {
				// NULL placeholder if the slice is empty or word DNE
				doc_postings.push_back(NULL);
#ifdef VS_DEBUG
				cout << "empty postings list for word " << _i->queryTerm << " (wordid is " << wordid << ")" << endl;
#endif
			}
		}

		// NULL placeholder
		// 
		else {
			doc_postings.push_back(NULL);
#ifdef VS_DEBUG
			cout << "no postings found for word " << _i->queryTerm << endl;
#endif
		}
	}
	
	assert (pthread_mutex_unlock(&index_access_mutex) == 0);

	// record number of terms in query
	num_terms = ct;

	// record all candidate documents as found (though these still have to 
	// make it through force/forbid processing)
	// 
	for (ct=0; ct < num_terms; ct++) {

		intmap<short>::iterator it;
		intmap<short>* slice = doc_postings[ct];

		if (slice != NULL) 
		for (it = slice->begin(); it != slice->end(); it++) {
			// value (occurrence count) must be greater than zero
			if (*it > 0) {
				int docid = it.get_key();
				found_docs[docid] = MYTRUE;
			}
		}
	}

	// process forbid (-).  this is easy: any found document which contains a
	// forbidden term simply gets removed.
	//
	ct=0;
	for (_i = query.begin(); _i != query.end(); _i++, ct++) {
	
		if (_i->qualifier != '-') continue;

		// loop through postings list slice for this term.  remove all documents
		// in the list from found_docs.
		//
		intmap<short>::iterator it;
		intmap<short>* slice = doc_postings[ct];

		if (slice != NULL)
		for (it = slice->begin(); it != slice->end(); it++) {
	
			if (*it > 0) {
				int docid = it.get_key();
				found_docs[docid] = MYFALSE;
#ifdef VS_DEBUG
				cout << "forbid : setting found_docs for " << docid << " to false" << endl;
#endif
			}
		}
	}

	// process force.  this is a little more complicated.  for each forced term:
	// 1. we make a temp docs boolean map and init it to _false_ (using the
	//    found_docs which are true)
	// 2. for each document in the postings for the term, set the document's
	//    entry in the temp map to _true_
	// 3. AND found_docs with temp doc list, which will leave only the found
	//    docs which passed all previous tests plus the force test for the 
	//    current term
	//
	
	// init these_docs to false based on found_docs which are true. this
	// is really ugly now because we dont have an iterator over intmaps
	// which abstracts that they are hashes.
	//

	intmap<MYBOOL>::iterator fi;
	for (fi = found_docs.begin(); fi != found_docs.end(); fi++) {

		// set to false... in the next loop these will have to "prove their
		// worth" to be included.
		//
		if (*fi == MYTRUE) {
			int docid = fi.get_key();
#ifdef VS_DEBUG
			cout << "initting these_docs[" << docid << "] to false" << endl;
#endif 
			these_docs[docid] = MYFALSE;
		}
	}
	
	ct=0;
	for (_i = query.begin(); _i != query.end(); _i++, ct++) {
	
		if (_i->qualifier != '+') continue;

#ifdef VS_DEBUG
		cout << "processing forbid for query term " << ct << endl;
#endif
	
		// now loop through postings list for this term and "turn on" the found
		// documents in these_docs
		//
		intmap<short>::iterator it;
		intmap<short>* slice = doc_postings[ct];

		if (slice != NULL)
		for (it = slice->begin(); it != slice->end(); it++) {
		
			int docid = it.get_key();
			these_docs[docid] = MYTRUE;
#ifdef VS_DEBUG
			cout << " setting these_docs[" << docid << "] = true" << endl;
#endif
		}	

		// now copy over the processed these_docs values, which will only "let
		// through" docs that had the current term.
		//
		intmap<MYBOOL>::iterator fi;
		for (fi = found_docs.begin(); fi != found_docs.end(); fi++) {

			// we only have to exclude included documents
			if (*fi == MYTRUE) {

				int docid = fi.get_key();

				// copy the temp value over
				found_docs[docid] = these_docs[docid];
#ifdef VS_DEBUG
				cout << " setting found_docs[" << docid << "] = " << these_docs[docid] << "(these_docs[" << docid << "])" << endl;
#endif

				// reset temp values for next loop
				these_docs[docid] = MYFALSE;
			}
		}
	}

	// walk through query terms and corresponding document lists
	// 
	ct = 0;
	int nmatches = 0;		// number matching documents
	int mag_query = 0;		// number of "dimensions" in the query
	for (_i = query.begin(); _i != query.end(); _i++, ct++) {
	
		// if this term is forbidden, it doesn't belong in the vector space
		//
		if (_i->qualifier != '-') {

			// vector to store weights for this term
			intmap<float> weights(hash_init, 0.0);		

			// loop through postings list
			intmap<short>::iterator it;
			intmap<short>* slice = doc_postings[ct];

			if (slice != NULL) {

				for (it = slice->begin(); it != slice->end(); it++) {

					int docid = it.get_key();

					// set weight
					if (found_docs[docid]) {

						// note that # of filled elements in the slice is the
						// df!
						//
						// TODO: some sort of normalized tf here? might have to 
						//  use doc record to get maxtf
						// 
						float weight = (*it) * 1/log((float)(1 + slice->get_filled()));	
						weights[docid] = weight;
#ifdef VS_DEBUG
						cout << "setting weight vector for query term " << ct << " and document " << docid  << " to value " << weight << " (tf=" << (*it) << ", df=" << slice->get_filled() << ")" << endl;
#endif
					}
				}
			}
			mag_query++;

			// add this vector to the set 
#ifdef VS_DEBUG
			cout << "pushing weight vector for term " << ct << " to docVector" << endl;
#endif
			docVectors.push_back(weights);

		}
	}
	
	// this is to store similarity between every doc and the query
	//
	intmap<float> similarity (hash_init, 0.0);	

	// loop through the vectors, calculating their similarity 
	//
	float dot_prod = 0.0, mag_doc = 0.0, mag = 0.0;
   
	intmap<MYBOOL>::iterator fdi;
	for (fdi = found_docs.begin(); fdi != found_docs.end(); fdi++) {
		
		int docid = fdi.get_key();

		intmap<short>* doc_field_counts = field_counts[docid];

		if (*fdi == MYTRUE) {

#ifdef VS_DEBUG
			cout << "calculating similarity for docid " << docid << endl;
#endif

			// loop through weight vectors for each term
			//
			for (int y = 0; y < docVectors.size(); y++) {
	
#ifdef VS_DEBUG
				cout << " scanning weights vector for term " << y << endl;
#endif
				// add to accumulators if docid is represented in this weight
				// vectors
				//
				if (docVectors[y].exists(docid)) {

					// we are assuming query weights are 1 here
					dot_prod += docVectors[y][docid];
#ifdef VS_DEBUG
					cout << "  dot_prod = " << dot_prod << endl;
#endif
/*					mag_doc += docVectors[y][docid] * docVectors[y][docid];
#ifdef VS_DEBUG
					cout << "  mag_doc = " << mag_doc << endl;
#endif */
				}
			}

			// get final cosine normalized similarity expression, and add to 
			// similarity intmap.
			//
			mag_doc = doc_list[docid]->mag;	
			mag = sqrt((float)mag_query) * sqrt((float)mag_doc);

			// final vector space similarity
			float vectorsim = dot_prod/mag;

			// now get field similarity 
			//
			float sumcounts = 0;
			float sumweighted = 0;
			intmap<short>::iterator dfc;
			for (dfc = doc_field_counts->begin(); dfc != doc_field_counts->end(); dfc++) {
				float weight = field_weights[dfc.get_key()];

				/* it seems that I've repaired the field weightimg similarity
				   here, that is, it doesn't seem *too* paradoxical anymore.  
				   however, it still is actually *harmful* to a document
				   to have "extra" matches in a very non-valuable field.  

				   Really, to have the field weighting behave in a purely 
				   relative manner, scalings should be relative to the set 
				   of all matching documents, not relative to where the matches
				   come from within a document.  perhaps we need the field 
				   weight similarity to be something like:

				   fieldsim(d) = (\sum_i fc_i(d) * fw_i(d))/(max_d(fieldsim(d)))

					the key here is that additional fields can only *help*, and
					we provide relative weightings by normalizing by the 
					best fieldweight.

					the drawback to this method is that if you were to add
					documents to the collection which matched a query, the 
					weights of the *other* matching documents could change.
					in other words, a weight is no longer unique to the 
					(document,query) pair, but is unique to the
					(documents_matching(query),query) pair (one element of
					which is a set!)

				   */

				//sumcounts += SQUARE(*dfc);
				//sumweighted += SQUARE(weight * (float)(*dfc));

				/* this double-log suppresses the effect of high counts in
				   field weights. */ 

				float scaled_dfc = log(1 + log(1 + (float)*dfc));
				sumcounts += scaled_dfc;
				sumweighted += weight * scaled_dfc;
			}
			//float fieldsim = sqrt(sumweighted)/sqrt(sumcounts);
			float fieldsim = sumweighted/sumcounts;

			//_log->lprintf(logger::DEBUG, "similarity for document %s: fieldsim = %f, vectorsim = %f, similarity = %f\n", get_docname(docid).c_str(), fieldsim, vectorsim, fieldsim*vectorsim);

			// calculate final similarity
			//
			similarity[docid] = fieldsim * vectorsim;
	
#ifdef VS_DEBUG
			cout << " setting similarity for " << docid << " to " << similarity[docid] << endl;
#endif

			// reset accumulators, etc, for next doc vector
			dot_prod = 0.0, mag_doc = 0.0, mag = 0.0;
		}

		// free the doc_field_counts vector, while we're here
		delete doc_field_counts;
	}

	// build a list of ranked results and a map of ranks to documents which 
	// have that rank.
	//
	rankmm rank_docid_map((int)similarity.get_filled()/5);
	vector<float> ranks((int)similarity.get_filled()/5);
	
	int r = 0;
	intmap<float>::iterator si;
	for (si = similarity.begin(); si != similarity.end(); si++) {
		int docid = si.get_key();
		if (*si > 0.0) {
			ranks.push_back(*si);
			rank_docid_map.add(*si, docid);

			r++;
			nmatches++;
		}
	}

	// use the STL introspective sort. this could be improved upon further 
	// by using a radix sort, since we know all of our ranks lie in a fixed
	// range.
	//
	sort(ranks.begin(), ranks.end());

	// generate results list, minding any limit that may have been set
	//
	vector<query_result> results(limit == -1 ? nmatches : limit);	
	int count = 0;
	float lastrank = -1;
	for (int i = ranks.size()-1; i >= 0; i--) {

		float rank = ranks[i];
		if (rank == lastrank) continue;

		vector<int>* docs = rank_docid_map[rank];

		if (docs != NULL) {
			for (int j = 0; j < docs->size(); j++) {

				results[count].docID = get_docname((*docs)[j]);
				results[count].sim = rank;

				count++;
				
				if (limit != -1 && count == limit) break;	
			}
		}

		if (limit != -1 && count == limit) break;

		lastrank = rank;
	}

	// set limit to actual number of matches in the corpus
	limit = nmatches;
	
	// and return results records
	return results;
}

/*
void vector_search::print() {

	stem.print();
	cout << "\n";
	int idx;
	for (idx=0; idx<capacity; idx++) {
		if (_keys[idx]!="") {
			cout << "vector_search::_keys[" << idx << "] = " << _keys[idx]
				 << "; postList[" << idx << "] contains " << postList[idx].get_numDocs()
				 << " node: \n";
			if (postList[idx].is_empty())
				cout << "NULL\n";
			else {
				vector<posting_list>::iterator _i=&postList[idx];
				postList[idx].print();
			}
		}
	}
	cout << "\n";
	docList.print();
}
*/

/*
void vector_search::revision_add(vector<string> text, const string _docName, 
								  const string _tagName) {

	char buf[20];
	int read_pos, write_pos, num_revisions, revision_size;

	fstream file;
	file.open(FILE_NAME.c_str(), ios::in | ios::out | ios::binary);

	//get number of bytes in snapshot
	file.seekg(0);
	file.read(buf, sizeof(string));
	int snapshot_size = atoi(buf);

	//get number of revisions (just for updating)
	read_pos = snapshot_size;
	file.seekg(read_pos);
	file.read(buf, sizeof(string));
	num_revisions = atoi(buf);
	read_pos+=sizeof(string);

	//increment and rewrite
	num_revisions++;
	write_pos = snapshot_size;
	file.seekp(write_pos);
	file.write((char*)_itoa(num_revisions, buf, 10), sizeof(string));
	write_pos+=sizeof(string);

	//get number of bytes in revision data
	int revSize_pos = read_pos;
	file.read(buf, sizeof(string));
	revision_size=atoi(buf);
	read_pos+=sizeof(string);

	//find end of revision data
	write_pos=read_pos+revision_size;
	file.seekp(write_pos);

	//write char 'a' for add
	char* char_a = new char('a');
	file.write(char_a, sizeof(char));
	write_pos+=sizeof(char);

	//save space to write size of this entry
	int thisSize_pos=write_pos;
	write_pos+=sizeof(string);

	char* dum = new char[sizeof(string)*(2+text.size())];
	char* array_pos=dum;

	//write _docName and _tagName into dum
	file.seekp(write_pos);
	memcpy((void*)array_pos, (void*)_docName.c_str(), sizeof(string));
	array_pos+=sizeof(string);
	memcpy((void*)array_pos, (void*)_tagName.c_str(), sizeof(string));
	array_pos+=sizeof(string);

	int idx;
	for (idx=0; idx<text.size(); idx++) {
		
		char* temp = (char*)text[idx].c_str();		//read in string at from[idx]
		//count letters in string	
		int word_size;
		for (word_size=0; temp[word_size]!='\0'; word_size++) {}
		word_size++;			//for null_char

		memcpy((void*)array_pos, (void*)temp, word_size);		//add word to buffer
		array_pos+=word_size;

	}
	int file_size=array_pos-dum;

	//write contents of array to disk
	file.write(dum, file_size);

	//write size of *this* add revision data 
	file.seekp(thisSize_pos);
	file.write((char*)_itoa(file_size, buf, 10), sizeof(string));

	//go back and rewrite number of bytes in revision data - this includes revision type char
	file.seekp(revSize_pos);
	file.write((char*)_itoa(revision_size+file_size+sizeof(char), buf, 10), sizeof(string));
}


void vector_search::revision_remove(const string _docName, const string _tagName) {

	char buf[20];
	int read_pos, write_pos, num_revisions, revision_size;

	fstream file;
	file.open(FILE_NAME.c_str(), ios::in | ios::out | ios::binary);

	//get number of bytes in snapshot
	file.seekg(0);
	file.read(buf, sizeof(string));
	int snapshot_size = atoi(buf);

	//get number of revisions (just for updating)
	read_pos = snapshot_size;
	file.seekg(read_pos);
	file.read(buf, sizeof(string));
	num_revisions = atoi(buf);
	read_pos+=sizeof(string);

	//increment and rewrite
	num_revisions++;
	write_pos = snapshot_size;
	file.seekp(write_pos);
	file.write((char*)_itoa(num_revisions, buf, 10), sizeof(string));
	write_pos+=sizeof(string);

	//get number of bytes in revision data
	int revSize_pos = read_pos;
	file.read(buf, sizeof(string));
	revision_size=atoi(buf);
	read_pos+=sizeof(string);

	//find end of revision data
	write_pos=read_pos+revision_size;
	file.seekp(write_pos);

	//write char 'r' for add
	char* char_r = new char('r');
	file.write(char_r, sizeof(char));
	write_pos+=sizeof(char);

	//no need to write size of remove data - it will always = 2*sizeof(string)
	char* dum = new char[2*sizeof(string)];
	char* array_pos=dum;

	//write _docName and _tagName into dum
	memcpy((void*)array_pos, (void*)_docName.c_str(), sizeof(string));
	array_pos+=sizeof(string);
	memcpy((void*)array_pos, (void*)_tagName.c_str(), sizeof(string));
	array_pos+=sizeof(string);

	//write array to file
	file.write(dum, 2*sizeof(string));

	//go back and rewrite number of bytes in revision data - this includes revision type char
	file.seekp(revSize_pos);
	file.write((char*)_itoa(revision_size+(2*sizeof(string))+sizeof(char), buf, 10), sizeof(string));
}

void vector_search::writeDisk() {

	map<int, int> write_map;

	int node_num=0;
	char buf[20];
	int file_size;

	fstream file;
	file.open(FILE_NAME.c_str(), ios::out | ios::binary);

	//save space to write total size of snapshot
	int totalSize_end = 0;
	totalSize_end+=sizeof(string);

	int stem_end = stem.writeDisk(totalSize_end, file);

	int term_end = writeHash(stem_end, file);

	//DO WE NEED THIS HERE????
	//write numDocs - size of docList
	int numDocs_end = term_end;
	file.write((char*)_itoa(numDocs, buf, 10), sizeof(string));
	numDocs_end+=sizeof(string);

	//write capacity of docList
	int capacity_end = numDocs_end;
	file.write((char*)_itoa(docList.get_capacity(), buf, 10), sizeof(string));
	capacity_end+=sizeof(string);

	int post_pos = capacity_end;

	//write contents of posting_list to file
	char* null_char = new char('\0');

	//save space to write byte size of postList
	file.seekp((int)file.tellp()+sizeof(string));
	post_pos+=sizeof(string);

	//DO WE NEED THIS HERE???
	//write capacity size of postList
	file.write((char*)_itoa(postList.capacity(), buf, 10), sizeof(string));
	post_pos+=sizeof(string);

	//enter posting_node info
	int idx;
	for (idx=0; idx<postList.capacity(); idx++) {
		if (postList[idx].is_empty()) {
			file.write(null_char, sizeof(char));
			post_pos++;
		}
		else 
			post_pos = postList[idx].writeDisk(post_pos, file, write_map, node_num);
	}

	//go back and write file_size 
	file_size = post_pos-(term_end+3*sizeof(string));
	file.seekp(capacity_end);
	file.write((char*)_itoa(file_size, buf, 10), sizeof(string));

	//docList returns the point at which snapshot writing stops
	int snapshot_size = docList.writeDisk(post_pos, file);
	
	//write number of addendums to snapshot - right now that = 0
	file.write((char*)_itoa(0, buf, 10), sizeof(string));

	//write size of addendum list - again, this = 0
	file.write((char*)_itoa(0, buf, 10), sizeof(string));

	//now go back to beginning and write size of snapshot	
	file.seekp(0);
	file.write((char*)_itoa(snapshot_size, buf, 10), sizeof(string));

	file.close();
}

void vector_search::readDisk() {

	map<int, int> read_map;
	int node_num=0;

	char buf[20];
	int file_size;
//	int capacity;

	fstream file;
	file.open(FILE_NAME.c_str(), ios::in | ios::binary);

	//skip over total size of snapshot
	file.seekg((int)file.tellg()+sizeof(string));
	int totalSize_end = 0;
	totalSize_end+=sizeof(string);

	int stem_end = stem.readDisk(totalSize_end, file);

	int term_end = readHash(stem_end, file);

	//read numDocs - size of docList
	int numDocs_end = term_end;
	file.read(buf, sizeof(string));
	numDocs = atoi(buf);
	numDocs_end+=sizeof(string);

	//read capacity of docList - need this to resize docList before postList additions
	int capacity_end = numDocs_end;
	file.read(buf, sizeof(string));
	int doc_capacity = atoi(buf);
	capacity_end+=sizeof(string);

	//set docList capacity
	docList.set_capacity(doc_capacity);

	int post_pos = capacity_end;

	//read in file_size as string, store as int - discard, don't need for this function
	file.seekg(post_pos);
	file.read(buf, sizeof(string));
	file_size=atoi(buf);

	//read in size of postList vector
	file.read(buf, sizeof(string));
	file_size=atoi(buf);

	//increment position pointer
	post_pos+=2*sizeof(string);

	//retrieve posting_node info
	int idx;
	for (idx=0; idx<postList.capacity(); idx++) {
		if (file.peek()!='\0') {
			pair<vector<posting_node*>, int> result = postList[idx].readDisk(post_pos, file, read_map, node_num);
			post_pos = result.second;
			vector<posting_node*> nodes = result.first;
			int g;
			for (g=0; g<nodes.size(); g++)
				docList.read_add(nodes[g]);
		}
		else {
			file.seekg((int)file.tellg()+sizeof(char));
			post_pos+=sizeof(char);
		}			
	}

	int doc_end = docList.readDisk(post_pos, file);

	//read in number of revisions
	file.read(buf, sizeof(string));
	int num_revisions = atoi(buf);
	int numRev_end = doc_end+sizeof(string);

	//skip over size of revision list
	file.read(buf, sizeof(string));
	int rev_size = atoi(buf);
	int sizeRev_end = numRev_end+sizeof(string);

	int rev_end = sizeRev_end;

	//read in each revision
	int ct;
	for (ct=0; ct<num_revisions; ct++)
		rev_end = process_revision(file, rev_end);

	file.close();
}

int vector_search::process_revision(fstream& file, int start_pos) {

	char* func_char=new char;

	file.seekg(start_pos);
	file.read(func_char, sizeof(char));
	if (*func_char=='a') 
		return read_add(file, start_pos+sizeof(char));
	else {
		assert(*func_char=='r');
		return read_remove(file, start_pos+sizeof(char));
	}
}

int vector_search::read_add(fstream& file, int start_pos) {

	char buf[20];
	//int vector_size, data_size;
	int data_size;
	char* doc_buf = new char[sizeof(string)];
	char* tag_buf = new char[sizeof(string)]; 
	string docName, tagName;
	vector<string> text;

	file.seekg(start_pos);

	//read size of add revision data - size of all strings in text + docName and tagName
	file.read(buf, sizeof(string));
	data_size=atoi(buf);

	char* dum = new char[data_size];
	char* array_pos=dum;

	//read in data from disk
	file.read(dum, data_size);
	
	//read docName and tagName from dum
	memcpy((void*)doc_buf, (void*)array_pos, sizeof(string));
	docName=(string)doc_buf;
	array_pos+=sizeof(string);
	memcpy((void*)tag_buf, (void*)array_pos, sizeof(string));
	tagName=(string)tag_buf;
	array_pos+=sizeof(string);

	int num_words=0;
	while (array_pos-dum<data_size) {
		int word_size;
		for (word_size=0; *(array_pos+word_size)!='\0'; word_size++) {}	//count letters in this word
		word_size++;				//to count null_char

		char* word_buf = new char[word_size];			
		memcpy((void*)word_buf, (void*)array_pos, word_size);	//copy word into word_buf
		text.push_back((string)word_buf);		//add to to
				
		array_pos+=(word_size);		//increment pos, ignore null_char
		num_words++;
	}

	add(text, docName, tagName);

	return start_pos+data_size;
}

int vector_search::read_remove(fstream& file, int start_pos) {

	string docName, tagName;
	char* doc_buf = new char[sizeof(string)];
	char* tag_buf = new char[sizeof(string)]; 

	//no need to read size of remove data - it will always = 2*sizeof(string)
	char* dum = new char[2*sizeof(string)];
	char* array_pos=dum;

	file.seekg(start_pos);
	file.read(dum, 2*sizeof(string));

	//write _docName and _tagName into dum
	memcpy((void*)doc_buf, (void*)array_pos, sizeof(string));
	docName=(string)doc_buf;
	array_pos+=sizeof(string);
	memcpy((void*)tag_buf, (void*)array_pos, sizeof(string));
	tagName=(string)tag_buf;
	array_pos+=sizeof(string);

	remove_elem(docName, tagName);

	return start_pos+(2*sizeof(string));
}



*/

