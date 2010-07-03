#if !defined( __LISTENER_H__ )
#define __LISTENER_H__

#include <netinet/in.h>
#include <string>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

#include "connection.h"
#include "logger.h"

using namespace std;

class listener {
	private:
		logger &_log;
		int _s;

	public:
		/* unix domain socket */
		listener( logger &log, string sock );
		/* inet socket */
		listener( logger &log, string addr, int port );
		~listener();

		connection get_connection();
};

#endif
