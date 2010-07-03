#include <arpa/inet.h>
#include <cstring>
#include <errno.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/un.h>
#include <unistd.h>

#include "connection.h"
#include "listener.h"
#include "logger.h"

using namespace std;

/* unix domain socket */
/* it is safe to exit() from the listener constructors because the daemon is
 * useless if these sockets are not created properly */
listener::listener( logger &log, string sock ) : _log( log ) {
	struct sockaddr_un saun;

	/* create the socket address */
	saun.sun_family = AF_UNIX;
	/* 108 happens to be size of the sun_path array */
	if( sock.length() > 107 ) {
		_log.lprintf( logger::NORMAL, "UnixSocket must be 107 characters or shorter." );
		exit( 1 );
	}
	strncpy( saun.sun_path, sock.c_str(), 108 );
	unlink( saun.sun_path );

	/* now attempt to create a socket */
	_s = socket( AF_UNIX, SOCK_STREAM, 0 );
	if( _s < 0 ) {
		_log.lprintf( logger::NORMAL, "Can't create a new unix socket: %s\n", strerror( errno ) );
		exit( 1 );
	}

	/* now bind to the socket */
	if( bind( _s, (struct sockaddr *)&saun, sizeof( saun ) ) ) {
		_log.lprintf( logger::NORMAL, "Couldn't bind to unix socket '%s': %s\n", sock.c_str(), strerror( errno ) );
		exit( 1 );
	}

	/* make the socket world writable */
	chmod( sock.c_str(), 0777 );

	listen( _s, 10 );
}

/* inet socket */
listener::listener( logger &log, string addr, int port ) : _log( log ) {
	struct sockaddr_in sain;

	/* create the socket address */
	sain.sin_family = AF_INET;
	sain.sin_port = htons( port );
	sain.sin_addr.s_addr = inet_addr( addr.c_str() );
	memset( &sain.sin_zero, 0, 8 );

	/* attempt to create a socket */
	_s = socket( AF_INET, SOCK_STREAM, 0 );
	if( _s < 0 ) {
		_log.lprintf( logger::NORMAL, "Can't create new inet socket\n" );
		exit( 1 );
	}

	if( bind( _s, (struct sockaddr *)&sain, sizeof( sain ) ) ) {
		_log.lprintf( logger::NORMAL, "Couldn't bind to %s:%d\n", addr.c_str(), port );
		exit( 1 );
	}

	listen( _s, 10 );
}

/* close the socket */
listener::~listener() {
	close( _s );
}

/* get a connection -- note that this call blocks until a connection is made */
connection listener::get_connection() {
	int newsock;
	if( (newsock=accept( _s, NULL, NULL))<0 ) {
		_log.lprintf( logger::DEBUG, "accept() failed: %s\n", strerror( errno ) );
		exit( 1 );
	}
	return connection( newsock );
}
