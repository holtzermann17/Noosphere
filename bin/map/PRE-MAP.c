/* PRE-MAP.c UPDATED 01-14-2003 BY Joel Irby */

#include <stdio.h>	// fscanf(); snprintf();
#include <string.h>	// strcpy(); strcat();
#include <stdlib.h>	// malloc();
#include <sys/types.h>	// fork();
#include <sys/wait.h>	// wait();
#include <unistd.h>	// execve();
#include "data.h"	// href struct

/*
 * struct href* parse_tex(char[])
 * 	The parse_tex function takes an input file (*IN_TEX) and parses it for
 * 	\htmladdnormallink tags and replaces them with various color tags to
 * 	allow for later parsing of the tex file and a search for the regions
 * 	that should be in place of the strings within the \htmladdnormallink
 * 	tags.
 *
 * INPUT:
 * 	Character arary to be the base name of of file document to be parsed.
 * 	EG: for file "Somefile.tex" use "Somefile".
 *
 * RETURN:
 * 	Returns a pointer to the head of a simple linked list of type 'href'.
 * 	The href struct is used to associate color regions with href tags. 
 * 	
 * CONSIDERATIONS:
 * 	This function will probably foul up the output if there are additional
 * 	tags within the text section of the \htmladdnormallink tag.
 * 	This funtion will strip C style slashes from the HREF portion of the
 * 	\htmladdnormallink tag, presuming they are escaping special characters.
 */

struct href* parse_tex(char name[], int *relay)
{
	int count, pos, scan, ref = 0, paren;
	int color[3] = {0, 0, 0};				// colors for href regions. 0 == red, 1 == green, 2 == blue
	float fcolor[3];
	char tmp_name[256];
	char tag[18], tag_text[128], tag_url[128];	
	FILE *IN_TEX = NULL, *OUT_TEX = NULL, *HI_TEX = NULL;
	struct href *table, *head = NULL;

	snprintf(tmp_name, 256, "%s.tex", name);
	IN_TEX = fopen(tmp_name, "r");
	if (IN_TEX == NULL) {
		printf("input file %s not available\n", tmp_name);
		return NULL;
	}

	snprintf(tmp_name, 256, "%s-PREMAP.tex", name);
	OUT_TEX = fopen(tmp_name, "w");
	if (OUT_TEX == NULL) {
		printf("could not create file %s\n", tmp_name);
		return NULL;
	}

	snprintf(tmp_name, 256, "%s-HI.tex", name);
	HI_TEX = fopen(tmp_name, "w");
	if (HI_TEX == NULL) {
		printf("could not create file %s\n", tmp_name);
		return NULL;
	}

	while (!feof(IN_TEX)) {
		scan = fgetc(IN_TEX);

		if (scan == '\\') {
			pos = ftell(IN_TEX);
			fgets(tag, 18, IN_TEX);
				
			if (strncmp(tag, "begin{document}", 15) == 0) {
				fseek(IN_TEX, pos, SEEK_SET);
				do {
					scan = fgetc(IN_TEX);
				} while (scan != '}');

				fprintf(OUT_TEX, "\\usepackage[dvips]{color}\n");
				fprintf(OUT_TEX, "\\setlength{\\fboxrule}{0mm}\n");
				fprintf(OUT_TEX, "\\setlength{\\fboxsep}{0mm}\n");
				fprintf(OUT_TEX, "\\begin{document}\n\n");
				
				fprintf(HI_TEX, "\\usepackage[dvips]{color}\n");
			//	fprintf(HI_TEX, "\\usepackage{soul}\n");		// OUTPUT TO USE SOUL FOR UNDERLINING
			//	fprintf(HI_TEX, "\\setul{.3ex}{.1ex}\n");		// OUTPUT TO USE SOUL FOR UNDERLINING
				fprintf(HI_TEX, "\\usepackage[normalem]{ulem}\n");	// OUTPUT TO USE ULEM FOR UNDERLINING
				fprintf(HI_TEX, "\\setlength{\\ULdepth}{.3ex}\n");	// OUTPUT TO USE ULEM FOR UNDERLINING
				fprintf(HI_TEX, "\\definecolor{HI}{rgb}{0,0,1}\n");
				fprintf(HI_TEX, "\\begin{document}\n\n");
			} else if (strncmp(tag, "ref", 3) == 0) {
				*relay += 1;
				fputc('\\', OUT_TEX);
				fputc('\\', HI_TEX);
				fseek(IN_TEX, pos, SEEK_SET);
			} else if (strncmp(tag, "eqref", 5) == 0) {
				*relay += 1;
				fputc('\\', OUT_TEX);
				fputc('\\', HI_TEX);
				fseek(IN_TEX, pos, SEEK_SET);
			} else if (strncmp(tag, "cite", 4) == 0) {
				*relay += 1;
				fputc('\\', OUT_TEX);
				fputc('\\', HI_TEX);
				fseek(IN_TEX, pos, SEEK_SET);
			} else if (strcmp(tag, "usepackage{color}") == 0) {
				// NOTE FOR FUTURE REVISION (12-19-2003). THIS
				// WILL ONLY COMMENT OUT THE CONFLICTING COLOR
				// PACKAGE IF THAT PACKAGE IS INITIALISED WITH
				// NO OPTIONS. REVISION SHOULD APPEND ANY
				// OPTIONS TO THE LINE INSTALLED BY THIS
				// PROGRAM.
				fputs("%\\", OUT_TEX);
				fputs("%\\", HI_TEX);
				fseek(IN_TEX, pos, SEEK_SET);
			} else if (strcmp(tag, "htmladdnormallink") == 0) {
				//GET HREF TAG TEXT
				do {
					scan = fgetc(IN_TEX);
				} while (scan != '{');
				for (count = 0, paren = 0; (((scan = fgetc(IN_TEX)) != '}') || (paren != 0)); count++) {
					tag_text[count] = scan;
					if (scan == '{') {++paren;}
					if (scan == '}') {--paren;}
				}
				tag_text[count] = '\0';

				// MAKE COLOR REFERENCES FOR HREF URL AND TEXT
				ref++;
				color[2]++;
				if (color[2] == 256) {
					color[2] = 0;
					color[1]++;
					if (color[1] == 256) {
						color[1] = 0;
						color[0]++;
					}
				}
				
				// PRINT HREF TEXT TO OUTPUT PREMAP TEX FILE WITH COLOR REFERENCES
				for (count = 0; count < 3; count++)
					fcolor[count] = color[count]/255.00;
				
				count = 0;
			//	fprintf(HI_TEX, "\\textcolor{HI}{\\ul{");	// OUTPUT TO USE SOUL FOR UNDERLINING
				fprintf(HI_TEX, "\\textcolor{HI}{\\uline{");	// OUTPUT TO USE ULEM FOR UNDERLINING
				do {
					fprintf(OUT_TEX, "\\definecolor{ref-%d}{rgb}{%f,%f,%f}",
							ref, fcolor[0], fcolor[1], fcolor[2]);
					fprintf(OUT_TEX, "\\colorbox{ref-%d}{\\textcolor{ref-%d}{",
							ref, ref);
					fprintf(HI_TEX, "\\mbox{");
					for(; tag_text[count] > 32; count++) {
						fputc(tag_text[count], OUT_TEX);
						fputc(tag_text[count], HI_TEX);
					}
					fprintf(OUT_TEX, "}}");
					fprintf(HI_TEX, "}");
					for(; (tag_text[count] <= 32) && (tag_text[count] != 0); count++) {
						fputc(tag_text[count], OUT_TEX);
						fputc(tag_text[count], HI_TEX);
					}
				} while(tag_text[count] != 0);
				fprintf(HI_TEX, "}}");
				
				// GET HREF TAG URL
				do {
					scan = fgetc(IN_TEX);
				} while (scan != '{');
				for (count = 0, paren = 0; (((scan = fgetc(IN_TEX)) != '}') || (paren != 0)); count++) {
					tag_url[count] = scan;
					if (scan == '{') {++paren;}
					if (scan == '}') {--paren;}
				}
				tag_url[count] = '\0';

				// PRINT HREF TAG URL WITH COLOR IDENTIFIERS
				table = (struct href *)malloc(sizeof(struct href));
				table->color[0] = color[0];
				table->color[1] = color[1];
				table->color[2] = color[2];
				for(scan = 0, count = 0; tag_url[scan] != '\0'; scan++, count++) {
					if (tag_url[scan] == '\\')
						scan++;
					table->url[count] = tag_url[scan];					
				}
				table->url[count] = tag_url[scan];
				table->next = head;
				head = table;
			} else {
				tag[0] = scan;
				fwrite(tag, 1, 1, OUT_TEX);
				fwrite(tag, 1, 1, HI_TEX);
				fseek(IN_TEX, pos, SEEK_SET);
			}
		} else {
			tag[0] = scan;
			fwrite(tag, 1, 1, OUT_TEX);
			fwrite(tag, 1, 1, HI_TEX);
		}
	}
	fclose(IN_TEX);
	fclose(OUT_TEX);
	fclose(HI_TEX);
	return head;
}

/* 
 * struct href* file_create(char[])
 * 	This function calls the parse_tex() function and makes additional system
 * 	calls to generate the output PNG file to be searched for "hinted
 * 	regions".
 *
 * INPUT:
 *	Character arary to be the base name of of file document to be parsed and
 *	used for additonal PREMAP file creation.
 *	EG: for file "Somefile.tex" use "Somefile".
 *	
 * RETURN:
 * 	Returns a pointer to the head of a simple linked list of type 'href'.
 * 	The href struct is used to associate color regions with href tags. 
 *
 * CONSIDERATIONS:
 * 	Function does not check return status of system processes.
 */

struct href* file_create (char name[], int *p) {
	char tmp_name[512];
	pid_t child;
	int pages, status, relay = 0;
	FILE *CHECK;
	struct href *hhead;

	if ((hhead = parse_tex(name, &relay)) == NULL)
		return NULL;

	printf("MAP found %d tags that require resolving references.\n", relay);
	
	// WAIT FOR FILE TO BECOME READABLE
	if ((child = fork()) == 0) {
		snprintf(tmp_name, 512, "%s-PREMAP.tex", name);
		while((CHECK = fopen(tmp_name, "r+")) == NULL) {}
		fclose(CHECK);
		exit(1);
	}
	wait(&status);
	
	// PARSE TEX FILE
	if ((child = fork()) == 0) {
		snprintf(tmp_name, 512, "/usr/bin/latex -interaction=batchmode %s-PREMAP.tex", name);
		execl("/bin/sh", "/bin/sh", "-c", tmp_name, NULL);
		exit(1);
	}
	wait(&status);

	// RUN MULTIPLE IF RELAY HAS BEEN SET POSITIVE
	if (relay > 0) {
		if ((child = fork()) == 0) {
			snprintf(tmp_name, 512, "/usr/bin/latex -interaction=batchmode %s-PREMAP.tex", name);
			execl("/bin/sh", "/bin/sh", "-c", tmp_name, NULL);
			exit(1);
		}
		wait(&status);
	}

	// CONVERT DVI TO PS
	if ((child = fork()) == 0) {
		snprintf(tmp_name, 512, "/usr/bin/dvips -t letter -f %s-PREMAP.dvi > %s-PREMAP.ps", name, name);
		execl("/bin/sh", "/bin/sh", "-c", tmp_name, NULL);
		exit(1);
	}
	wait(&status);

	// CONVERT PS TO PNM
	if ((child = fork()) == 0) {
		snprintf(tmp_name, 512, "/usr/bin/gs -q -dBATCH -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -dNOPAUSE -sDEVICE=pnmraw -r100 -sOutputFile=%s-PREMAP%s.pnm %s-PREMAP.ps", name, "%02d", name);
		execl("/bin/sh", "/bin/sh", "-c", tmp_name, NULL);
		exit(1);
	}
	wait(&status);

	// CHECK FOR NUMBER OF PAGES OUTPUTTED
	for(pages = 1;; pages++) {
		snprintf(tmp_name, 512, "%s-PREMAP%02d.pnm", name, pages);
		if ((CHECK = fopen(tmp_name, "r+")) != NULL) {
			fclose(CHECK);
		} else {
			pages -= 1;
			break;
		}
	}

	// CONVERT PNM TO PNG
	for (relay = 1; relay < (pages+1); relay++) {
		if ((child = fork()) == 0) {
			snprintf(tmp_name, 512, "/usr/bin/pnmcrop < %s-PREMAP%02d.pnm | /usr/bin/pnmpad -white -l20 -r20 -t20 -b20 | /usr/bin/pnmtopng > %s-PREMAP%02d.png", name, relay, name, relay);
			execl("/bin/sh", "/bin/sh", "-c", tmp_name, NULL);
			exit(1);
		}
		wait(&status);
	}
	*p = pages;
	return hhead;
}

/*
 * void cleanup(char[])
 * 	This function cleans up extra files after all parsing and additional
 * 	file creation has been completed.
 *
 * INPUT:
 *	Character arary to be the base name of of file document to be cleand up
 *	after.
 *	EG: for file "Somefile.tex" use "Somefile".
 *	
 * CONSIDERATIONS:
 * 	Function does not check return status of system processes.
 */

void cleanup (char name[]) {
	char tmp_name[256];
	pid_t child;
	int status;
	
	if ((child = fork()) == 0) {
		snprintf(tmp_name, 256, "rm -f %s-PREMAP*", name);
		execl("/bin/sh", "/bin/sh", "-c", tmp_name, NULL);
		exit(1);
	}
	wait(&status);	
}
