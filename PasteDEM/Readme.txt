This is to paste dem files downloaded from 30-Meter SRTM Tile Downloader
https://dwtkns.com/srtm30m/
(Requires a NASA Earthdata login to download the files)

1. unzip all the dem tiles using Unzip.csh (no parameters needed)
2. Open Paste.csh to put in the parameters.
seq: a series of the two digits that followed after N or S
Pre1: a 3-digit number that followed E or W
Pre2: another 3-digit number that followed E or W
seq2: a series of the rest 3-digit numbers that followed E or W
NS: N or S
EW: E or W

An example of it could be:
All the dem tiles:
N31E068.hgt	N32E068.hgt	N33E068.hgt	N34E068.hgt
N31E069.hgt	N32E069.hgt	N33E069.hgt	N34E069.hgt
N31E070.hgt	N32E070.hgt	N33E070.hgt	N34E070.hgt
N31E071.hgt	N32E071.hgt	N33E071.hgt	N34E071.hgt

seq = (31 32 33 34)
Pre1 = 068
Pre2 = 069
seq2 = (070 071)
