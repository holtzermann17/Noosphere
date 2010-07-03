/******************************************************************************

 Implementation for posting list.

******************************************************************************/

#include "posting_list.h"

// get the document id from a compact posting entry record
//
int posting_list::get_docid(postentry& pe) {

#ifdef RELAX_POSTINGS
	return (pe.docid);
#else
	return (pe.docid + (pe.docid_high<<16));
#endif
}

// set the document id for a compact posting entry record. 
//
void posting_list::set_docid(postentry& pe, int _docid) {

#ifdef RELAX_POSTINGS
	pe.docid = (unsigned int)_docid ;
#else
	pe.docid = ((short*)&_docid)[0];
	pe.docid_high = ((char*)&_docid)[2];
#endif
}

// get the count for a compact posting entry record
//
int posting_list::get_count(postentry& pe) {
	
#ifdef RELAX_POSTINGS
	return (pe.count);
#else
	// mask out and add 1 to represent 1..16 rather than 0..15
	return ((pe.count_and_tagid & 0x0f)+1);
#endif
}

// get the tagid for a compact posting entry record
//
int posting_list::get_tagid(postentry& pe) {
	
#ifdef RELAX_POSTINGS
	return (pe.tagid);
#else
	return ((pe.count_and_tagid & 0xf0)>>4);
#endif

}

// set the count for a compact posting entry record
//
void posting_list::set_count(postentry& pe, int _count) {
#ifdef RELAX_POSTINGS
	pe.count = (unsigned char)_count ;	
#else
	_count = _count > 16 ? 16 : _count;
	_count--;  // represent 1..16, not 0..15 
	pe.count_and_tagid = (pe.count_and_tagid & 0xf0) | _count;
#endif

}

// set the tagid for a compact posting entry record
//
void posting_list::set_tagid(postentry& pe, int _tagid) {
	
#ifdef RELAX_POSTINGS
	pe.tagid = (unsigned char) _tagid ;
#else
	_tagid = _tagid > 15 ? 15 : _tagid;
	pe.count_and_tagid = (pe.count_and_tagid & 0x0f) | (_tagid << 4);
#endif
}

// remove list entries for a docid.  this uses a binary search (we 
// assume the posting list is sorted by docid, ascending).
//
void posting_list::remove(int _docid) {

	// check position after last removal.  this is a shortcut in the case
	// we are unindexing an archive in indexed order.
	//
#ifdef SUPER_FAST_UNINDEXING
	int i = (last > -1 ? last : -1);
	int docid = (i > -1 ? get_docid(list[i]) : -1);
#else
	int i = -1;
	int docid = -1;
#endif

	// if we can't take the above shortcut, try to find where the docid is 
	// indexed using a binary search
	//
	if (docid != _docid) {

		int n = list.size();

		// unless there's only one item
		if (n == 1) {
			i = 0;
			docid = get_docid(list[0]);
		} 
		
		// the binary search
		else {
			int lower = 0; 
			int upper = n-1;
			do {
				i = lower + (n+1)/2 - 1;
				docid = get_docid(list[i]);

				if (_docid > docid) lower = i + 1;
				else upper = i - 1;

				n = upper - lower + 1;
			} while (docid != _docid && n>0);

		} 
	} 

#ifdef VS_DEBUG
	int removed = 0;
#endif

	// remove all nodes matching the docid at the current spot
	//
	if (docid == _docid) {

		// probe "upwards" from this position, removing nodes
		while (get_docid(list[i]) == _docid && i != list.size()) {
			list.erase(list.begin()+i);
#ifdef VS_DEBUG
			removed++;
#endif
		}
#ifdef SUPER_FAST_UNINDEXING
		last = i;
#endif

		i--;
		// probe "downwards" from this position
		while (get_docid(list[i]) == _docid && i>=0) {
			list.erase(list.begin()+i);
#ifdef VS_DEBUG
			removed++;
#endif
			i--;
#ifdef SUPER_FAST_UNINDEXING
			last--;
#endif
		}
	}

#ifdef VS_DEBUG
	if (removed == 0) {
		cout << "posting_list::remove : FAILED TO FIND RECORDS FOR " << _docid << "!!!" << endl;
	}
#endif
}

// get the percentage of postings list records which are using their tag lists
// (always zero for this implementation)
// 
float posting_list::get_taglist_frac() {

	int total = 0;
	int used = 0;
	
	return 0;
}

// add a word instance to the postings list
//
void posting_list::add(int _docid, int _tagid) {

	// see if we can just increment a count
	// loop backwards, since we append the list and records for the same
	// docid will likely be together.
	//
	for (int i = list.size() - 1; i >= 0; i--) {

		// remove this early-out if the documents are not indexed together 
		// by docid (this is ok unless the same document can be "appended to"
		// later on.  you can avoid this for updates by un-indexing first,
		// THEN re-indexing the whole updated doc).
		//
		if (get_docid(list[i]) != _docid) break;

		// if we're still here, docid matches, see if tagid also matches.
		//
		if (get_tagid(list[i]) == _tagid) {
			set_count(list[i], get_count(list[i])+1);
			return;
		} 
		else {
			// remove this early out if tags aren't guaranteed to be together.
			break;
		}
	}

	// otherwise add a new entry
	//
	postentry n;
	set_docid(n, _docid);
	set_tagid(n, _tagid);
	set_count(n, 1);

	list.push_back(n);
}

// get docid => count map from the list.  if _tagID != -1, use it to narrow
// the selection.
//
// utilize a field weights hash to determine weightings of what we return.
//
intmap<short>* posting_list::get_list(int collection_size, int num_tags, int _tagid, intmap<intmap<short>*>& field_counts) {
	
	// make a return hash vec at a strategic size
	//
	// the value .00797 comes from experiment; each document contributes 
	// approximately .00797 entries to each postings list
	//
	int predicted_size = int(0.00797*collection_size);
	int init_size = int(10 > 2*predicted_size ? 10 : 2*predicted_size);

	intmap<short>* r = new intmap<short>(init_size, 0);

	// loop through the postings list and check for postings entries that 
	// have a matching tag.  sum all of these up (scaled by field weights),
	// grouped by docid.
	//
	vector<postentry>::iterator it;
	for (it = list.begin(); it != list.end(); it++) {

		int docid = get_docid(*it);
		int tagid = get_tagid(*it);

		if (_tagid == -1 || tagid == _tagid) {
			
			int occurrences = get_count(*it);

			// add to return map
			(*r)[docid] += occurrences;

			// update field counts for the document
			intmap<short>* doc_field_counts;
			if (!field_counts.exists(docid)) {
				field_counts[docid] = new intmap<short> (2*num_tags, 0);	
			} 
			doc_field_counts = field_counts[docid];
			(*doc_field_counts)[tagid] += occurrences;

#ifdef VS_DEBUG
			cout << "posting_list::get_list : adding docid " << docid << " to slice" << endl;
#endif
		} 
#ifdef VS_DEBUG
		else {
			cout << "posting_list::get_list : not adding to slice, failed tagid match for docid " << docid << " and tagid " << _tagid << endl;
		}
#endif
	}

	return r;
}

/*
posting_list& inverted_index::operator=(posting_list _p) {

	head=_p.head;
	tail=_p.tail;
	numDocs=_p.numDocs;
	
	posting_node* temp=head;
	while (temp!=NULL) {
		temp->set_list(this);
		temp=temp->get_next();
	}
	return (*this);
}

posting_node* inverted_index::add() {

	if (head==NULL) {
		head=new posting_node(this);
		tail=head;
		numDocs++;
		return head;
	}
	else {
		posting_node* temp=new posting_node(this);
		tail->set_next(temp);
		temp->set_prev(tail);
		tail=temp;
		temp=NULL;
		numDocs++;
		return tail;
	}
}

//this should only be called if you know that _pN is part of the list
void inverted_index::remove(posting_node* _pN) {

	if (_pN->get_prev()==NULL) {
		if (_pN->get_next()==NULL) {	//_pN only element in list
			delete _pN;
			head=NULL;
			tail=NULL;
		}
		else {						//_pN at head of list
			head=_pN->get_next();
			head->set_prev(NULL);
			delete _pN;
		}
	}
	else {
		if (_pN->get_next()==NULL) {	//_pN at tail of list
			tail=_pN->get_prev();
			tail->set_next(NULL);
			delete _pN;
		}
		else {						//_pN anywhere else in list
			_pN->get_prev()->set_next(_pN->get_next());
			_pN->get_next()->set_prev(_pN->get_prev());
			delete _pN;
		}
	}
	numDocs--;
}

void inverted_index::print() {

	int ct=0;
	posting_node* idx;
	for (idx=head; idx!=NULL; idx=idx->get_next()) {
		cout << "\t posting_node[" << ct << "] contains: docID = " << idx->get_docID()
			 << "; tagID = " << idx->get_tagID() << "; count = " << idx->get_count()
			 << "; normFreq = " << idx->get_normFreq() << "\n";
		ct++;
	}
}


int inverted_index::writeDisk(int start_pos, fstream& file, 
							map<int, int>& write_map, int& node_num) {

	char buf[20];
	pair<map<int, int>::iterator, bool> map_test;

	//this allocates bytes for each node in the list minus its pointers
	int copy_size = sizeof(posting_node)-(sizeof(void*)+(2*sizeof(posting_node*)));
	char* dum = new char[numDocs*copy_size];
	char* pos = dum;
	posting_node* temp=head;

	while (temp!=NULL) {
		//copy contents into buffer
		memcpy((void*)pos, (void*)temp, copy_size);

		//map the node number to the address of this node
		map_test = write_map.insert(map<int, int>::value_type((int)temp, node_num));

		//check that a unique entry was made
		assert(map_test.second==true);

		//increment pointers, etc.
		temp=temp->get_next();
		node_num++;
		pos+=copy_size;
	}
	
	int file_size=pos-dum;

	//find starting point in file
	file.seekp(start_pos);

	//write the number of bytes in the buffer
	file.write((char*)_itoa(file_size, buf, 10), sizeof(string));

	//write the contents
	file.write((char*)dum, file_size);

	//return the new position at which to begin writing
	return start_pos+file_size+sizeof(string);
}

pair<vector<posting_node*>, int> inverted_index::readDisk(int start_pos, fstream& file, map<int, int>& read_map, int& node_num) {
	
	pair<map<int, int>::iterator, bool> map_test;
	vector<posting_node*> to_return;

	char buf[20];
	int file_size;
	int copy_size = sizeof(posting_node)-(sizeof(void*)+(2*sizeof(posting_node*)));

	//move read pointer to first byte in data
	file.seekg(start_pos);

	//read in file_size as a string, convert to int
	file.read(buf, sizeof(string));
	file_size=atoi(buf);

	//allocate temporary storage for data, read it in
	char* dum = new char[file_size];
	char* pos = dum;
	file.read(dum, file_size);

	int idx;
	for (idx=0; idx<file_size/copy_size; idx++) {
		
		posting_node* temp=add();
		memcpy((void*)temp, (void*)pos, copy_size);
		pos+=copy_size;
		to_return.push_back(temp);

		//add to read_map - node_num is index at which this node was read in,
		//(int) temp is its address for later assignment
		map_test = read_map.insert(map<int, int>::value_type(node_num, (int)temp));

		assert(map_test.second==true);

		node_num++;
	}

	//return the new position at which to begin writing
	return pair<vector<posting_node*>, int>(to_return, start_pos+file_size+sizeof(string));
}


*/


