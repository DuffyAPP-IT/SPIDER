#!/bin/bash


if [ $# -eq 0 ]
then
	echo -e "db-bplist-proc - DuffyAPP_IT - @J-Duffy01\nUsage: ./other.sh /path/to/DB.sqlite TABLE COLUMN"
	exit 1
fi

echo "Dumping Database Blobs To HEX Values..."

sqlline="select hex($3) from $2"

sqlite3 $1 -line "$sqlline" | cut -f2 -d'=' >> blobdata

if [ -f blobdata ]
then
	count=0
	while read p; do
 		echo "$p" | xxd -r -p > $count.bplist
 		count=$[$count +1]
	done <blobdata
	echo "Parsing Binary PLIST Values..."
	find . -name '*.bplist' -size +5c -exec /usr/libexec/plistbuddy -c Print {} 2>/dev/null \; >> bplistvals

	if [ -f bplistvals ]
		then
			cat bplistvals
	else
		echo Coud Not Find BPLIST Values...
	fi

	echo "Cleaning Up..."
	count=0
	while read p; do
 		rm $count.bplist
 		count=$[$count +1]
	done <blobdata

	rm blobdata
	rm bplistvals

else
	echo Coud Not Find Blob Data...
fi