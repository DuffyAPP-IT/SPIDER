#!/bin/bash


if [ $# -eq 0 ]
then
	echo -e "snapchat-proc - DuffyAPP_IT - @J-Duffy01\nUsage: ./other.sh /path/to/arroyo.sqlite"
	exit 1
fi

echo "Dumping Database Blobs To HEX Values..."

sqlline="select hex(message_content) from conversation_message"
#convid="select client_conversation_id from conversation_message"

sqlite3 $1 -line "$sqlline" | cut -f2 -d'=' >> blobdata
#sqlite3 $1 -line "$convid" | cut -f2 -d'=' >> conv-id-data
#sqlite3 $1 -line "$convid"

#if [ -f blobdata ]
#then
#count=0
#while read c; do
#    echo "$c" > $count.convid
#    count=$[$count +1]
#done<conv-id-data
#fi


if [ -f blobdata ]
then
	count=1
	while read p; do
#        convidcount=$[$count -2]
 		echo "$p" | xxd -r -p > $count.outsc

#        Remove first 72 bytes
        tail +60c $count.outsc > $count.outsc.truncated && mv $count.outsc.truncated $count.outsc

#        Remove last 75 bytes
#        stat -f%z $count.outsc
        newfsize=$(($(stat -f%z $count.outsc) - 72)) 2>/dev/null
        truncate -s $newfsize $count.outsc 2>/dev/null
#        stat -f%z $count.outsc

#        tr -d '\n\r' < $count.outsc

        hexdump $count.outsc | grep '8b 01 0a 88'
        isvid=$?
        if [ $isvid -eq 0 ]
            then
#            stat -f%z $count.outsc
            newfsize=$(($(stat -f%z $count.outsc) - 75)) 2>/dev/null
            truncate -s $newfsize $count.outsc
#            stat -f%z $count.outsc
        fi

        hexdump $count.outsc | grep '87 01 0a 84'
        isvid=$?
        if [ $isvid -eq 0 ]
        then
        tail +149c $count.outsc > $count.outsc.truncated && mv $count.outsc.truncated $count.outsc
#        stat -f%z $count.outsc
        newfsize=$(($(stat -f%z $count.outsc) - 162)) 2>/dev/null
        truncate -s $newfsize $count.outsc
#        stat -f%z $count.outsc
        fi

        hexdump $count.outsc | grep '8a 01 0a 87'
        isvid=$?
        if [ $isvid -eq 0 ]
        then
        tail +162c $count.outsc > $count.outsc.truncated && mv $count.outsc.truncated $count.outsc
#        stat -f%z $count.outsc
        newfsize=$(($(stat -f%z $count.outsc) - 188)) 2>/dev/null
        truncate -s $newfsize $count.outsc
#        stat -f%z $count.outsc
        fi



        echo -e '\n----------'
#        cat $convidcount.convid
        echo $count.outsc
        echo -e '----------'
        cat $count.outsc
        rm $count.outsc
        count=$[$count +1]


	done <blobdata

#    echo "Parsing Values..."
#    find . -name '*.outsc' -size +3c -exec cat {} 2>/dev/null \; >> vals
#    if [ -f vals ]
#        then
#            iconv -f utf-8 -t utf-8 -c vals
#            cat vals
#    else
#        echo Coud Not Find Values...
#    fi

#    echo "Cleaning Up..."
#    count=0
#    while read p; do
#         rm $count.convid
#         count=$[$count +1]
#    done <conv-id-data

    rm blobdata
#    rm vals

else
	echo Coud Not Find Blob Data...
fi
