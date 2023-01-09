#!bin/csh 
#################################################################################
#                                                                               #
# This code is to prepare dem.grd for GMTSAR from 30-Meter SRTM Tile Downloader #
# https://dwtkns.com/srtm30m/                                                   #
#                                                                               #
# Requires NASA Earthdata login to download the files                           #
#                                                                               #
# Lin, Li-Chieh (Jack)                                                          #
#                                                                               #
# Ver.2: 2023.01.09 								#
#  For ocean area where dem tiles are not available. Make null grids to ensure  #
#  grdpaste could work properly. (Having the same edges) 			#
#                                                                               #
# dem.grd is the final pasted dem file. Readily be used in GMTSAR               #
#################################################################################
# seq: The first two digits followed N or S (Lat): series
# Pre1: The three digits followed E or W (Lon): one number
# Pre2: The three digits followed E or W (Lon): one number
# seq2 The three digits followed E or W (Lon): series
# NS: The first letter, N or S
# EW: The first letter, E or W
set seq = (32 33 34 35)
set Pre1 = 067
set Pre2 = 068
set seq2 = (069 070 071)
set NS = N
set EW = E


### Check if there are holes present
## Make null grd for missing tiles using grdlandmask
set colTotal = `echo $Pre1 $Pre2 $seq2 | wc -w`
foreach row ($seq)
set colNow = `ls ${NS}${row}${EW}* | wc -l `

if ($colNow != $colTotal) then
	foreach col (`echo $Pre1 $Pre2 $seq2`)
		if (! -e ${NS}${row}${EW}${col}.hgt) then
		  echo "Missing tile: ${NS}${row}${EW}${col}.hgt"
		  if ($EW == 'E') then
		    set xmin = `echo $col`
		  else if ($EW == 'W') then
		    set xmin = `echo "$col*-1" | bc -l`
		  endif
		  set xmax = `echo "$xmin+1" | bc -l`

		  if ($NS == 'N') then
		    set ymin = `echo $row`
		  else if ($NS == 'S') then
		    set ymin = `echo "$row*-1" | bc -l`
		  endif
		  set ymax = `echo "$ymin+1" | bc -l` 

		  gmt grdlandmask -R$xmin/$xmax/$ymin/$ymax -I1s -G${NS}${row}${EW}${col}.hgt
		  echo "-- Null grd is made:" ${NS}${row}${EW}${col}.hgt
		endif
	end
else
echo "- No missing tiles for $NS $row"
endif
end
echo ""
echo "- Start pasting grds"

### Start pasting
## First step
foreach num ($seq)
echo ""
echo "Pasting: " ${NS}${num}${EW}$Pre1.hgt ${NS}${num}${EW}$Pre2.hgt
gmt grdpaste ${NS}${num}${EW}$Pre1.hgt ${NS}${num}${EW}$Pre2.hgt -Gtmp

        foreach i ($seq2)
        gmt grdpaste tmp ${NS}${num}${EW}$i.hgt -Gtmp
        end

mv tmp topo${NS}${num}.grd
end

## Second step
echo ""
echo "-- Second step"
echo "Pasting: " topo${NS}$seq[1].grd topo${NS}$seq[2].grd
gmt grdpaste topo${NS}$seq[1].grd topo${NS}$seq[2].grd -Gtmp
ls topo${NS}*.grd > filelist
set Row = `cat filelist | wc -l`
foreach grd (`cat filelist`)
@ j +=1
if ( $j == 1 || $j == 2 ) then
        continue
else if ( $j != $Row ) then
        gmt grdpaste tmp topo${NS}$seq[$j].grd -Gtmp
else
	echo ""
        echo "-- Last time"
        echo "Making: dem.grd"
        gmt grdpaste tmp topo${NS}$seq[$j].grd -Gdem.grd
endif
end

