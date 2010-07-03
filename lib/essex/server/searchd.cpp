#include <cassert>
#include <cstdarg>
#include <cstdlib>
#include <getopt.h>
#include <grp.h>
#include <pwd.h>
#include <signal.h>

#ifdef __LINUX__
	#include <sys/mman.h>
#endif

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <vector>

#include "config.h"

#include "daemon.h"

#define STR 512
#define VERSION 0.75

using namespace std;

void show_help() {
	cout << "Usage: essexd [OPTIONS]" << endl << endl;
}

void show_version() {
	cout << "essexd " << VERSION << endl;
}

int main( int argc, char *argv[] ) {
	string conffile( "essex.conf" );
	int c;

	while( (c=getopt( argc, argv, "f:hv" ))!=EOF ) {
		switch( c ) {
			/* f: specify config file */
			case 'f':
				conffile = string( optarg );
				break;

			/* h: help */
			case 'h':
				show_help();
				exit( 0 );
				break;

			/* v: version */
			case 'v':
				show_version();
				exit( 0 );
				break;

			/* otherwise, it's an error */
			default:
				show_help();
				exit( 1 );
				break;
		}
	}

	/* load configuration */	
	confhelper options( conffile, CONF_MAIN );

	/* switch to the appropriate group */
	gid_t cur_gid = getgid();
	struct group dest_grp;
	struct group *pg = getgrnam( options.get_string( "Group" ).c_str() );
	if( !pg ) {
		cerr << "No such group " << options.get_string( "Group" ) << endl;
		exit( 1 );
	}
	memcpy( &dest_grp, pg, sizeof( dest_grp ) );
	if( dest_grp.gr_gid != cur_gid ) {
		if( setregid( dest_grp.gr_gid, dest_grp.gr_gid ) ) {
			cerr << "Couldn't switch to group " << dest_grp.gr_gid << endl;
			exit( 1 );
		}
	}

	/* get user/group information */

	pid_t cur_uid = getuid();
	struct passwd dest_pw;
	struct passwd *pp = getpwnam( options.get_string( "User" ).c_str() );
	if( !pp ) {
		cerr << "No such user " << options.get_string( "User" ) << endl;
		exit( 1 );
	}
	memcpy( &dest_pw, pp, sizeof( dest_pw ) );

#ifdef __LINUX__
	/* lock memory so we can't be swapped */

	if ( cur_uid == 0 ) {
		int ret = mlockall(MCL_CURRENT|MCL_FUTURE);
		if (ret == -1) {
			cerr << "Warning: Memory lock failed; swapping may happen." << endl;
		}
	} else {
		
		cerr << "Warning: Not starting as root, so I can't lock memory. Swapping may occur." << endl;
	}
#endif

	/* actually do the userid/gid switch */

	if( dest_pw.pw_uid != cur_uid ) {
		if( setreuid( dest_pw.pw_uid, dest_pw.pw_uid ) ) {
			cerr << "Couldn't switch to uid " << dest_pw.pw_uid << endl;
			exit( 1 );
		}
	}

	/* warn if running as root */
	if( dest_grp.gr_gid==0 )
		cerr << "Warning: running as gid 0 (this may be a security risk)" << endl;
	if( dest_pw.pw_uid==0 )
		cerr << "Warning: running as uid 0 (this may be a security risk)" << endl;

	/* fork off the main process */
	pid_t childpid;
	if( childpid = fork() ) {
		string pidfilename = options.get_string( "PidFile" );
		ofstream pf( pidfilename.c_str() );
		pf << childpid;
		if( pf.bad() ) {
			cerr << "Couldn't write to pidfile: " << pidfilename << endl;
			cerr << "pid is " << childpid << endl;
		}
	} else {
		searchdaemon searchd( options );
		searchd.go();
	}

	return 0;
}
