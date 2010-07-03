#!/bin/bash

# this file should contain Noosphere things that need to be started up
# at boot.  it should be called from /etc/init.d/bootmisc.sh or similar.
#

# start up postgres
#
#su postgres -c "/etc/init.d/postgresql start"

# start up the query spell repair daemon
#
su pm -c "/var/www/noosphere/bin/spelld &"

# remove renderall lockfile if we didn't shut down gracefully
#
rm /var/www/noosphere/bin/run/renderall.running

# start search engine
#
nohup /var/www/noosphere/bin/start_searchengine.sh &

