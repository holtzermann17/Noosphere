#if !defined( __DAEMON_H__ )
#define __DAEMON_H__ 

#include "confhelper.h"
#include "connection.h"
#include "logger.h"
#include "listener.h"
#include "vector_search.h"

class searchdaemon {
	private:
		confhelper& _options;
		
		connection* next_conn;	// used for passing connections to threads

		logger _log;
		
		vector_search engine;	// the search engine object.

		void listenloop( listener &l );
		void handle( connection c );


	public:
		searchdaemon( confhelper &options );

		// tell the search daemon to handle the current incoming connection
		// (triggers handle())
		void handle_current();

		void go();
};

#endif
