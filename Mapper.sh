#!/bin/bash
clear

echo ========================================
echo Welcome To SPIDER -\> MapperV2
echo Build 2
echo DuffyAPP_IT - @J_Duffy01
echo ========================================
date
echo ========================================

#Check if rootFS is present
#if [ ! -d private ]
#then
#	echo iOS rootFS Not Detected In Current Directory
#	echo Exiting For Safety...
#	exit
#fi

read -rsn1 -p"Press Enter To MapperV2...";echo

#echo ========================================
#echo Removing Empty Directories In Build...
#echo ========================================
#
#find . -type d -empty -print -exec rm -rf {} \; >/dev/null 2>/dev/null
#echo 'Done!'

# echo ========================================
# echo Removing File Smaller Than 50 Bytes In Build...
# echo ========================================

# find . -type f -size -50c  -exec rm {} \; >/dev/null 2>/dev/null
# echo 'Done!'


echo ========================================
echo Finding Databases Larger Than 50KB In Build...
echo ========================================

find . -type f -size +50k -name "*.db" -print 2>/dev/null
find . -type f -size +50k -name "*.sqlite*" -print 2>/dev/null



echo ========================================
echo Finding Hidden Media In Build...
echo ========================================

find . -type f -size +10k -size -800k -not -name "*.png" -exec file '{}' \; 2>/dev/null | grep -H PNG | cut -f2 -d':' | xargs -I{} open {}

find . -type f -size +10k -size -800k -not -name "*.jpg" -exec file '{}' \; 2>/dev/null | grep -H JFIF | cut -f2 -d':' | xargs -I{} open {}

find . -type f -size +80k -not -name "*.wav" -exec file '{}' \; 2>/dev/null | grep -H WAVE | cut -f2 -d':' | xargs -I{} open {}

#
#find . -type f -size +100k -size -800k -exec grep -H -a Photoshop '{}' \; 2>/dev/null
