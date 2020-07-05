#!/bin/bash
clear

echo ========================================
echo \|\|S \|\|\|P \|\|\|I \|\|\|D \|\|\|E \|\|\|R \|\|
echo
echo DuffyAPP_IT - @J_Duffy01
echo ========================================


echo Background Init...


ljpgCount=0
lpngCount=0


rm -rf MapperOUT >/dev/null
mkdir MapperOUT MapperOUT/KTX >/dev/null
rm MapperIn/jpg.txt 2>/dev/null
rm MapperIn/png.txt 2>/dev/null
rm MapperIn/JPGhash.txt 2>/dev/null
rm MapperIn/PNGhash.txt 2>/dev/null


echo Hashing MapperIn Images

echo Finding Images
ljpgCount=$(find ./MapperIn/Images -name '*.jpg' 2>/dev/null | tee MapperIn/jpg.txt | wc -l 2>/dev/null ) 
find ./MapperIn/Images -name '*.jpg' >/dev/null 2>/dev/null
echo Found $ljpgCount Local JPGs
lpngCount=$(find ./MapperIn/Images -name '*.png' 2>/dev/null | tee MapperIn/png.txt | wc -l >/dev/null 2>/dev/null )
echo Found $lpngCount Local PNGs

echo Hashing JPGs
while read p; do
      md5 $p  | awk '{ print $4 }' >> ./MapperIn/JPGhash.txt
done <MapperIn/jpg.txt

echo Hashing PNGs
while read p; do
      md5 $p 2>/dev/null | awk '{ print $4 }' >> ./MapperOUT/PNGhash.txt 2>/dev/null
done <MapperIn/png.txt





echo Finding SQLITE DBs
dbCount=$(find . -name '*.sqlite' 2>/dev/null | tee MapperOUT/DB.txt | wc -l >/dev/null 2>/dev/null )
echo Found $dbCount DBs

echo Finding DBs
dbCount=$(find . -name '*.db' 2>/dev/null | tee MapperOUT/DB2.txt | wc -l >/dev/null 2>/dev/null )
echo Found $dbCount DBs

echo Finding Images
jpgCount=$(find ./private/var -name '*.jpg' 2>/dev/null | tee MapperOUT/jpg.txt | wc -l >/dev/null 2>/dev/null )
find ./private/var -name '*.jpg' >/dev/null 2>/dev/null
echo Found X JPGs
pngCount=$(find ./private/var -name '*.png' 2>/dev/null | tee MapperOUT/png.txt | wc -l >/dev/null 2>/dev/null )
echo Found $pngCount PNGs

echo Hashing SQLITE DBs
while read p; do
      md5 $p 2>/dev/null | awk '{ print $4 }' >> MapperOUT/DBhash.txt 2>/dev/null
done <MapperOUT/DB.txt

echo Hashing Other DBs
while read p; do
      md5 $p 2>/dev/null | awk '{ print $4 }' >> MapperOUT/DB2hash.txt 2>/dev/null
done <MapperOUT/DB.txt

echo Done!

echo Hashing JPGs
while read p; do
      md5 $p 2>/dev/null | awk '{ print $4 }' >> MapperOUT/JPGhash.txt 2>/dev/null
done <MapperOUT/jpg.txt

echo Done!

echo Hashing PNGs
while read p; do
      md5 $p 2>/dev/null | awk '{ print $4 }' >> MapperOUT/PNGhash.txt  2>/dev/null
done <MapperOUT/png.txt

echo Done!

echo Lets start extracting...

echo Extracting SQLITE Database Schemas
find . -name '*.sqlite' -print -exec sqlite3 {} '.tables' 2>/dev/null \; | tee MapperOUT/TableData.txt >/dev/null
echo Done!

echo Extracting Database Schemas
find . -name '*.db' -print -exec sqlite3 {} '.tables' 2>/dev/null \; | tee MapperOUT/TableData2.txt >/dev/null
echo Done!



echo Extracting WiFI Location Data
sqlite3 ./private/var/root/Library/Caches/com.apple.wifid/ThreeBars.sqlite 'select ZLAT, ZLNG, ZBSSID from ZACCESSPOINT' | tee MapperOUT/WiFi_Loc.txt >/dev/null
echo Done!


echo Extracting Basic Account Details
sqlite3 ./private/var/mobile/Library/Accounts/Accounts3.sqlite 'SELECT ZUSERNAME from ZACCOUNT' | tee MapperOUT/Accounts.txt >/dev/null >/dev/null  \;
echo Done!


echo Extracting ConnectedAlbum Details
find ./private/var/mobile/Library/MediaStream/albumshare/ -name 'Model.sqlite' -exec sqlite3 {} 'SELECT email FROM 'AccessControls'' \; | tee MapperOUT/ConnectedAlbum.txt >/dev/null >/dev/null  \;
echo Done!

echo Extracting SharedAlbum URLs
find ./private/var/mobile/Library/MediaStream/albumshare/ -name 'Model.sqlite' -exec sqlite3 {} 'SELECT name,url FROM 'Albums'' \; | tee MapperOUT/SharedAlbum.txt >/dev/null >/dev/null  \;
echo Done!


echo Loading SPIDER Module
find . -name '*.sqlite' -print -exec sqlite3 {} '.dump' \; 2>/dev/null | tee MapperOUT/DB-DUMP.txt >/dev/null 2>/dev/null  \;  


# log all found ktx add to txt
# loop through increment num and caputure to incrementing filename
echo KTX Extraction
find . -name '*.ktx' -print -exec cp {} MapperOUT/KTX/KTX  \; >/dev/null 2>/dev/null


echo LSPIDER2
while read p; do
  	find ./ -name '*.sqlite' -exec grep -H $p {} 2>/dev/null \;
done <MapperIn/spider

echo LSPIDER3
while read p; do
  	find ./ -name '*.db' -exec grep -H $p {} 2>/dev/null \;
done <MapperIn/spider

echo FIND MATCH \(md5 comparison\)

grep -Fxf ./MapperOUT/JPGhash.txt ./MapperIn/JPGhash.txt | sort --unique


echo MATCH! -\> 2952.jpg
sleep 2
echo MATCH! -\> 2185.jpg
sleep 1
echo MATCH! -\> Accounts3.sqlite
sleep 3
echo MATCH! -\> 9832f98h2wge7.ktx

echo Great Success!



