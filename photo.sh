#!/bin/bash


if [ $# -eq 0 ]
then
	echo -e "Photo.sh - DuffyAPP_IT - @J-Duffy01\nUsage: ./photo.sh /path/to/Model.sqlite"
	exit 1
fi

echo "Dumping Database Blobs To HEX Values..."
sqlite3 $1 -line 'select hex(obj) from Comments' | cut -f2 -d'=' >> blobdata

if [ -f blobdata ]
then
	count=0
	while read p; do
 		echo "$p" | xxd -r -p > $count.bplist
 		count=$[$count +1]
	done <blobdata
	echo "Parsing Binary PLIST Values..."


	# Identify bplists of interest (over 0 bytes...)
	# Prevents empty values from being outputted.
	find . -name '*.bplist' -size +1c -maxdepth 1 -print 2>/dev/null > plbuild

	# Iterate through each file in the 'identified' good bplists
	while read p; do
		echo "COMMENT:"
 		/usr/libexec/plistbuddy -c Print "$p" | grep -B7 'MSASComment' | head -1
 		echo "TIMESTAMP:"
 		/usr/libexec/plistbuddy -c Print "$p" | grep 'NS.time' | head -1 | cut -f2 -d'.' | cut -f2 -d'='
	done <plbuild

	# Cleanup
	echo "Cleaning Up"
	find . -name '*.bplist' -maxdepth 1 -exec rm {} \;
	rm plbuild
	rm blobdata

else
	echo Coud Not Find Blob Data...
fi