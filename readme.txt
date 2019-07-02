SSRPTC - Sega Saturn Rhea Phoebe Tool Collection

all tools have only been tested ina linux environment. YMMV. forks / patches / etc. are welcome

all source code is licensed under the GNU GPL V2 or later. 

cue2ccdsub.py - creates a ccd file and a "dummy" sub file from the cue/bin files

bin2img.sh - simple script to concatenate all bin files in the proper order to get a single img file

ssrp - sega saturn region patcher
    original source code comes from https://www.romhacking.net/utilities/861/
    this version has printf() lines added to show exactly what bytes are being changed
    ( currently its not showing the frame and sector crc changes that are done. WIP)
    
    you can compile this with:
        $ cd ssrp 
        $ gcc ssrp.c -o ssrp


