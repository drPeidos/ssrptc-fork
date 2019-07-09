#!/bin/bash

#set -u -x


-rwxr-xr-x 1 root root  240534 Jul  9 07:39 RMENU_KAI_6314.BIN
-rwxr-xr-x 1 root root    1995 Jul  9 07:39 rmenu_020.sh
-rwxr-xr-x 1 root root  123920 Jul  9 07:39 RMENU_020.BIN
-rwxr-xr-x 1 root root  115284 Jul  9 07:39 RMENU_013.BIN


if [ "$2" = '013' ]; then
    ZEROBIN='RMENU_013.BIN'
elif [ "$2" = '020' ]; then
    ZEROBIN='RMENU_020.BIN'
elif [ "$2" = 'kai' ]; then
    ZEROBIN='RMENU_KAI_6314.BIN'
else
    echo 'you must choose which version of RMENU you want and provide it as $2'
    echo 'options are 013 or 020 or kai'
    echo 'example: ./rmenu.sh kai'
fi


rm out.iso
rm RMENU/LIST.INI
rm RMENU/0.BIN
cp $ZEROBIN RMENU/0.BIN
echo "01.title=RMENU" > RMENU/LIST.INI
echo "01.disc=1/1" >> RMENU/LIST.INI
echo "01.region=JTUE" >> RMENU/LIST.INI
echo "01.version=V0.0.0" >> RMENU/LIST.INI
echo "01.date=00000000" >> RMENU/LIST.INI


for i in $(find ../ -maxdepth 1 -type d -name "[0-9]*" | awk -F'/' '{print $NF}' | sort -n | egrep -v '^1$|^01$|^001$'); do
    IMG="$(find ../$i/*.img)"
    if [ x"$IMG" == 'x' ]; then
        :
    else
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

        echo "$i.title=$TITLE" >> RMENU/LIST.INI
        echo "$i.disc=$DISC" >> RMENU/LIST.INI
        echo "$i.region=$REGION" >> RMENU/LIST.INI
        echo "$i.version=$VERSION" >> RMENU/LIST.INI
        echo "$i.date=$DATE" >> RMENU/LIST.INI
    fi

done


mkisofs -sysid "SEGA SATURN" -volid "SaturnApp" -volset "SaturnApp" -publisher "SEGA ENTERPRISES, LTD." -preparer "SEGA ENTERPRISES, LTD." -appid "SaturnApp" -abstract "./RMENU/ABS.TXT" -copyright "./RMENU/CPY.TXT" -biblio "./RMENU/BIB.TXT" -generic-boot "./RMENU/IP.BIN" -full-iso9660-filenames -o out.iso ./RMENU/
