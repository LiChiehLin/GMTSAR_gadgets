#!/bin/csh -f
#
# Extract and plot the Burst Overlap Interferometry from ddphase (align_tops_esd.csh mode 2)
# 
# This is an extensional use of GMTSAR that is modified from GMTSAR c-shell code
# Run this after you've finished p2p_S1_TOPS.csh
# Mind the directories
#
# Lin Li-Chieh
# Department of Geography, National Taiwan University
# 2021.12.17
#
if ($#argv != 2 ) then
 echo " "
 echo "Usage: BOI_processing.csh Reference_prefix Coherence"
 echo " "
 echo "Example: BOI_processing.csh S1_20190704_135158_F2 0.5"
 echo " "
 echo "Output: ddphase_ll.dat ddphase_ll.grd ddphase_pix ddphase_pix_ll.dat ddphase_pix_ll.grd ddphase_disp.dat ddphase_disp_ll.dat ddphase_disp_ll.grd"
 echo ""
 echo "Note: "
 echo "1. suffix with ll is taken with coherence higher than the given coherence"
 echo "2. make sure you have trans.dat in your intf/*"
 echo "3. ddphase_disp is measured in meter"
 echo "4. Run this after p2p_S1_TOPS.csh"
 echo ""
 exit 1
endif

set PWD = `pwd`
set ref = `echo $1`
set coh = `echo $2`
set Swath = `echo $ref | awk -F_ '{print $4}'`


echo ""
echo "Start BOI processing..."
echo "Processing subswath:" $Swath
echo "Threshold coherence:" $coh


###############################
# Prepare the necessary files #
# 1. ddphase                  #
# 2. spec_div_output          # 
###############################
cp raw/ddphase $Swath/intf/*/
cp raw/spec_div_output $Swath/intf/*/

cd $Swath/intf/*/
set prf = `grep PRF $ref.PRM | awk '{print $3}'`
set height = `grep SC_height $ref.PRM | head -1 | awk '{print $3}'`
set radius = `grep earth_radius $ref.PRM | head -1 | awk '{print $3}'`
set SC_vel = `grep SC_vel $ref.PRM | head -1| awk '{print $3}'`
set SepOverPRF = `grep spectral_spectrationXdta spec_div_output | awk '{print $3}'`
set Sep = `echo $SepOverPRF $prf | awk '{print $1*$2}'`
echo Frequency separation: $Sep
echo PRF: $prf

set pix_size = `echo $prf $height $radius $SC_vel | awk '{printf("%.6f",$4/($2+$3)*$3/$1)}'`
echo Pixel size: $pix_size

cat ddphase | awk '{print $1,$2,$3*(prf/(2*3.1415926*Sep)),$4}' prf="$prf" Sep="$Sep" > ddphase_pix
cat ddphase_pix | awk '{print $1,$2,$3*pix_size,$4}' pix_size="$pix_size" > ddphase_disp


cat ddphase | awk '{if ($4>coh) {print $1,$2,$3}}' coh="$coh" > ddphtmp
cat ddphase_pix | awk '{if ($4>coh) {print $1,$2,$3}}' coh="$coh" > ddpixtmp
cat ddphase_disp | awk '{if ($4>coh) {print $1,$2,$3}}' coh="$coh" > dddisptmp

###########
# ddphase #
###########
echo "Processing ddphase"
echo "Project from ra to ll and Convert to grd"
proj_ra2ll_ascii.csh trans.dat ddphtmp ddphase_ll.dat
set W = `cat ddphase_ll.dat | awk '{print $1}' | awk 'BEGIN {min = 180} {if ($1+0 < min+0) min=$1} END {print min}'`
set E = `cat ddphase_ll.dat | awk '{print $1}' | awk 'BEGIN {max = -180} {if ($1+0 > max+0) max=$1} END {print max}'`
set S = `cat ddphase_ll.dat | awk '{print $2}' | awk 'BEGIN {min = 90} {if ($1+0 < min+0) min=$1} END {print min}'`
set N = `cat ddphase_ll.dat | awk '{print $2}' | awk 'BEGIN {max = -90} {if ($1+0 > max+0) max=$1} END {print max}'`

set inc_x1 = `cat ddphase_ll.dat | awk 'NR==1 {print $1}'`
set inc_x2 = `cat ddphase_ll.dat | awk 'NR==2 {print $1}'`
set inc_x = `echo $inc_x2 - $inc_x1 | bc -l`

set inc_y1 = `cat ddphase_ll.dat | awk 'NR==1 {print $2}'`
set inc_y2 = `cat ddphase_ll.dat | awk 'NR==2 {print $2}'`
set inc_y = `echo $inc_y2 - $inc_y1 | bc -l`

#gmt xyz2grd ddphase_ll.dat -R$W/$E/$S/$N -I0.001/0.001 -Gddphase_ll.grd -V
gmt xyz2grd ddphase_ll.dat -R$W/$E/$S/$N -I$inc_x/$inc_y -Gddphase_ll.grd -V

set LowB = `gmt grdinfo -C ddphase_ll.grd | awk '{print $6}'`
set UpB = `gmt grdinfo -C ddphase_ll.grd | awk '{print $7}'`
gmt makecpt -Crainbow -Z -T$LowB/$UpB/0.1 > ddphase.cpt
gmt psbasemap -R$W/$E/$S/$N -JM16c -Ba1f1 -BWSen -K > ddphase_ll.ps
gmt grdimage ddphase_ll.grd -R -J -Cddphase.cpt -O -K -P -Q -V >> ddphase_ll.ps
gmt psscale -R -J -DJTC+w5i/0.2i+h+e -Cddphase.cpt -O -Bxaf+l"Phase misalignment" >> ddphase_ll.ps
gmt psconvert ddphase_ll.ps -E300 -Tg -A 

###############
# ddphase_pix #
###############
proj_ra2ll_ascii.csh trans.dat ddpixtmp ddphase_pix_ll.dat
#gmt xyz2grd ddphase_pix_ll.dat -R$W/$E/$S/$N -I0.001/0.001 -Gddphase_pix_ll.grd -V
gmt xyz2grd ddphase_pix_ll.dat -R$W/$E/$S/$N -I$inc_x/$inc_y -Gddphase_pix_ll.grd -V

set LowB = `gmt grdinfo -C ddphase_pix_ll.grd | awk '{print $6}'`
set UpB = `gmt grdinfo -C ddphase_pix_ll.grd | awk '{print $7}'`
gmt makecpt -Crainbow -Z -T$LowB/$UpB/0.01 > ddphase_pix.cpt
gmt psbasemap -R$W/$E/$S/$N -JM16c -Ba1f1 -BWSen -K > ddphase_pix_ll.ps
gmt grdimage ddphase_pix_ll.grd -JM16c -Cddphase_pix.cpt -O -K -P -Q -V >> ddphase_pix_ll.ps
gmt psscale -R -J -DJTC+w5i/0.2i+h+e -Cddphase_pix.cpt -O -Bxaf+l"Pixel misalignment" >> ddphase_pix_ll.ps
gmt psconvert ddphase_pix_ll.ps -E300 -Tg -A


################
# ddphase_disp #
################
proj_ra2ll_ascii.csh trans.dat dddisptmp ddphase_disp_ll.dat
#gmt xyz2grd ddphase_disp_ll.dat -R$W/$E/$S/$N -I0.001/0.001 -Gddphase_disp_ll.grd -V
gmt xyz2grd ddphase_disp_ll.dat -R$W/$E/$S/$N -I$inc_x/$inc_y -Gddphase_disp_ll.grd -V

set LowB = `gmt grdinfo -C ddphase_disp_ll.grd | awk '{print $6}'`
set UpB = `gmt grdinfo -C ddphase_disp_ll.grd | awk '{print $7}'`
gmt makecpt -Crainbow -Z -T$LowB/$UpB/0.1 > ddphase_disp.cpt
gmt psbasemap -R$W/$E/$S/$N -JM16c -Ba1f1 -BWSen -K > ddphase_disp_ll.ps
gmt grdimage ddphase_disp_ll.grd -JM16c -Cddphase_disp.cpt -O -K -P -Q -V >> ddphase_disp_ll.ps
gmt psscale -R -J -DJTC+w5i/0.2i+h+e -Cddphase_disp.cpt -O -Bxaf+l"Azimuthal displacement (m)" >> ddphase_disp_ll.ps
gmt psconvert ddphase_disp_ll.ps -E300 -Tg -A

rm *.ps


