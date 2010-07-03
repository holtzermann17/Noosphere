/*****************************************************************************
 *
 * configuration options
 *
 *****************************************************************************/

#ifndef _CONFIG_H_
#define _CONFIG_H_

using namespace std;

/* uncomment below to get some debug printing */

//#define VS_DEBUG 1

/* uncomment to make serial unindexing O(nm) (rather than O(nmlog m)), where
 * n is the number of documents being unindexed and m is the average number
 * of occurrences  */

//#define SUPER_FAST_UNINDEXING

/* uncomment below to log indexing events.  this will slow things down. */

//#define LOG_INDEXING

/* define relax postings list: allows 4 billion documents instead of 16.7 
 * million, 256 tf values instead of 16, and 256 tags instead of 16 */

//#define RELAX_POSTINGS 1

const int STEM_HASH_SIZE = 500;

#endif
