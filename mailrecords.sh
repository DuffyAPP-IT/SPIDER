#!/bin/bash
clear
echo ========================================
echo Welcome To Mail_URL_Parse -\> MapperV2
echo Build 1
echo DuffyAPP_IT - @J_Duffy01
echo ========================================
date
echo ========================================

if [ $# -eq 0 ]
then
	echo -e "mailrecords.sh - DuffyAPP_IT - @J_Duffy01\nUsage: ./mailrecords.sh /path/to/url/dump/output"
	exit 1
fi

# Check if rootFS is present
if [ ! -d private ]
then
	echo iOS rootFS Not Detected In Current Directory
	echo Exiting For Safety...
	exit
fi

# check if user selected output already exists
if [ -f $1 ]
then
	read -p 'Output File Already Exists...Remove? (y/n) ' fileexistremove
	if [ "$fileexistremove" = "y" ]; then
		rm $1
	else
		echo "Appending To File Instead - Will NOT Overwrite!"
	fi
fi



# find mail directory id
mediadir=$(find . -name 'com.apple.mobilemail.plist' | sed 's|\(.*\)/.*|\1|' | sed 's|\(.*\)/.*|\1|')

# find records within NetworkCache... 
find $mediadir/Caches/WebKit/NetworkCache  -type f -name '*' -size +1c >> .files

# # Iterate through each file in the 'identified' files and fetch URL
while read p; do
		cat "$p" | head -1 | grep -a Resource | tr '\n' ' ' 2>/dev/null | head -1 | tr -d '\n' | cut -f1 -d'?' | cut -c 25- >> $1
done <.files


# id amount of found url's
urlcount=$(cat $1 | wc -l)
if [ $urlcount \< 1 ]
then
	echo "Found No URLs :-("
	exit 1
	#statements
fi

echo "$urlcount URLs Extracted! Check $1 For Output!"
echo "DEBUG"
sleep 3
cat $1

# clean old filename cache
rm .files 2>/dev/null