#!/bin/bash

# 
# this script sends a HUP signal to the spell-fixer daemon, which causes 
# it to rehash the lexicon.  this should be called as a cron job every
# hour or so.
#

SPID=`cat /var/www/noosphere/bin/run/spelld.pid`

kill -HUP $SPID
