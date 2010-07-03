/*
 * logger.h - simple logging stuff
 */

#if !defined( __LOGGER_H__ )
#define __LOGGER_H__

#include <string>

using namespace std;

class logger {
	private:
		string _logfile;
		int _verbosity;
	public:
		enum {
			DEBUG = -2,
			VERBOSE = -1,
			NORMAL = 0,
			QUIET = 1
		};

		logger( string const &logfile, int verbosity = NORMAL );

		void lprintf( int level, char const *, ... ); 
};

#endif
