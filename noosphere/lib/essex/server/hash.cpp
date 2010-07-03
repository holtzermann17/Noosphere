/******************************************************************************
  
 Common hashing routines.

******************************************************************************/

// locate the extern PRIMES table here.
#define PUT_PRIMES_HERE 1

#define abs(x) (x>0?x:(-x))

#include "hash.h"

// get the index of a prime, given the prime
//
unsigned int prime_index ( int p ) {

	int i = -1;

	while(PRIMES[++i] != p && PRIMES[i] != 0);

	return i;
}

// get the index of the nearest prime to n in the PRIMES list
//
unsigned int nearest_prime_index ( int n ) {
	
	unsigned int best_index = 0;
	int diff = n - PRIMES[0];

	int i = 0;

	while (PRIMES[++i]) {
	
		int thisdiff = n - PRIMES[i];

		if (abs(thisdiff) < abs(diff)) {
	
			diff = thisdiff;
			best_index = i;
		} 
		
		// if the diff starts going up, we've already found the closest prime
		else {
			break;
		}
	}

	return best_index;
}
