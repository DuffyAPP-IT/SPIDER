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
	find . -name '*.bplist' -exec /usr/libexec/plistbuddy -c Print {} 2>/dev/null \; | grep -B7 'MSASComment' >> bplistvals

	if [ -f bplistvals ]
		then
			cat bplistvals | grep -A1 - | grep -v classes | grep -v -
	else
		echo Coud Not Find BPLIST Values...
	fi

else
	echo Coud Not Find Blob Data...
fi