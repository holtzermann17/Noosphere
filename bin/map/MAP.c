/* MAP.c UPDATED 12-17-2002 BY Joel Irby */

#include <stdio.h>	// fscanf(); snprintf();
#include <string.h>	// strcpy(); strcat();
#include <stdlib.h>
#include <time.h>	// for magick
#include <sys/types.h>	// for magick
#include <magick/api.h>	// image magick api
#include "data.h"	// href and coord structs

struct href* file_create(char[], int*);
struct href* pm_check(int, PixelPacket*, struct href*);
int box_check(struct coord*, struct href*, int[]);
int cleanup(char[]);

int main (int argc, char *argv[])
{
	unsigned int height, width, x, y, run, tbox[4];
	int pages, count;
	char tmp_name[256];
	FILE *MAP;
	struct href *htable, *hhead = NULL;
	struct coord *btable, *bhead = NULL;

	ExceptionInfo exception;
	ImageInfo *PM_INFO;
	Image *PM;
	PixelPacket PM_PIXEL;
	
	if (argc == 1) {
		printf("requires input file argument\n");
		return 0;
	} else {
		// FIRST GENERATE OUTPUT FROM ORIGIONAL TEX FILE AND CLEANUP AFTERWORDS
		if ((hhead = file_create(argv[1], &pages)) == NULL)
			return 0;

		// INITIALIZE IM AND HINTED PNG IMAGE
		InitializeMagick(*argv);
		GetExceptionInfo(&exception);
		PM_INFO = CloneImageInfo((ImageInfo *) NULL);

		// TRY TO CREATE FILE FOR MAP TAG OUTPUT
//		strcpy(tmp_name, argv[1]);
//		strcat(tmp_name, ".map");
//		MAP = fopen(tmp_name, "w");
//		if (MAP == NULL) {
//			printf("could not create .map file\n");
//			return 0;
//		}

		for (count = 1; count <= pages; count++) {
	
			// TRY TO CREATE FILE FOR MAP TAG OUTPUT
			snprintf(tmp_name, 256, "%s%02d.map", argv[1], count);
			if ((MAP = fopen(tmp_name, "w")) == NULL) {
				printf("could not create .map file\n");
				return 0;
			}
	
			// READ IMAGE
			snprintf(tmp_name, 256, "%s-PREMAP%02d.png", argv[1], count);
			strcpy(PM_INFO->filename, tmp_name);
			PM = ReadImage(PM_INFO, &exception);
	
			// GET WIDTH AND HEIGHT OF HINTED IMAGE
			PM_INFO->ping = 1;
			PM = ReadImage(PM_INFO, &exception);
			height = PM->rows;
			width = PM->columns;
	
			//printf("%d %d\n", height, width);	
			
			// REREAD IMAGE DATA WITH PING SET TO 0 (WILL BE CURRUPT OTHERWISE)
			PM_INFO->ping = 0;
			PM = ReadImage(PM_INFO, &exception);
	
			// BEGIN SCANNING IMAGE
			for(x = 0, y = 0; y < height;) {
				PM_PIXEL = AcquireOnePixel(PM, x, y, &exception);
				if ((htable = pm_check(1, &PM_PIXEL, hhead)) != NULL) {
					tbox[0] = x; tbox[1] = y; run = y;
					do {
						x++;
						PM_PIXEL = AcquireOnePixel(PM, x, run, &exception);
					} while(pm_check(0, &PM_PIXEL, htable));
					x--;
					do {
						run++;
						PM_PIXEL = AcquireOnePixel(PM, x, run, &exception);
					} while(pm_check(0, &PM_PIXEL, htable));
					run--;
					tbox[2] = x; tbox[3] = run;
	
					if (box_check(bhead, htable, tbox) == 0) {
						btable = (struct coord *)malloc(sizeof(struct coord));
						btable->htable = htable;
						btable->bbox[0] = tbox[0];
						btable->bbox[1] = tbox[1];
						btable->bbox[2] = tbox[2];
						btable->bbox[3] = tbox[3];
						btable->next = bhead;
						bhead = btable;
						//printf("added box\n");
					}
				}
					
				x++;
				if (x == width) {x = 0; y++;}
			}
		
			fprintf(MAP, "<map name=\"ImageMap%d\">\n", count);
			for(btable = bhead; btable; btable = btable->next)
				fprintf(MAP, "<area shape=\"rect\" coords=\"%d,%d,%d,%d\" href=\"%s\"/>\n",
						btable->bbox[0], btable->bbox[1]-1, btable->bbox[2], btable->bbox[3]+1, btable->htable->url);
			fprintf(MAP, "</map>\n");
			for(btable = bhead; btable; btable = bhead) {
				bhead = btable->next;
				free(btable);
			}
	
			fclose(MAP);
		}
	
	}

	DestroyImage(PM);
	DestroyImageInfo(PM_INFO);
	DestroyExceptionInfo(&exception);

	cleanup(argv[1]);
	
	return 1;
}
