//global.cpp

#include "global.h"
#include <vector>
#include <math.h>

char* _itoa(int num, char* buf, int radix) {

	vector<char> foo;

	//determine sign, remove if negative
	if (num<0) {
		foo.push_back('-');
		num*=-1;
	}

	//find # digits in num
	int num_digits;
	for (num_digits=1; num/(int)(pow(radix, num_digits)) > 0; num_digits++);

	//find char value of each digit in num
	int idx=0;
	int ct;
	for (ct=num_digits-1; idx<num_digits; idx++, ct--) {
		foo.push_back((char)((num/(int)(pow(radix, ct)))+48));
		num=num%(int)(pow(radix, ct));
	}

	//write foo contents into buf
	for (ct=0; ct<foo.size(); ct++)
		buf[ct]=foo[ct];
	buf[ct]='\0';
	return buf;
}


