#include <cstring>
#include <stdarg.h>
#include <stdio.h>
#include <string>
#include <time.h>

#include "logger.h"

#define STR 256

logger::logger( string const &logfile, int verbosity ) : _logfile( logfile ), _verbosity( verbosity ) { }

void logger::lprintf( int level, char const *fmt, ... ) {
	if( _verbosity <= level ) {
		FILE *f = fopen( _logfile.c_str(), "a" );
		if( f ) {
			char strnow[STR+1] = {0};
			time_t now = time(0);
			strftime( strnow, STR+1, "%b %d %H:%M:%S %z ", localtime( &now ) );
			fprintf( f, "%s", strnow );

			va_list args;
			va_start( args, fmt );
			vfprintf( f, fmt, args );
			va_end( args );
			fclose( f );
		}
	}
}
