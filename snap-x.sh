#!/bin/sh

#  snap-x.sh - duffy.app - @J_Duffy01
#
#   TODO
#   -   Automatic Bundle ID Detection
#   -   Add some ASCII art or something
#
#  Created by x_010010 on 19/03/2021.
#  

echo "DuffyAPP-IT $(date)"

if [ $# -eq 0 ]
then
    echo "Snap - DuffyAPP - @J_Duffy01\nUsage: ./snap-x APP_BUNDLE_ID"
    exit 1
fi

#Remove Current Temporary Directory
rm -rf snap_proc 2>/dev/null

if [ ! -d snap_proc ]
    then
    
    echo "[+] Creating Working Folder"
    mkdir snap_proc
    
    cd snap_proc
    
    while [ 1 ];
    do
        echo "[+] Processing..."

        # Try wildcard, should make it more universal...
        sshpass -p alpine scp -r -p -P 2222 root@127.0.0.1:/private/var/mobile/Containers/Data/Application/73598F2C-9219-4633-AF8D-3351FDCA9E37/Documents/com.snap.file_manager_3_SCContent_* .
        
        #sshpass -p alpine scp -r -p -P 2222 root@127.0.0.1:/private/var/mobile/Containers/Data/Application/73598F2C-9219-4633-AF8D-3351FDCA9E37/Documents/com.snap.file_manager_3_SCContent_1d5af270-d5d7-49cd-99bf-38480ad309bd/ .
        
        find . -type f -mtime -10s -exec open -a Preview {} \;
        
        count="$(find . -type f -mtime -10s | wc -l)"
            
        echo "Extracted $count Snaps - [+]"
        
#        touch -a -m $newfile
        sleep 5;
    done
fi
