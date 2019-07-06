#!/usr/bin/python3

# http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-130.pdf

# convert MODE1/2048 (iso) to MODE1/2352 (bin)

# each 2352 sector contains in this order:
#
# Sync: 12 bytes ( is always 00 ff ff ff ff ff ff ff ff ff ff 00 )
# Sector Address: 3 bytes, ( first byte is A-MIN, second byte is A-SEC, third time is A-FRAME) (counting the frames since the begining of the of the disc, not including lead-in)
# Mode: 1 byte (always 0x01)
# User Data: 2048 bytes (the iso file, taken in 2048 byte segments)
# EDC: 4 bytes (P(x) = (x**16 + x**15 + x**2 + 1) . (x**16 + x**2 + x + 1))
# Intermediate: 8 bytes (always 8 0x00 bytes)
# P-Parity: 172 bytes
# Q-Parity: 104 Bytes
#
# 12 + 3  + 1 + 2048 + 4 + 8 + 172 + 104 = 2352 

# https://github.com/xdotnano/PSXtract/blob/master/Windows/cdrom.h

# vatlv track 1 line   1: 00 ff ff ff ff ff ff ff ff ff ff 00 00 02 00 01
# vatlv track 1 line  99: 00 ff ff ff ff ff ff ff ff ff ff 00 00 02 01 01
# vatlv track 1 line 197: 00 ff ff ff ff ff ff ff ff ff ff 00 00 02 02 01

