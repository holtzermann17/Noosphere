#!/bin/bash

# (re)start the search engine. indexes from database every time.  this
# should be deprecated when the search engine utilizes a swapped image of
# the index.
#
kill -TERM `cat /var/www/noosphere/bin/run/essexd.pid` > /dev/null 2>&1

cd /var/www/essex/server

./essexd -f /var/www/noosphere/etc/essex.conf

echo "indexing"

/var/www/noosphere/bin/ir_index.pl

