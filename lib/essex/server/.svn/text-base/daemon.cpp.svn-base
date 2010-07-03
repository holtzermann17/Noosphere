#include <strstream>

#include <pthread.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <assert.h>

#include "daemon.h"

// forward decl
void* thread_handle (void *);

/* these must be global so the term handler can get them */
pid_t childunix, childinet;
vector<pid_t> children;

/* term for main searchd process */
void handler_term( int arg ) {
	if( childunix ) kill( childunix, SIGTERM );
	if( childinet ) kill( childinet, SIGTERM );
	exit( 0 );
}

/* handle sigchld to clean up zombies */
void handler_child( int arg ) {
	wait( NULL );
}

/* term for listeners */
void handler_term_listener( int arg ) {
	/* kill all the children */
	for( int i=0; i < children.size(); ++i ) {
		if( children[i] )
			kill( children[i], SIGTERM );
	}
}

/* sigchld for listeners */
void handler_child_listener( int arg ) {
	pid_t ch = wait( NULL );
	for( int i=0; i < children.size(); ++i )
		if( children[i]==ch ) children[i] = 0;
}

searchdaemon::searchdaemon( confhelper &options ) :
	_options( options ),
	_log( options.get_string( "LogFile" ), logger::DEBUG ) { }

void searchdaemon::listenloop( listener &l ) {
	vector<pthread_t> threads;
	pthread_t thread;
	pthread_attr_t attr;

	assert(pthread_attr_init (&attr) == 0);

	engine.initmutex();

	// do we need this?? it does'nt seem to help when a connection is aborted
	//signal( SIGCHLD, handler_child );

	while( true ) {
	//	pid_t ch;
		next_conn = new connection( l.get_connection() );

		// create a thread
		assert(pthread_create(
			&thread,
			&attr,
			//(void*)thread_handle,
			(void*(*)(void*))thread_handle,
			(void*)this
		) == 0);

		// start up the thread, stop it on a return of 0
		pthread_join(thread, (void **)0);

		// add thread to list
		threads.push_back(thread);
		
	//	if( (ch=fork())==0 ) {
	//		_log.lprintf( logger::DEBUG, "Connection\n" );
	//		handle( c );
	//	} else children.push_back( ch );
	}
}

// dummy function to receive thread handling
//
void* thread_handle(void *arg) {
	
	searchdaemon *s = (searchdaemon *)arg;

	// invoke handler for current connection
	//
	s->handle_current();

	// APK - pthread-style exit
	pthread_exit(0);
}

// public access to tell the searchdaemon to handle the incoming connection. 
// needed for interface with pthreads.
//
void searchdaemon::handle_current( void ) {

	// copy next connection into a local variable, since when the next one
	// comes in, the value of next_conn will change.
	//
	connection* c;
	c = next_conn;
	
	// call the handler.
	//
	handle(*c);

	delete c;	// free mem
}

// main connection handler
//
void searchdaemon::handle( connection c ) {
	c.send_message( connection::HELLO, string( "searchd" ) );

	vector<string> t;
	string cmd( "" );
	do {
		t = c.get_response();

		// lost peer
		if( t[0] == "DISCON") break;

		if( t.size() < 1 ) {
			c.send_message( connection::BADCMD, "Empty command" );
		} 
		else {
			cmd = t[0];

			/* index a document chunk (corresponds to XML element) */
			
			if (cmd == "index") {
#ifdef LOG_INDEXING
				_log.lprintf( logger::DEBUG, "Got index command\n" );
#endif
				c.send_message( connection::OK, "indexing; send IDs" );

				//read in doc/tag IDs
				vector<string> IDs = c.get_index_IDs();
				assert(IDs.size()==2);
				string docID=IDs[0];
				string tagID=IDs[1];
#ifdef LOG_INDEXING
				_log.lprintf( logger::DEBUG, "Got index IDs\n" );
#endif
				c.send_message( connection::OK, "send words" );

				//read in terms
				vector<string> words = c.get_words();;
#ifdef LOG_INDEXING
				_log.lprintf( logger::DEBUG, "Receiving indexing words\n" );
#endif

				//add to inverted index
				engine.add_element(words, docID, tagID);

				//cout << "printing ii" << endl;
				//engine.print();
				//cout << "done printing ii" << endl;
			} 

			/* unindex based on a document id */

			else if (cmd == "unindex") {
#ifdef LOG_INDEXING
				_log.lprintf( logger::DEBUG, "Got unindex command\n" );
#endif
				c.send_message( connection::OK, "unindexing; send ID" );

				string docID = c.get_unindex_ID();
#ifdef LOG_INDEXING
				_log.lprintf( logger::DEBUG, "Unindexing\n" );
#endif

				engine.remove_doc(docID);
			}

			/* execute a search */

			else if (cmd == "search") {
				_log.lprintf( logger::DEBUG, "Got search command\n" );
				c.send_message( connection::OK, "send query" );

				vector<query_node> query = c.get_query();
				_log.lprintf( logger::DEBUG, "Searching\n" );

				vector<query_result> results = engine.search(query);

				if( results.size()>0 ) {
					_log.lprintf( logger::DEBUG, "Sending some search results\n" );
					c.send_message( connection::BEGINSEARCHRESULT, "here are some results");
					for( int i=0; i < results.size(); i++ )
						c.send_search_result(results[i]);

					c.send_message( connection::ENDSEARCHRESULT, "that is all" );
				} 
				else {
					c.send_message( connection::NOSEARCHRESULT, "no results" );
				}
			}

			/* execute a limited search */

			else if (cmd == "limitsearch") {
				_log.lprintf( logger::DEBUG, "Got search command\n" );
				c.send_message( connection::OK, "send query" );

				vector<query_node> query = c.get_query();
				int limit = c.get_limit();
				_log.lprintf( logger::DEBUG, "Limited Searching\n" );

				// actual number of matches gets returned in nmatches
				int nmatches = limit;
				vector<query_result> results = engine.search(query, nmatches);

				if( results.size() > 0 ) {

					_log.lprintf( logger::DEBUG, "Sending search results number of matches\n" );
					char buf[101];
					ostrstream os(buf, 100);	
					os << nmatches << endl;

					c.send_message( connection::NMATCHES, buf);

					_log.lprintf( logger::DEBUG, "Sending some search results\n" );
					c.send_message( connection::BEGINSEARCHRESULT, "here are some results");
					for( int i=0; i < results.size() && i < results.size(); i++ )
						c.send_search_result(results[i]);

					c.send_message( connection::ENDSEARCHRESULT, "that is all" );
				} 
				else {
					c.send_message( connection::NOSEARCHRESULT, "no results" );
				}
			}

			/* shut down daemon */

			else if( cmd == "quit" ) {
				_log.lprintf( logger::DEBUG, "Shutting down.\n" );
				c.send_message( connection::BYE, "Thanks for playing" );
			} 

			/* get statistics */

			else if ( cmd == "stats" ) {

				c.send_message( connection::OK, "printing statistics" );
				engine.stats();
			}

			/* squeeze down data structures to conserve memory, do other 
			 * maintenance */

			else if ( cmd == "compactify" ) {

				c.send_message( connection::OK, "compactifying data structures" );
				engine.stats();
			}
			
			/*
			else if ( cmd=="printindex" ) {

				c.send_message( connection::OK, "printing inverted index" );
				engine.print();
			}
			*/

			/* say what? */

			else c.send_message( connection::BADCMD, string( "Unknown command " ) + cmd );
		}
	} while( cmd != "quit" );

	c.finish();
}

void searchdaemon::go() {

	/* let search engine get at logger */
	engine.setlogger(&_log);

	/* fork off listeners */
	_log.lprintf( logger::DEBUG, "Looks good: %d\n", getpid() );
	childunix=0;
	childinet=0;

	/* fork off a unix listener .. */
	if( _options.get_bool( "ListenUnix" ) ) {
		_log.lprintf( logger::DEBUG, "Forking UNIX domain listener\n" );
		if( (childunix=fork())==0 ) {
			listener unix_listen( _log, _options.get_string( "UnixSocket" ) );
			listenloop( unix_listen );
		}
	}

	/* .. and an inet listeneer */
	if( _options.get_bool( "ListenInet" ) ) {
		_log.lprintf( logger::DEBUG, "Forking inet domain listener\n" );
		if( (childinet=fork())==0 ) {
			listener inet_listen( _log, _options.get_string( "BindAddress" ), _options.get_int( "ListenPort" ) );
			listenloop( inet_listen );
		}
	}

	signal( SIGTERM, handler_term );

	/* now just chill for a bit */
   while( childunix != 0 || childinet != 0 ) {
     pid_t child = wait( NULL );
     if( child==childunix ) childunix = 0;
     if( child==childinet ) childinet = 0;
   }
	exit( 0 );
}
