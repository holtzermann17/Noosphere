/* data.h UPDATED 12-17-2002 BY Joel Irby */

/*
 * struct href
 * 
 * int color[3]:
 * 	Array contains red, green, and blue values (in that order) to be
 * 	associated with hinted regions withing a PNG.
 *
 * char url[256]
 * 	Character string containing a string to be associated with hinted
 * 	regions withing a PNG.
 */

struct href {
	int color[3];
	char url[256];
	struct href *next;
};

/*
 * struct coord
 *
 * int bbox[4]:
 * 	Array with two sets of x,y coordinates to form a bounding box around a
 * 	region wihtin a PNG.
 * 	
 * struct href *htable:
 * 	Pointer to an href to be associated with the afore mentioned bounding box.
 */

struct coord {
	int bbox[4];
	struct href *htable;
	struct coord *next;
};
