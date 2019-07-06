#!/usr/bin/env python3

import os
import sys

def printhelp():
    # $1 - input cue
    # $2 - input bin
    return 0

def frames2minsec(tf):
    # u = uncleaned, c = cleaned
    us = int(tf/75)
    cf = int(tf - (us*75))
    cm = int(us /60)
    cs = int(us - (cm * 60))
    #print("m={}    s={}    f={}".format(cm,cs,cf))
    formatted_timing = "{0:02d}:{1:02d}:{2:02d}".format(cm,cs,cf)
    return formatted_timing

def minsec2frames(input_msf):
    minutes = int(input_msf.split(":")[0])
    seconds = int(input_msf.split(":")[1])
    frames = int(input_msf.split(":")[2])
    total_frames = (((minutes * 60) + seconds) *75) + frames
    return total_frames

def frames2bytes(input_frames):
# TODO check to make sure this is a clean number with no decimal or remainder, otherwise this indicates the bytes per frame of 2352 is not correct
    _bytes = input_frames * 2352
    return _bytes

def bytes2frames(input_bytes):
# TODO check to make sure this is a clean number with no decimal or remainder, otherwise this indicates the bytes per frame of 2352 is not correct
    _frames = input_bytes / 2352
    _frames_str = str(_frames)
    after_decimal = int(_frames_str.split('.')[1])
    if after_decimal != 0:
        print("INPUTBYTES: {0} IS NOT CLEANLY DIVISIBLE BY 2352!! {0} / 2352 = {1}".format(input_bytes, _frames))
        print("exiting...")
        quit()
    else: 
        return int(_frames)

def getsizeofbin(bin_file_location):
    size_of_bin = os.path.getsize(bin_file_location)
    return size_of_bin

def generate_nested_dict_from_cuefile(cue_file_location):

    with open(cue_file_location, "r") as myfile:
        cuelist=myfile.read().splitlines() 

    disc_toc = {}
    linelist = []
    cueline = 0
    linelist = cuelist[cueline].split()
    file_list = []
    frames_before_current_track = 0
    accumulated_frames = 0
    pregap_spacing = None
    def cuestep():
        nonlocal cueline
        nonlocal cuelist
        cueline +=1
        if cueline >= len(cuelist):
            return "END_OF_FILE"
        else:
            linelist = cuelist[cueline].split()
            return linelist

    while linelist != "END_OF_FILE":
        if linelist[0].lower() == 'catalog':
            linelist = cuestep()
        if linelist[0].lower() == 'file':
            current_file = ' '.join(linelist).split('"')[1]
            file_list.append(current_file)
            try:
                current_file_size = getsizeofbin(cue_file_location.rsplit('/', 1)[0] + '/' + current_file)
            except IOError:
                print('ERROR: file not found: {}'.format(current_file))
                print('FIX THE CUESHEET FILE LOCATIONS, OR RENAME INPUT FILES. EXITING...')
                quit()
            linelist = cuestep()
        elif linelist[0].lower() == 'track':
            track_number = "{0:02d}".format(int(linelist[1]))
            disc_toc['track' + str(track_number)] = {}
            disc_toc['track' + str(track_number)]['file'] = current_file
            disc_toc['track' + str(track_number)]['file_size'] = current_file_size
            disc_toc['track' + str(track_number)]['mode'] = linelist[-1]
            disc_toc['track' + str(track_number)]['indexes'] = {}
            linelist = cuestep()
            #print(disc_toc)
            while linelist[0].lower != 'track' and linelist != "END_OF_FILE":
                if linelist[0].lower() == 'index' or linelist[0].lower() == 'pregap':
                    if linelist[0].lower() == 'pregap':
                        pregap_spacing = linelist[1]
                        linelist.append(linelist[1])
                        linelist[0] = 'INDEX'
                        linelist[1] = '0'
                    index_number = int(linelist[1])
                    disc_toc['track' + str(track_number)]['indexes'][str(index_number)] = {}
                    if len(file_list) > 1: # 
                        # at the begining of a disc we assume all times given in the cuefile are absolute,
                        # however as soon as a second file is detected, we know all tracks coming forward
                        # will be relative to their FILE declaration, either way, track 1 times are acceptable for both aboslute and relative values
                        disc_toc['track' + str(track_number)]['indexes'][str(index_number)]['rtime'] = linelist[-1]
                        if len(disc_toc['track' + str(track_number)]['indexes']) == 1:
                            accumulated_frames += bytes2frames(disc_toc['track' + "{0:02d}".format(int(track_number) - 1)]['file_size'])
                        disc_toc['track' + str(track_number)]['indexes'][str(index_number)]['atime'] = frames2minsec(accumulated_frames + minsec2frames(disc_toc['track' + str(track_number)]['indexes'][str(index_number)]['rtime']))

                    else:
                        # first file in cuesheet, or all times given are absolute from the cuesheet
                        disc_toc['track' + str(track_number)]['indexes'][str(index_number)]['atime'] = linelist[-1]
                        first_index_in_track = sorted(disc_toc['track' + str(track_number)]['indexes'])[0]
                        accumulated_frames = minsec2frames(disc_toc['track' + str(track_number)]['indexes'][str(first_index_in_track)]['atime'])
                        disc_toc['track' + str(track_number)]['indexes'][str(index_number)]['rtime'] = frames2minsec(minsec2frames(linelist[-1]) - accumulated_frames)
                    linelist = cuestep()
                elif linelist[0].lower() == 'pregap':
                    disc_toc['track' + str(track_number)]['pregap'] = linelist[-1]
                    linelist = cuestep()
                elif linelist[0].lower() == 'postgap':
                    print("POSTGAP NOT IMPLEMENTED")
                    print('exiting...')
                    quit()
                    disc_toc['track' + str(track_number)]['postgap'] = linelist[-1]
                    linelist = cuestep()
                elif linelist[0].lower() == 'title':
                    linelist = cuestep()
                elif linelist[0].lower() == 'performer':
                    linelist = cuestep()
                elif linelist[0].lower() == 'songwriter':
                    linelist = cuestep()
                elif linelist[0].lower() == 'track' or linelist[0].lower() == 'file':
                    break
                else:
                    print("Command: {} is not supported, exiting...".format(linelist[0].lower())) 
                    quit()
            if pregap_spacing:
                 disc_toc['track' + str(track_number)]['indexes']['0']['rtime'] = "00:00:00"
                 disc_toc['track' + str(track_number)]['indexes']['0']['atime'] = frames2minsec(minsec2frames(disc_toc['track' + str(track_number)]['indexes']['1']['atime']) - minsec2frames(pregap_spacing))
                 disc_toc['track' + str(track_number)]['indexes']['1']['rtime'] = pregap_spacing 
                 pregap_spacing = None
        elif linelist[0].lower() != 'file'  \
        and linelist[0].lower() != 'track'  \
        and linelist[0].lower() != 'index'  \
        and linelist[0].lower() != 'pregap' \
        and linelist[0].lower() != 'pregap' \
        and linelist[0].lower() != 'catalog':
            print('the only supported cue command words are FILE TRACK INDEX PREGAP POSTGAP CATALOG')
            print('{} is not a valid cue command. exiting...'.format(linelist[0]))
            quit()
    return disc_toc

def generate_ccd(disc_toc_dict, leadout_pos):
    # get full size of bin
    leadout_timing = frames2minsec(leadout_pos)
    lo_m = int(leadout_timing.split(":")[0])
    lo_s = int(leadout_timing.split(":")[1]) + 2
    lo_f = int(leadout_timing.split(":")[2])
    if lo_s >= 60:
        lo_s -= 60
        lo_m += 1

    ccd  = '[CloneCD]' 			+ '\n'
    ccd += 'Version=3' 			+ '\n'
    ccd += '' 				+ '\n'
    ccd += '[Disc]' 			+ '\n'
    ccd += 'TocEntries=' + str(len(disc_toc) + 3) + '\n'
    ccd += 'Sessions=1'			+ '\n'
    ccd += 'DataTracksScrambled=0' 	+ '\n'
    ccd += 'CDTextLength=0' 		+ '\n'
    ccd += '' 				+ '\n'
    ccd += '[Session 1]' 		+ '\n'
    ccd += 'PreGapMode=1' 		+ '\n' # TODO
    ccd += 'PreGapSubC=0' 		+ '\n' # TODO
    ccd += '' 				+ '\n'
    ccd += '[Entry 0]' 			+ '\n'
    ccd += 'Session=1' 			+ '\n'
    ccd += 'Point=0xa0' 		+ '\n'
    ccd += 'ADR=0x01' 			+ '\n'
    ccd += 'Control=0x04' 		+ '\n'
    ccd += 'TrackNo=0' 			+ '\n'
    ccd += 'AMin=0' 			+ '\n'
    ccd += 'ASec=0' 			+ '\n'
    ccd += 'AFrame=0' 			+ '\n'
    ccd += 'ALBA=-150' 			+ '\n'
    ccd += 'Zero=0' 			+ '\n'
    ccd += 'PMin=1' 			+ '\n'
    ccd += 'PSec=0' 			+ '\n'
    ccd += 'PFrame=0' 			+ '\n'
    ccd += 'PLBA=4350' 			+ '\n'
    ccd += '' 				+ '\n'
    ccd += '[Entry 1]' 			+ '\n'
    ccd += 'Session=1' 			+ '\n'
    ccd += 'Point=0xa1' 		+ '\n'
    ccd += 'ADR=0x01' 			+ '\n'
    ccd += 'Control=0x00' 		+ '\n'
    ccd += 'TrackNo=0' 			+ '\n'
    ccd += 'AMin=0' 			+ '\n'
    ccd += 'ASec=0' 			+ '\n'
    ccd += 'AFrame=0' 			+ '\n'
    ccd += 'ALBA=-150' 			+ '\n'
    ccd += 'Zero=0' 			+ '\n'
    ccd += 'PMin=' + str(len(disc_toc))			+ '\n' # this must be set to how many total tracks there are
    ccd += 'PSec=0' 			+ '\n'
    ccd += 'PFrame=0' 			+ '\n'
    ccd += 'PLBA=' + str(minsec2frames("{}:00:00".format(len(disc_toc))) - 150)	 		+ '\n' # this is set to the equivalent frames for the PMin set earlier, minus ALBA
    ccd += '' 				+ '\n'
    ccd += '[Entry 2]'			+ '\n'
    ccd += 'Session=1'			+ '\n'
    ccd += 'Point=0xa2'			+ '\n'
    ccd += 'ADR=0x01'			+ '\n'
    ccd += 'Control=0x00'		+ '\n'
    ccd += 'TrackNo=0'			+ '\n'
    ccd += 'AMin=0'			+ '\n'
    ccd += 'ASec=0'			+ '\n'
    ccd += 'AFrame=0'			+ '\n'
    ccd += 'ALBA=-150'			+ '\n'
    ccd += 'Zero=0'			+ '\n'
    ccd += 'PMin=' + str(lo_m)		+ '\n'
    ccd += 'PSec=' + str(lo_s)		+ '\n'
    ccd += 'PFrame=' + str(lo_f)			+ '\n'
    ccd += 'PLBA=' + str(leadout_pos)		+ '\n'

    track_number = 1
    ccd_tracklist = ''
    while track_number <= len(disc_toc_dict):
        pmin = int(disc_toc_dict['track' + "{0:02d}".format(track_number)]['indexes']['1']['atime'].split(":")[0])
        psec = int(disc_toc_dict['track' + "{0:02d}".format(track_number)]['indexes']['1']['atime'].split(":")[1]) + 2 
        pframe = int(disc_toc_dict['track' + "{0:02d}".format(track_number)]['indexes']['1']['atime'].split(":")[2])
        if psec >= 60:
            psec -= 60
            pmin += 1
        ccd += '' 				+ '\n'
        ccd +='[Entry ' + str(track_number + 2) + ']'			+'\n'
        ccd +='Session=1'			+'\n'
        ccd +='Point=' + "{0:#0{1}x}".format(track_number,4)			+'\n'
        ccd +='ADR=0x01'			+'\n'
        if disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode'] == 'MODE1/2352' or disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode'] == 'MODE2/2352':
            ccd +='Control=0x04'			+'\n'
        elif disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode'] == 'AUDIO':
            ccd +='Control=0x00'			+'\n'
        else:
            print("unknown track mode: {}".format(disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode']))
            print("exiting...")
            quit()
        ccd +='TrackNo=0'			+'\n'
        ccd +='AMin=0'			+'\n'
        ccd +='ASec=0'			+'\n'
        ccd +='AFrame=0'			+'\n'
        ccd +='ALBA=-150'			+'\n'
        ccd +='Zero=0'			+'\n'
        ccd +='PMin=' + str(pmin)			+'\n'
        ccd +='PSec='	+ str(psec)		+'\n'
        ccd +='PFrame=' + str(pframe)			+'\n'
        ccd +='PLBA=' + str(minsec2frames(disc_toc_dict['track' + "{0:02d}".format(track_number)]['indexes']['1']['atime']))			+'\n' # TODO test again a disck with more indexes than just 00 or 01

        ccd_tracklist += '' + '\n'
        ccd_tracklist += '[TRACK ' + str(track_number) +']' + '\n'
        if disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode'] == 'MODE1/2352':
            ccd_tracklist += 'MODE=1' +'\n'
        elif disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode'] == 'MODE2/2352':
            ccd_tracklist += 'MODE=2' +'\n'
        elif disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode'] == 'AUDIO':
            ccd_tracklist += 'MODE=0' +'\n'
        else:
            print("unknown track mode: {}".format(disc_toc_dict['track' + "{0:02d}".format(track_number)]['mode']))
            print("exiting...")
            quit()
        for index in disc_toc_dict['track' + "{0:02d}".format(track_number)]['indexes']:
            ccd_tracklist += 'INDEX ' + index + '=' + str(minsec2frames(disc_toc_dict['track' + "{0:02d}".format(track_number)]['indexes'][str(index)]['atime'])) + '\n'
        track_number += 1
        
    ccd += ccd_tracklist
    return ccd

def list_files(disc_toc_dict):
    file_list = []
    last_file = disc_toc_dict['track01']['file']
    file_list.append(last_file)
    for key in disc_toc_dict:
        next_file = disc_toc_dict[key]['file']
        if next_file != last_file :
            file_list.append(next_file)
            last_file = next_file
    return file_list

def create_imgfile_from_bin():
    return 0

def get_total_bin_size(disc_toc_dict, cue_file_location):
    total_bin_size = 0
    for current_file in list_files(disc_toc_dict):
       path = cue_file_location.rsplit('/', 1)[0]
       full_file_path = path + '/' + current_file
       total_bin_size += os.path.getsize(full_file_path)       
    return total_bin_size

def generate_sub_file(disc_toc_dict):
#  |----  P  CHANNEL  ----||----  Q  CHANNEL  ----||----  R  CHANNEL  ----||----  S  CHANNEL  ----||----  T  CHANNEL  ----||----  U  CHANNEL  ----||----  V  CHANNEL  ----||----  W  CHANNEL  ----|
#                          abcdefghijklmnopqrstuvwx     
#                          012101001643004739490db4
# '000000000000000000000000410201045343000611565bcd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
#
# http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-130.pdf
#
#
#  THIS SECTION IS CALLED THE Q-CHANNEL 
# a  = Control field: either 4 or 0, look at the value for Control under the track in question in the ccd
# b  = q-Mode field: alyways set to 1
# cd = TNO field: track number
# ef = INDEX field: 00 or 01
# gh = RELATIVE MIN
# ij = RELATIVE SEC
# kl = RELATIVE FRAC
# mn = ZERO: always set to zero
# op = ABSOLUTE MIN
# qr = ABSOLUTE SEC
# st = ABSOLUTE FRAC
# uvwx = CRC

    # channels filled with zeros
    P = '000000000000000000000000'
    R = '000000000000000000000000'
    S = '000000000000000000000000'
    T = '000000000000000000000000'
    U = '000000000000000000000000'
    V = '000000000000000000000000'
    W = '000000000000000000000000'
    
        



    # place holders....
    time_dict = {}
    time_dict['rm'] = 0
    time_dict['rs'] = 0
    time_dict['rf'] = 0
    time_dict['am'] = 0
    time_dict['as'] = 2
    time_dict['af'] = 0
    
    pregap_mode = False

    def mmssff_counter(time_dict, index_number, disc_toc_dict):
        nonlocal pregap_mode
        if time_dict['af'] == 74:
            time_dict['af'] -= 74
            if time_dict['as'] == 59:
                time_dict['as'] -= 59
                time_dict['am'] += 1            
            else:
                time_dict['as'] += 1
        else:
            time_dict['af'] += 1
        #print(disc_toc_dict[track_]['indexes']['1'])
        if index_number == '0':
            if time_dict['rf'] == 0:
                time_dict['rf'] += 74
                if time_dict['rs'] == 0:
                    time_dict['rs'] += 59
                    time_dict['rm'] -= 1
                else:
                    time_dict['rs'] -= 1
            else:
                time_dict['rf'] -= 1
        else:
            if time_dict['rf'] == 74:
                time_dict['rf'] -= 74
                if time_dict['rs'] == 59:
                    time_dict['rs'] -= 59
                    time_dict['rm'] += 1            
                else:
                    time_dict['rs'] += 1
            else:
                time_dict['rf'] += 1

            


    subfile_out = open('./out.sub', 'wb')

    crc_table = make_crc_table()
    total_frames = (total_bin_size / 2352)
    track_number = 1
    for track_ in disc_toc_dict:
        track_number = track_.split("track")[-1]
        for index in disc_toc_dict[track_]['indexes']:
            if index == '0':
                index_rtime_offset = disc_toc_dict[track_]['indexes']['1']['rtime']
                time_dict['rm'] = int(index_rtime_offset.split(":")[0])
                time_dict['rs'] = int(index_rtime_offset.split(":")[1])
                time_dict['rf'] = int(index_rtime_offset.split(":")[2])

            frame = 1
            while frame <= disc_toc_dict[track_]['indexes'][index]['frame_size']:
                if disc_toc_dict['track' + str(track_number)]['mode'] == 'MODE1/2352' or disc_toc_dict['track' + str(track_number)]['mode'] == 'MODE2/2352':
                    a = '4'
                elif disc_toc_dict['track' + str(track_number)]['mode'] == 'AUDIO':
                    a = '0'
                else:
                    print("unknown track mode: {}".format(disc_toc_dict['track' + str(track_number)]['mode']))
                    print("exiting...")
                    quit()
                b = '1'
                cd = "{:02d}".format(int(track_number))
                ef = "{:02d}".format(int(index))
                gh = "{:02d}".format(time_dict['rm']) # just have this count up by 1 for each frame loop!!
                ij = "{:02d}".format(time_dict['rs'])
                kl = "{:02d}".format(time_dict['rf'])
                mn = '00'
                op = "{:02d}".format(time_dict['am'])
                qr = "{:02d}".format(time_dict['as'])
                st = "{:02d}".format(time_dict['af'])
                abcdefghijklmnopqrst = a + b + cd + ef + gh + ij + kl + mn + op + qr + st
                #print(abcdefghijklmnopqrst)
                #print("41020104534300061156  <--- example")
                uvwx = "{0:#0{1}x}".format(crc_16(crc_table, bytes.fromhex(abcdefghijklmnopqrst)), 6).split("0x")[1]  # "{0:#0{1}x}".format(track_number,4)
                Q = abcdefghijklmnopqrst + uvwx
                SUBCHANNEL = P + Q + R + S + T + U + V + W
                subfile_out.write(bytes.fromhex(SUBCHANNEL))
                frame += 1
                mmssff_counter(time_dict, index, disc_toc_dict)
    subfile_out.close()

def make_crc_table():
# this a simplified version of gen_table() from pycrc/crc_algorithms.py
    tbl = []
    x = 2 
    polynomial = ((x**16)+(x**12)+(x**5)+(1)) & 0xffff # 0x1021
    for i in range(256):
        reg = i 
        reg = reg << (8)
        for bit in range(8):
            if reg & (0x8000 << 0) != 0:
                reg = (reg << 1) ^ (polynomial << 0)
            else:
                reg = (reg << 1)
        tbl.append((reg >> 0) & 0xffff)
    return tbl 

def crc_16(table, msg):
    crc = 0x0000
    for byte in msg:
        tbl_idx = ((crc >> 8) ^ byte) & 0xff
        crc = (table[tbl_idx] ^ (crc << 8)) & 0xffff
    return crc ^ 0xffff


def test_crc16():
    print(hex(crc_16(bytes.fromhex("41020104534300061156"))))
    print('it should be 0x5bcd')


def append_track_sizes_in_frames(disc_toc, leadout_position_in_frames):

    previous_track_beginning = leadout_position_in_frames
    for track in sorted(disc_toc, reverse=True):
        for index in sorted(disc_toc[track]['indexes'], key=int, reverse=True):
            track_beginning = minsec2frames(disc_toc[track]['indexes'][index]['atime'])
            index_size_in_frames = previous_track_beginning - track_beginning
            disc_toc[track]['indexes'][index]['frame_size'] = index_size_in_frames
            previous_track_beginning = track_beginning
            
    return disc_toc

cuefile = os.path.realpath(sys.argv[1])
disc_toc = generate_nested_dict_from_cuefile(cuefile)
total_bin_size = get_total_bin_size(disc_toc, cuefile)
leadout_position_in_frames = bytes2frames(total_bin_size)
disc_toc = append_track_sizes_in_frames(disc_toc, leadout_position_in_frames)
ccd = generate_ccd(disc_toc, leadout_position_in_frames)
f = open("./out.ccd","w") #opens file with name of "test.txt"
f.write(ccd)
f.close()
table = make_crc_table()
sub = generate_sub_file(disc_toc)
