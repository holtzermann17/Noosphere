/******************************************************************************
 
 Hashing base declarations.

******************************************************************************/

#ifndef __HASH_H_
#define __HASH_H_

using namespace std;

// a table of good hashing primes
//
#ifdef PUT_PRIMES_HERE
unsigned int PRIMES[] = {3, 7, 13, 23, 53, 97, 193, 389, 769, 1543, 3079,
	6151, 12289, 24593, 49157, 98317, 196613, 393241, 786433, 1572869, 3145739, 
	6291469, 12582917, 25165843, 50331653, 100663319, 201326611, 402653189, 
	805306457, 1610612741, 0};  // (null-terminated)
#else
extern unsigned int PRIMES[];
extern unsigned int INDICES[];
#endif 

// adjust this if the above table changes size
#define MAX_PRIME_IDX 29 

// forward decl of function to find nearest prime in above table.
unsigned int nearest_prime_index ( int );

// forward decl of function to find table index from a prime
unsigned int prime_index ( int );

#endif
