#!/bin/csh -f
#
##############################################################
# This is to extract range offset from freq_xcorr.dat        #
#                                                            #
# Just some simple modification from make_a_offset.csh       #
# Source: GMTSAR                                             #
##############################################################
#							     #
#       Department of Geography, National Taiwan University  #
#      							     #
#                          Lin,Li-Chieh                      #
#                           2021.07.12                       #
##############################################################
#
#Some notes on the product of xcorr (freq_xcorr.dat)
#col1: x coordinate
#col2: slant-range offset
#col3: y coodinate
#col4: azimuth offset
#col5: SNR
#
#

if ($#argv != 3) then
   echo ""
   echo "Usage: take_r_offset.csh PRM nx ny"
   echo ""
   echo "       PRM - Referenced PRM (just for range sampling rate)  "
   echo "       nx - The number which used when doing make_a_offset.csh (~num_rng/4) "
   echo "       ny - The number which used when doing make_a_offset.csh (~num_az/6) "
   echo ""
   echo "       Do this in azi_offset/(the original output from make_a_offset.csh)  "
   echo ""
   exit 1
endif
echo "take_r_offset.csh" $1 $2 $3

#
set PRM = $1
set nx = $2
set ny = $3
set fs = `grep rng_samp_rate $PRM | awk -F"=" 'NR==1 {print $2}'`
set c = 300000000 # Speed of light

#
# Compute the range pixel size
# rng_size = c/2*fs
#
set rng_size = `echo $c $fs | awk '{print $1/(2*$2)}'`
echo "range pixel size = "$rng_size


awk '{if ($4>-1.1 && $4<1.1) print $1,$3,$2,$5}'  freq_xcorr.dat > rng.dat
set xmin = `gmt gmtinfo rng.dat -C |awk '{print $1}'`
set xmax = `gmt gmtinfo rng.dat -C |awk '{print $2}'`
set ymin = `gmt gmtinfo rng.dat -C |awk '{print $3}'`
set ymax = `gmt gmtinfo rng.dat -C |awk '{print $4}'`
#
set xinc = `echo $xmax $xmin $nx |awk '{printf "%d", ($1-$2)/($3-1)}'`
set yinc = `echo $ymax $ymin $ny |awk '{printf "%d", ($1-$2)/($3-1)}'`
#
set xinc = `echo $xinc | awk '{print $1*12}'`
set yinc = `echo $yinc | awk '{print $1*12}'`
echo "xinc:"$xinc"  yinc:"$yinc

gmt blockmedian rng.dat -R$xmin/$xmax/$ymin/$ymax  -I$xinc/$yinc -Wi | awk '{print $1, $2, $3}'  > rng_b.dat
gmt xyz2grd rng_b.dat -R$xmin/$xmax/$ymin/$ymax  -I$xinc/$yinc -Groff.grd 
gmt grdmath roff.grd $rng_size MUL = rng_offset.grd
#
gmt grd2cpt rng_offset.grd -Cpolar -E30 -D > rngoff.cpt
gmt grdimage rng_offset.grd -JX5i -Crngoff.cpt -Q -P > rngoff.ps

#
#  Project to lon/lat

proj_ra2ll_ascii.csh trans.dat rng_b.dat roff.llo

set xmin2 = `gmt gmtinfo roff.llo -C |awk '{print $1}'`
set xmax2 = `gmt gmtinfo roff.llo -C |awk '{print $2}'`
set ymin2 = `gmt gmtinfo roff.llo -C |awk '{print $3}'`
set ymax2 = `gmt gmtinfo roff.llo -C |awk '{print $4}'`
#
set xinc2 = `echo $xmax2 $xmin2 $nx |awk '{printf "%12.5f", ($1-$2)/($3-1)}'`
set yinc2 = `echo $ymax2 $ymin2 $ny |awk '{printf "%12.5f", ($1-$2)/($3-1)}'`
set xinc2 = `echo $xinc2 | awk '{print $1*12}'`
set yinc2 = `echo $yinc2 | awk '{print $1*12}'`
#
echo "xinc2:"$xinc2"  yinc2:"$yinc2


#
gmt xyz2grd roff.llo -R$xmin2/$xmax2/$ymin2/$ymax2  -I$xinc2/$yinc2 -r -fg -Groff_ll.grd
gmt grdmath roff_ll.grd $rng_size MUL = rng_offset_ll.grd
#
gmt grdsample dem.grd -Gs_dem.grd -R$xmin2/$xmax2/$ymin2/$ymax2 -I$xinc2/$yinc2 -r
gmt grdgradient dem.grd -Gtmp.grd -A325 -Nt.5
gmt grdmath tmp.grd .5 ADD = dem_grd.grd
gmt grdgradient s_dem.grd -Gs_dem_grd.grd -A45 -Nt.5

#
# plot the range offset
#
set r_topo = `gmt grdinfo dem.grd -T100`
gmt makecpt -Cgray -T-1/1/.1 -Z > topo.cpt
#
set x1 = `gmt grdinfo rng_offset_ll.grd -C |awk '{print $2 }'`
set x2 = `gmt grdinfo rng_offset_ll.grd -C |awk '{print $3 }'`
#
set y1 = `gmt grdinfo rng_offset_ll.grd -C |awk '{print $4 }'`
set y2 = `gmt grdinfo rng_offset_ll.grd -C |awk '{print $5 }'`
#
set xlim = `echo $x2 $x1|awk '{print $1-$2}'`
set ylim = `echo $y2 $y1|awk '{print $1-$2}'`
#
set length = 20 
set width = 16
#
set scl1 = `echo $ylim $length | awk '{print $2/$1 }' `
set scl2 = `echo $xlim $width | awk '{print $2/$1}'`
set scl = `echo $scl1 $scl2 | awk '{if ($1<$2) {print $1} else {print $2} }'`
#
set bounds = `gmt grdinfo -I- rng_offset_ll.grd`
#
gmt gmtdefaults -Ds > gmt.conf
gmt set MAP_FRAME_TYPE plain
#
gmt psbasemap -Baf -BWSne -Jm$scl"c" $bounds -K -P > rngoff_ll.ps
gmt grdimage dem_grd.grd -J -R -Ctopo.cpt -K -O -Q >> rngoff_ll.ps
#gmt grdimage azi_offset_ll.grd -Is_dem_grd.grd -J -R -Cazioff.cpt -Q -K -O >> azioff_ll.ps
gmt grdimage rng_offset_ll.grd -J -R -Crngoff.cpt -Q -K -O >> rngoff_ll.ps
gmt pscoast -N3,2p -W1,1p -Slightblue -J -R -K -O -Df -I1 >> rngoff_ll.ps
gmt psscale -Rrng_offset_ll.grd -J -DJTC+w5c/0.35c+e -Crngoff.cpt -Bxaf -By+lm -O >> rngoff_ll.ps 
gmt psconvert rngoff_ll.ps -P -Tg -Z
echo "Range Offset map: rngoff_ll.png"
