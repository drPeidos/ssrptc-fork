#!/bin/bash

rm out.iso
echo "01.title=RMENU" > RMENU_020/LIST.INI
echo "01.disc=1/1" >> RMENU_020/LIST.INI
echo "01.region=JTUE" >> RMENU_020/LIST.INI
echo "01.version=V0.1.3" >> RMENU_020/LIST.INI
echo "01.date=20151205" >> RMENU_020/LIST.INI


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

    echo "$i.title=$TITLE" >> RMENU_020/LIST.INI
    echo "$i.disc=$DISC" >> RMENU_020/LIST.INI
    echo "$i.region=$REGION" >> RMENU_020/LIST.INI
    echo "$i.version=$VERSION" >> RMENU_020/LIST.INI
    echo "$i.date=$DATE" >> RMENU_020/LIST.INI

done

# https://assemblergames.com/threads/official-rhea-discussion.57377/page-26#post-938291
# it didnt work...
#let "i++"
#echo " i = $i"
#for i in $(seq -f "%02g" $i 24); do
#    TITLE="EMPTY FOLDER"
#    DISC="1/1"
#    REGION=" "
#    VERSION=" "
#    DATE=" "
#    echo "adding 'EMPTY FOLDER' entry for $i"
#    echo "$i.title=$TITLE" >> RMENU_020/LIST.INI
#    echo "$i.disc=$DISC" >> RMENU_020/LIST.INI
#    echo "$i.region=$REGION" >> RMENU_020/LIST.INI
#    echo "$i.version=$VERSION" >> RMENU_020/LIST.INI
#    echo "$i.date=$DATE" >> RMENU_020/LIST.INI
#done



mkisofs -sysid "SEGA SATURN" -volid "SaturnApp" -volset "SaturnApp" -publisher "SEGA ENTERPRISES, LTD." -preparer "SEGA ENTERPRISES, LTD." -appid "SaturnApp" -abstract "./RMENU_020/ABS.TXT" -copyright "./RMENU_020/CPY.TXT" -biblio "./RMENU_020/BIB.TXT" -generic-boot "./RMENU_020/IP.BIN" -full-iso9660-filenames -o out.iso ./RMENU_020/
