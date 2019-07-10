#!/bin/bash

set -u -e


if [ x"$1" = 'x013' ]; then
    ZEROBIN='RMENU_013.BIN'
elif [ x"$1" = 'x020' ]; then
    ZEROBIN='RMENU_020.BIN'
elif [ x"$1" = 'xkai' ] || [ x"$1" = 'xpsk' ]; then
    ZEROBIN='RMENU_KAI_6314.BIN'
else
    echo 'you must choose which version of RMENU you want and provide it as the only arguement'
    echo 'options are 013 or 020 or kai or psk'
    echo 'example: ./rmenu.sh kai'
    exit 1
fi


[ -f out.iso ] && rm out.iso
[ -f RMENU/LIST.INI ] && rm RMENU/LIST.INI
[ -f RMENU/0.BIN ] && rm RMENU/0.BIN
cp RMENU/$ZEROBIN RMENU/0.BIN
echo "01.title=RMENU" > RMENU/LIST.INI
echo "01.disc=1/1" >> RMENU/LIST.INI
echo "01.region=JTUE" >> RMENU/LIST.INI
echo "01.version=V0.0.0" >> RMENU/LIST.INI
echo "01.date=00000000" >> RMENU/LIST.INI


for i in $(find ../ -maxdepth 1 -type d -name "[0-9][0-9]" -o -name "[0-9][0-9][0-9]"| awk -F'/' '{print $NF}' | sort -n | egrep -v '^1$|^01$|^001$'); do
    IMG="../$i/out.img"
    if [ -f "$IMG" ]; then

        if [ -f "../$i/ofn.txt" ]; then
            source "../$i/ofn.txt"
            TITLE="$(echo "$ORIGINAL_DIRECTORY_NAME" | cut -c 1-111)"
        else
            TITLE="$(head -c 224 "$IMG" | cut -c 113-225 | LANG=C sed 's/ *$//g')"
        fi
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


echo
echo "press y key to edit RMENU/LIST.INI, or any other key to skip editing names"
echo
read -n 1 YNVAR

if [ x"$YNVAR" == 'xy' ]; then
    vim RMENU/LIST.INI
fi


mkisofs -sysid "SEGA SATURN" -volid "SaturnApp" -volset "SaturnApp" -publisher "SEGA ENTERPRISES, LTD." -preparer "SEGA ENTERPRISES, LTD." -appid "SaturnApp" -abstract "./RMENU/ABS.TXT" -copyright "./RMENU/CPY.TXT" -biblio "./RMENU/BIB.TXT" -generic-boot "./RMENU/IP.BIN" -full-iso9660-filenames -o out.iso ./RMENU/
