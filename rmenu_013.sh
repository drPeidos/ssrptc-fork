#!/bin/bash

rm out.iso
echo "01.title=RMENU" > RMENU_013/LIST.INI
echo "01.disc=1/1" >> RMENU_013/LIST.INI
echo "01.region=JTUE" >> RMENU_013/LIST.INI
echo "01.version=V0.1.3" >> RMENU_013/LIST.INI
echo "01.date=20151205" >> RMENU_013/LIST.INI


for i in $(find ../ -maxdepth 1 -type d -name "[0-9]*" | awk -F'/' '{print $NF}' | sort -n | egrep -v '^1$|^01$|^001$'); do
    IMG="$(find ../$i/*.img)"
    TITLE="$(head -c 224 "$IMG" | cut -c 113-225 | LANG=C sed 's/ *$//g')"
    DISC="$(head -c 224 "$IMG" | cut -b 76-78)"
    REGION="$(head -c 224 "$IMG" | cut -b 81)"
    VERSION="$(head -c 224 "$IMG" | cut -b 59-64)"
    DATE="$(head -c 224 "$IMG" | cut -b 65-72)"

    echo "$i.img=$IMG"
    echo "$i.title=$TITLE" 
    echo "$i.disc=$DISC" 
    echo "$i.region=$REGION" 
    echo "$i.version=$VERSION" 
    echo "$i.date=$DATE" 

    echo "$i.title=$TITLE" >> RMENU_013/LIST.INI
    echo "$i.disc=$DISC" >> RMENU_013/LIST.INI
    echo "$i.region=$REGION" >> RMENU_013/LIST.INI
    echo "$i.version=$VERSION" >> RMENU_013/LIST.INI
    echo "$i.date=$DATE" >> RMENU_013/LIST.INI

done


mkisofs -sysid "SEGA SATURN" -volid "SaturnApp" -volset "SaturnApp" -publisher "SEGA ENTERPRISES, LTD." -preparer "SEGA ENTERPRISES, LTD." -appid "SaturnApp" -abstract "./RMENU_013/ABS.TXT" -copyright "./RMENU_013/CPY.TXT" -biblio "./RMENU_013/BIB.TXT" -generic-boot "./RMENU_013/IP.BIN" -full-iso9660-filenames -o out.iso ./RMENU_013/
