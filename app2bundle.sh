#!/bin/bash


if [ $# -eq 0 ]
then
	echo -e "bundle.sh - DuffyAPP_IT - @J-Duffy01\nUsage: ./bundle.sh /path/to/applicationState.db"
	exit 1
fi

echo "Dumping Database Blobs To HEX Values..."
sqlite3 $1 -line 'select hex(value) from kvs' | cut -f2 -d'=' >> blobdata

if [ -f blobdata ]
then
	count=0
	while read p; do
 		echo "$p" | xxd -r -p > $count.bplist
 		count=$[$count +1]
	done <blobdata
	echo "Parsing Binary PLIST Values (extracted from applicationState.db)..."


	# Identify bplists of interest (over 0 bytes...)
	# Prevents empty values from being outputted.
	find . -name '*.bplist' -size +1c -maxdepth 1 -print 2>/dev/null > plbuild

	# Iterate through each file in the 'identified' good bplists
	while read p; do
 		/usr/libexec/plistbuddy -c Print "$p" | grep -a $2
	done <plbuild

	# Cleanup
	echo "Cleaning Up Temporary Files"
    rm *.bplist
    rm plbuild
    rm blobdata

else
	echo Coud Not Find Blob Data...
fi
