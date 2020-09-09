#!/bin/bash
clear

echo ========================================
echo Welcome To SPIDER
echo Build 2
echo DuffyAPP_IT - @J_Duffy01
echo ========================================
date
echo ========================================

if [ $# -eq 0 ]
then
	echo -e "Usage: ./spider\n-f\t\t\t\tFind Databases & Dump Schemas\n-p\t\t\t\tExtract Apple Photos Shared Album Information\n-i yourpersonalinfo\t\tDetect Personal Information Within Databases\n-a\t\t\t\tExtended Scan"
	exit 1
fi

echo Background Init...
#Initialise Local Counters
ljpgCount=0
lpngCount=0

# Check if rootFS is present
if [ ! -d private ]
then
echo iOS Root Filesystem Not Detected In Current Directory
echo Exiting For Safety Reasons...
exit 1
fi

		#Clean Old Directories & Files
		if [ -d ./SpiderOUT ]
		then
		echo Old SpiderOUT Directory Found... Removing!
		rm -rf ./SpiderOUT
		fi

		mkdir SpiderOUT

if [[ $1 = "-a" ]]
	then
		echo "Extended Scan"
		rm -rf SpiderIn
		mkdir SpiderIn SpiderIn/Images SpiderIn/Videos
		touch SpiderIn/spider
		echo Your Data Subjects, each on a new line please! > SpiderIn/spider

		read -rsn1 -p"Populate SPIDER Data In SpiderIN Directory & Press Enter...";echo


		echo ========================================
		echo Processing SPIDER Input Files
		echo ========================================

		echo Finding Input Images
		#Find amount of images, output path to jpg.txt, output amount of found files to stdout ( ljpgCount var in this case )
		ljpgCount=$(find ./SpiderIn/Images -name '*.jpg' 2>/dev/null | tee SpiderIn/jpg.txt | wc -l 2>/dev/null )
		echo Found $ljpgCount Local JPGs

		#Find amount of images, output path to png.txt, output amount of found files to stdout ( lpngCount var in this case )
		lpngCount=$(find ./SpiderIn/Images -name '*.png' 2>/dev/null | tee SpiderIn/png.txt | wc -l >/dev/null 2>/dev/null )
		echo Found $lpngCount Local PNGs

		#Hash paths of all files of relevant filetypes, compute an md5 hash of each file, append to JPGhash.txt



		#Loop through the files we created earlier in the script... Lines 44/48 specifically!
		#Create files to prevent file-not-exit errors later in script.
		touch SpiderIn/JPGhash.txt
		touch SpiderIn/PNGhash.txt
		echo Hashing JPGs for comparison against similar files in rootFS
		while read p; do
		      md5 $p  | awk '{ print $4 }' >> ./SpiderIn/JPGhash.txt
		done <SpiderIn/jpg.txt
		echo Done!

		echo Hashing PNGs for comparison against similar files in rootFS
		while read p; do
		      md5 $p 2>/dev/null | awk '{ print $4 }' >> ./SpiderOUT/PNGhash.txt 2>/dev/null
		done <SpiderIn/png.txt
		echo Done!


		echo ========================================
		echo Processing User-Supplied RootFS
		echo ========================================


		#Start calculating values pertaining to our iOS RootFS
		echo Finding SQLITE DBs
		dbCount=$(find . -name '*.sqlite' 2>/dev/null | tee SpiderOUT/DB.txt | wc -l >/dev/null 2>/dev/null )
		echo Found $dbCount DBs

		echo Finding DBs
		dbCount=$(find . -name '*.db' 2>/dev/null | tee SpiderOUT/DB2.txt | wc -l >/dev/null 2>/dev/null )
		echo Found $dbCount DBs

		echo Finding Images
		jpgCount=$(find . -type f -size +10k -size -800k -exec file '{}' \; 2>/dev/null | grep -H JFIF | cut -f2 -d':'  | tee SpiderOUT/jpg.txt | wc -l >/dev/null 2>/dev/null )
		echo Found JPGs
		pngCount=$(find . -type f -size +10k -size -800k -exec file '{}' \; 2>/dev/null | grep -H PNG | cut -f2 -d':' | tee SpiderOUT/png.txt | wc -l >/dev/null 2>/dev/null )
		echo Found PNGs



		echo Hashing SQLITE DBs
		while read p; do
		      md5 $p 2>/dev/null | awk '{ print $4 }' >> SpiderOUT/DBhash.txt 2>/dev/null
		done <SpiderOUT/DB.txt

		echo Hashing Other DBs
		while read p; do
		      md5 $p 2>/dev/null | awk '{ print $4 }' >> SpiderOUT/DB2hash.txt 2>/dev/null
		done <SpiderOUT/DB.txt

		echo Done!

		echo Hashing JPGs
		while read p; do
		      md5 $p 2>/dev/null | awk '{ print $4 }' >> SpiderOUT/JPGhash.txt 2>/dev/null
		done <SpiderOUT/jpg.txt

		echo Done!

		echo Hashing PNGs
		while read p; do
		      md5 $p 2>/dev/null | awk '{ print $4 }' >> SpiderOUT/PNGhash.txt  2>/dev/null
		done <SpiderOUT/png.txt

		echo Extracting SQLITE Database Schemas
		find . -name '*.sqlite' -print -exec sqlite3 {} '.tables' 2>/dev/null \; | tee SpiderOUT/TableData.txt >/dev/null

		echo Extracting Database Schemas
		find . -name '*.db' -print -exec sqlite3 {} '.tables' 2>/dev/null \; | tee SpiderOUT/TableData2.txt >/dev/null



		echo Extracting WiFI Location Data
		sqlite3 ./private/var/root/Library/Caches/com.apple.wifid/ThreeBars.sqlite 'select ZLAT, ZLNG, ZBSSID from ZACCESSPOINT' | tee SpiderOUT/WiFi_Loc.txt >/dev/null


		echo Extracting Basic Account Details
		sqlite3 ./private/var/mobile/Library/Accounts/Accounts3.sqlite 'SELECT ZUSERNAME from ZACCOUNT' | tee SpiderOUT/Accounts.txt >/dev/null >/dev/null


		echo Extracting ConnectedAlbum Details
		find ./private/var/mobile/Library/MediaStream/albumshare/ -name 'Model.sqlite' -exec sqlite3 {} 'SELECT email FROM 'AccessControls'' \; | tee SpiderOUT/ConnectedAlbum.txt >/dev/null >/dev/null

		echo Extracting SharedAlbum URLs
		find ./private/var/mobile/Library/MediaStream/albumshare/ -name 'Model.sqlite' -exec sqlite3 {} 'SELECT name,url FROM 'Albums'' \; | tee SpiderOUT/SharedAlbum.txt >/dev/null >/dev/null


		echo Loading SPIDER Data


		find . -name '*.sqlite' -print -exec sqlite3 {} '.dump' \; 2>/dev/null | tee SpiderOUT/DB-DUMP.txt >/dev/null 2>/dev/null


		#Removed KTX related stuff as not finished yet!


		echo ========================================
		echo Inspecting Matching Databases...
		echo ========================================
		while read p; do
		  	find ./ -name '*.sqlite' -exec grep -H $p {} \; 2>/dev/null | tee SpiderOUT/MATCHSQLITE.txt >/dev/null 2>/dev/null
		done <SpiderIn/spider

		while read p; do
		  	find ./ -name '*.db' -exec grep -H $p {} \; 2>/dev/null | tee SpiderOUT/MATCHDB.txt >/dev/null 2>/dev/null
		done <SpiderIn/spider
		 echo Done!

		echo MD5 Compare...
		#Compare MD5s of input files against processes rootFS
		grep -Fxf ./SpiderOUT/JPGhash.txt ./SpiderIn/JPGhash.txt | sort --unique

		grep -Fxf ./SpiderOUT/PNGhash.txt ./SpiderIn/PNGhash.txt | sort --unique

		echo Great Success!

		echo ========================================
		echo "Make Sure To Check The SpiderOUT Directory <3 \!"
		echo ========================================

		exit 1
fi

if [[ $1 = "-f" ]]
then
		echo Finding SQLITE DBs
		dbCount=$(find . -name '*.sqlite' 2>/dev/null | tee SpiderOUT/DB.txt | wc -l >/dev/null 2>/dev/null )
		echo Found $dbCount DBs

		echo Finding DBs
		dbCount=$(find . -name '*.db' 2>/dev/null | tee SpiderOUT/DB2.txt | wc -l >/dev/null 2>/dev/null )
		echo Found $dbCount DBs


		echo Extracting SQLITE Database Schemas
		find . -name '*.sqlite' -print -exec ls -lh {} \; -exec sqlite3 {} '.tables' 2>/dev/null \; | tee SpiderOUT/TableData.txt

		echo Extracting Database Schemas
		find . -name '*.db' -print -exec ls -lh {} \; -exec sqlite3 {} '.tables' 2>/dev/null \; | tee SpiderOUT/TableData.txt
fi

if [[ $1 = "-p" ]]
then
		echo Extracting ConnectedAlbum Details
		find ./private/var/mobile/Library/MediaStream/albumshare/ -name 'Model.sqlite' -exec sqlite3 {} 'SELECT email FROM 'AccessControls'' \; 2>/dev/null | tee SpiderOUT/ConnectedAlbum.txt

		echo Extracting SharedAlbum URLs
		find ./private/var/mobile/Library/MediaStream/albumshare/ -name 'Model.sqlite' -exec sqlite3 {} 'SELECT name,url FROM 'Albums'' \; 2>/dev/null | tee SpiderOUT/SharedAlbum.txt
fi

if [[ $1 = "-i" ]]
then
	if [ $2 = 0 ]
	then
		echo "No Information Supplied... Exiting For Safety"
		exit 1
	fi
	echo "Searching..."
	find ./ -name '*.sqlite' -exec grep -H $2 {} \; 2>/dev/null | tee SpiderOUT/MATCHSQLITE.txt 2>/dev/null
	find ./ -name '*.db' -exec grep -H $2 {} \; 2>/dev/null | tee SpiderOUT/MATCHSQLITE.txt 2>/dev/null
fi


