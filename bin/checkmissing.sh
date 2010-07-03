#!/bin/bash

# this script checks for entries missing their cached outputs (a 
# planetmath.html file) and lets you optionally invalidate their
# cache in the database
#

DBUSER="pm"
DBNAME="pm"
DBPASS="groupschemes"

MISSING=0
LIST=""

for FILE in [0-9]* ; do  
	if [ ! -e $FILE/l2h/planetmath.html ] ; then  
		LIST="$FILE $LIST"

		MISSING=1
	fi 
done

if [[ $MISSING == 1 ]] ; then

	if [[ "$1" == "invalidate" ]] ; then

		for OBJ in $LIST ; do 
			echo "invalidating $OBJ"
			echo "update cache set valid=0 where method='l2h' and tbl='objects' and objectid='$OBJ';" | mysql -u$DBUSER -p$DBPASS $DBNAME		
		done	
	else 
	
		echo "$LIST"

		echo ""
		echo "Some entries were missing cached output.  Run with parameter"
		echo "'invalidate' to invalidate their caches in the database."
		echo ""
	fi
fi
