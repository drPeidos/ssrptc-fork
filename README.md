#!/bin/false 
```

SSRPTC - Sega Saturn Rhea Phoebe Tool Collection

all tools have only been tested on a GNU/Linux environment. YMMV. forks / patches / etc. are welcome
all source code is licensed under the GNU GPL V2 or later. 


cue2ccd.py - creates a ccd file and a "dummy" sub file from the cue/bin files
               the only arguement it requires is a cuefile.
               run it with your current working directory being the folder a bin/cue file is in
               it produces a ccd file named out.ccd and a subfile named out.sub

bin2img.sh - simple script to concatenate all bin files in the proper order to get a single img file
               run this in the same directory as cue2ccd.py with no arguements
               it produces a file called out.img

iso2bin.py - create a img format bin from an iso, not finished yet

make_library_conversion_script.sh - used to make the master conversion script to convert all of the REDUMP collection to ccd/sub/img

setup_numerical_names.sh - used to rename all the game directories into the 01/10/100 scheme required by pheobe

restore_original_names.sh - used to rename all folders created with setup_numerical_names.sh back to their original name

watch_folder_size.sh - just a script to monitor a folders size so you can plan out what games you want before actually copying them to the sdcard

setup_sd.txt - tutorial on setting up / managing the sdcard for phoebe with these tools

rmenu.sh - build the menu, must provide 013 or 020 or kai as the only arguement

Ecma-130.pdf - technical documentation that was very helpful when developing cue2ccd.py and iso2bin.py

Phoebe.ini - the pheobe config file that works for me

build-saturn-sdk-gcc-sh2.sh - scripts to build a compiler to create binaries for sega saturn
this is just a refactored version of https://github.com/SaturnSDK/Saturn-SDK-GCC-SH2



regarding the license of RMENU:
RMENU doesnt have a license, or source code available. these scripts I provided are a replacement for the exe files that come in the original archive
you can get those here:
https://www.softpedia.com/get/Others/Miscellaneous/RMenu.shtml
https://www.mediafire.com/file/4sbn2oqpoh8898t/RMENU_v0.2.zip

regarding the license of RMENU_KAI:
RMENU_KAI is licensed under the GNU GPL V2
however the author of RMENU_KAI is unwilling to provide full source code.
this means RMENU_KAI cant be compiled with the sources made available by its author.
RMENU_KAI is in violation of its license and you should email them demanding full source code!
http://ppcenter.webou.net/pskai/


EXTRA NOTES:
 * I have noticed that with a 4gb sdcard with 10 games, rmenu_020 and rmenu_kai_6314
   do not boot the game correctly and i get stuck at a black screen after the sega licensing screen.
   only rmenu_013 with the slow original reset will load the games. 
   also you have to comment out 'reset_goto = 1' in Phoebe.ini in the root of the sdcard

   however with a 128gb card and over 100 games, rmenu_013 doesnt work and only rmenu_020 and rmenu_kai_6314 work...
   also high_speed = 1 needs to be commented out otherwise it wont boot anything


```
