#!/bin/bash

# this script uses tidy to find likely "bad" version snapshots
# that will probably crash the interface and likely have corrupt
# data.  the files are listed in error_versions.dat
#
# you should run this from the versions directory.

find . -name '*.xml' -exec sh -c 'if ! xmlstarlet val "{}" > /dev/null 2>&1  ; then echo "{}" ;  fi'  ';' > error_versions.dat


