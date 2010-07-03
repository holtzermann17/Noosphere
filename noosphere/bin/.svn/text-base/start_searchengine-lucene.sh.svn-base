#!/bin/bash

###############################################################################
#
# A sample startup script for the Lucene search daemon.
#
# Note that it doesn't automatically detach itself, so that is done 
# unixistically.
#
###############################################################################

LMHOME="/usr/local/apache/htdocs/lucene_search_module"

#export JAVA_HOME="/usr/local/j2sdk1.4.1"
export JAVA_HOME="/usr/java/default"
#export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"

if [ -n "$CLASSPATH" ] ; then
	export CLASSPATH="$CLASSPATH:/usr/share/java/lucene-1.4.3.jar:$LMHOME"
else 
	export CLASSPATH="/usr/share/java/lucene-1.4.3.jar:$LMHOME"
fi

nohup $JAVA_HOME/bin/java Daemon /usr/local/apache/htdocs/noosphere/etc/lucene_search.conf &

