#!/bin/bash


# in the directory with all the 7z archives, make a folder and cd into it. then clone the ssrptc git repo here
# now run this script to generate a script that will extract and convert the files to ccd/img/sub format.
# you can keep a log with:
# $ ./unar_script.sh 2>&1 | tee -a logfile 

echo "#!/bin/bash" > unar_script.sh
echo "set -x -e" >> unar_script.sh
echo "exec > >(tee -a script.log) 2>&1" >> unar_script.sh

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for i in $(LANG=C; find .. -type f -name "*.7z" -exec basename {} '.7z' \; | sort); do 
    echo "unar \"../$i.7z\"; cd \"$i\"; ../ssrptc/cue2ccd.py \"$i.cue\"; ../ssrptc/bin2img.sh; rm *.bin; cd .."
done >> unar_script.sh
IFS=$SAVEIFS

chmod +x unar_script.sh
