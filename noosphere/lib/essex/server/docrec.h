#ifndef _DOCREC_H
#define _DOCREC_H

#include "intmap.h"

// a document record (element of the "forward" index)

typedef struct doc_rec {

	intmap<char>* words;	// vector-form of the contents of the document

	float mag;	// place to cache document magnitude, so we dont have to 
	 			// calculate this at query-time

} docrec;

#endif
