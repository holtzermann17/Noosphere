/* LOGIC.c UPDATED 12-17-2002 BY Joel Irby */

#include <stdio.h>
#include <time.h>	// for magick/api.h
#include <sys/types.h>	// for magick/api.h
#include <magick/api.h>	// for PixelPacket
#include "data.h"	// for href and bbox structs

/*
 * struct href* pm_check(int, PixxelPacket, struct href*)
 * 	This function will check to see if a pixel contained in *PP matches a
 * 	particular row in the simple href linked list. 
 * 	
 * INPUT:
 * 	Intiger 'scan' will determine how the function accesses the 'href' list. 
 *	PixelPacket pointer contianing information on the current pixel of an
 *	image being read by libmagick.
 *	Struct Href pointer which is to be set to the head of the href list if
 *	'scan' is non-zero. Otherwise only the current row in the list is
 *	checked against the current pixel. 
 *	
 * RETURN:
 * 	Returns a pointer to a position in an href list if match was found.
 * 	Otherwise a NULL pointer is returned.
 */

struct href* pm_check(int scan, PixelPacket *PP, struct href *htable) {
	int color[3];
	
	if (!scan) {
		color[0] = ((htable->color[0]/255.0)*65535.0);
		color[1] = ((htable->color[1]/255.0)*65535.0);
		color[2] = ((htable->color[2]/255.0)*65535.0);

		if ((PP->red == color[0]) && (PP->green == color[1]) && (PP->blue == color[2]))
			return htable;
		else 
			return NULL;
	} else {
		while(htable) {
			color[0] = ((htable->color[0]/255.0)*65535.0);
			color[1] = ((htable->color[1]/255.0)*65535.0);
			color[2] = ((htable->color[2]/255.0)*65535.0);
			
			if ((PP->red == color[0]) && (PP->green == color[1]) && (PP->blue == color[2]))
				return htable;
			else
				htable = htable->next;
		}
		return NULL;
	}
}

/*
 * int box_check(struct coord*, struct href*, int[])
 * 	This function checks if the input coordinates have the same href
 * 	association as any other instances in the 'coord' list. If they do the
 * 	function will check to see if they exist in the same space on the x-axis
 * 	(if they exist on the same rows in the image). If they do, the function
 * 	will adjust the existing coordinates to include the input coordinates. 
 *
 * INPUT:
 * 	Struct Coord pointer to the head of the list (to be scanned through).
 * 	Struct Href pointer to the hint and string associated with the input.
 * 	Intiger array to have four members being two sets of x,y coordinates for
 * 	defining a bounding box.
 *
 * RETURN:
 * 	Returns non-zero if a row in the 'coord' list was revised. Otherwise
 * 	zero is returned.
 */

int box_check(struct coord *btb, struct href *htb, int tbox[]) {
	while(btb) {
		if (htb == btb->htable) {
			if (((tbox[1] >= btb->bbox[1]) && (tbox[1] <= btb->bbox[3])) || ((btb->bbox[1] >= tbox[1]) && (btb->bbox[1] <= tbox[3]))) {
				if (tbox[0] < btb->bbox[0])
					btb->bbox[0] = tbox[0];
				if (tbox[1] < btb->bbox[1])
					btb->bbox[1] = tbox[1];
				if (tbox[2] > btb->bbox[2])
					btb->bbox[2] = tbox[2];
				if (tbox[3] > btb->bbox[3])
					btb->bbox[3] = tbox[3];
				//printf("revised bbox\n");
				return 1;
			}
		}
		btb = btb->next;
	}
	return 0;
}
