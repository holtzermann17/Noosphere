#!/bin/bash

# 
# this script completely reloads the query spell-fixer daemon.
#

SPID=`cat /var/www/noosphere/bin/run/spelld.pid`

kill -TERM $SPID
nohup /var/www/noosphere/bin/spelld &
