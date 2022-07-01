#!bin/csh
#################################################################################
#										#
# This code is to prepare dem.grd for GMTSAR from 30-Meter SRTM Tile Downloader #
# https://dwtkns.com/srtm30m/							#
#										#
# Requires NASA Earthdata login to download the files 			 	#
# 										#
# dem.grd is the final pasted dem file. Readily be used in GMTSAR 		#
#################################################################################
# seq: The first two digits followed N or S (Lat): series
# Pre1: The three digits followed E or W (Lon): one number
# Pre2: The three digits followed E or W (Lon): one number
# seq2 The three digits followed E or W (Lon): series
# NS: The first letter, N or S
# EW: The first letter, E or W
set seq = (23 24 25 26)
set Pre1 = 044
set Pre2 = 045
set seq2 = (046 047 048)
set NS = N
set EW = E

##First step
foreach num ($seq)
gmt grdpaste ${NS}${num}${EW}$Pre1.hgt ${NS}${num}${EW}$Pre2.hgt -Gtmp -V

	foreach i ($seq2)
	gmt grdpaste tmp ${NS}${num}${EW}$i.hgt -Gtmp -V
	end

mv tmp topo${NS}${num}.grd
end

##Second step
gmt grdpaste topo${NS}$seq[1].grd topo${NS}$seq[2].grd -Gtmp -V
ls topo${NS}*.grd > filelist
set Row = `cat filelist | wc -l`
foreach grd (`cat filelist`)
@ j +=1
if ( $j == 1 || $j == 2 ) then
	echo "Already done: Skip"
	continue	
else if ( $j != $Row ) then
	echo "Do it"
	gmt grdpaste tmp topo${NS}$seq[$j].grd -Gtmp -V
else
	echo "Last time"
	echo "File name: dem.grd"
	gmt grdpaste tmp topo${NS}$seq[$j].grd -Gdem.grd -V
endif
end


