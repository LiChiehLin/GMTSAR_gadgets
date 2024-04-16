#!bin/csh 
#################################################################
#								#
#		Earth and Planetary Sciences			#
#	    University of California, Riverside			#
#	   		Li-Chieh Lin				#
#								#
# This is to resample each grd to the same size and increment   #
# for further processing (e.g. 3D decomposition, DPM etc.) 	#
#								#
# The resampled grds are named with suffix _resamp.grd  	#
#								#
# Note that each grd file name should be ended with .grd suffix	#
# and filenames should not contain ".", use whatever but not "."#
# to name your grd files					#
#								#
# Updates: 2023.10.23 						#
#   Iterates if the input grds are not resampled to the same	#
#   nrows and ncols						#
#								#
# Updates: 2024.01.30						#
#   1.Correct mode 1 and mode 2 description. They were opposite	#
#   2.Make more proper clean up and reporting results		#
#   								#
# Updates: 2024.04.16						#
#   1.Fix MacOS compatibilty. MacOS and Linux have different 	#
#     ways of creating empty text files.			#
#   2.Minor fixes for reporting results	nicely			#
#################################################################

# grds to be resampled to the same size and increments
# suffix .grd is not needed
# e.g. set grd = ('los_ll_02020214' 'los_ll_02140228') More than 2 grds is ok!
# mode 1: All align to the maximum increment (from fine to coarse)
# mode 2: All align to the minimum increment (from coarse to fine)
set grddir = '/Users/linlichieh/Documents/LiChieh/Events/20240403Hualien/3Ddisplacement/resamp_test'
set grd = ('ALOS_Asc_LOS_cut' 'Sen_Asc_LOS' 'Sen_Des_LOS' 'swbdLat_N21_N27_Lon_E118_E124_wbd')
set mode = 1

cd $grddir
# Get all increments and boundaries
rm incx_tmp incy_tmp
rm xmin_tmp xmax_tmp
rm ymin_tmp ymax_tmp
touch incx_tmp incy_tmp
touch xmin_tmp xmax_tmp
touch ymin_tmp ymax_tmp
foreach line (`echo $grd`)
  gmt grdinfo $line.grd -C | awk '{print $8}' >> incx_tmp
  gmt grdinfo $line.grd -C | awk '{print $9}' >> incy_tmp
  gmt grdinfo $line.grd -C | awk '{print $2}' >> xmin_tmp
  gmt grdinfo $line.grd -C | awk '{print $3}' >> xmax_tmp
  gmt grdinfo $line.grd -C | awk '{print $4}' >> ymin_tmp
  gmt grdinfo $line.grd -C | awk '{print $5}' >> ymax_tmp
end

# Determine the largest increment to align with
if ($mode == 1) then
  set incx_ref = `cat incx_tmp | sort -n | awk 'NR==1 {print $1}' | awk '{printf "%0.5f", $1}'`
  set incy_ref = `cat incy_tmp | sort -n | awk 'NR==1 {print $1}' | awk '{printf "%0.5f", $1}'`
else if ($mode == 2) then
  set incx_ref = `cat incx_tmp | sort -n -r | awk 'NR==1 {print $1}' | awk '{printf "%0.5f", $1}'`
  set incy_ref = `cat incy_tmp | sort -n -r | awk 'NR==1 {print $1}' | awk '{printf "%0.5f", $1}'`
else 
  echo "Wrong mode input! Should be 1 or 2"
  exit
endif

set xmin_ref = `cat xmin_tmp | sort -n -r | awk 'NR==1 {print $1}'`
set xmax_ref = `cat xmax_tmp | sort -n | awk 'NR==1 {print $1}'`
set ymin_ref = `cat ymin_tmp | sort -n -r | awk 'NR==1 {print $1}'`
set ymax_ref = `cat ymax_tmp | sort -n | awk 'NR==1 {print $1}'`

rm tmp_name tmp_range tmp_inc
rm check_row check_col
touch tmp_name tmp_range tmp_inc
touch check_row check_col
foreach GRD (`echo $grd`)
# Resample to the same increment
  gmt grdsample $GRD.grd -R$xmin_ref/$xmax_ref/$ymin_ref/$ymax_ref -I$incx_ref/$incy_ref -G${GRD}_resamp.grd -V

# Cut to the same region
  gmt grdcut ${GRD}_resamp.grd -R$xmin_ref/$xmax_ref/$ymin_ref/$ymax_ref -G${GRD}_resamp_cut.grd -V

# Rename to _resamp.grd
  rm ${GRD}_resamp.grd
  mv ${GRD}_resamp_cut.grd ${GRD}_resamp.grd
  
# Store grd descriptions
  gmt grdinfo ${GRD}_resamp.grd -C | awk -F"." '{print $1}' >> tmp_name
  gmt grdinfo ${GRD}_resamp.grd -Ir >> tmp_range
  gmt grdinfo ${GRD}_resamp.grd -I >> tmp_inc

  gmt grdinfo ${GRD}_resamp.grd -C | awk '{print $11}' >> check_row
  gmt grdinfo ${GRD}_resamp.grd -C | awk '{print $10}' >> check_col
end

# Show result
echo ""
paste tmp_name tmp_range tmp_inc check_row check_col
echo ""

set rmax = `cat check_row | awk 'BEGIN{a=0}{if ($1>0+a) a=$1} END{print a}'`
set cmax = `cat check_col | awk 'BEGIN{a=0}{if ($1>0+a) a=$1} END{print a}'`

set checkr = `cat check_row | awk '{print $1-rmax}' rmax="$rmax" | awk '{sum+=$1;}END{print sum;}'`
set checkc = `cat check_col | awk '{print $1-cmax}' cmax="$cmax" | awk '{sum+=$1;}END{print sum;}'`

# Check row and column length the same or not
# If not loop again to resample to the same nrow and ncol
# If yes, done

if ($checkr == 0 && $checkc == 0) then
  echo ""
  echo "Resampling completed!"
  echo 

  # Clean up
  rm incx_tmp incy_tmp
  rm xmin_tmp xmax_tmp ymin_tmp ymax_tmp
  rm tmp_name tmp_range tmp_inc
  rm check_row check_col
  rm gmt.history
else

  @ i = 0
  while ($checkr != 0 || $checkc != 0)
    @ i += 1
    # Clean up even if there is no such file
    rm incx_tmp2 incy_tmp2
    rm xmin_tmp2 xmax_tmp2
    rm ymin_tmp2 ymax_tmp2
    rm tmp_name2
    rm tmp_range2
    rm tmp_inc2
    touch incx_tmp2
    touch incy_tmp2
    touch xmin_tmp2
    touch xmax_tmp2
    touch ymin_tmp2
    touch ymax_tmp2
    touch tmp_name2
    touch tmp_range2
    touch tmp_inc2
    foreach line (`cat tmp_name`)
      gmt grdinfo $line.grd -C | awk '{print $8}' >> incx_tmp2
      gmt grdinfo $line.grd -C | awk '{print $9}' >> incy_tmp2
      gmt grdinfo $line.grd -C | awk '{print $2}' >> xmin_tmp2
      gmt grdinfo $line.grd -C | awk '{print $3}' >> xmax_tmp2
      gmt grdinfo $line.grd -C | awk '{print $4}' >> ymin_tmp2
      gmt grdinfo $line.grd -C | awk '{print $5}' >> ymax_tmp2
    end
    set xmin_ref = `cat xmin_tmp2 | sort -n -r | awk 'NR==1 {print $1}'`
    set xmax_ref = `cat xmax_tmp2 | sort -n | awk 'NR==1 {print $1}'`
    set ymin_ref = `cat ymin_tmp2 | sort -n -r | awk 'NR==1 {print $1}'`
    set ymax_ref = `cat ymax_tmp2 | sort -n | awk 'NR==1 {print $1}'`
  
    rm check_row2
    rm check_col2
    touch check_row2
    touch check_col2
    foreach GRD (`cat tmp_name`)
      # Resample to the same increment
      gmt grdsample $GRD.grd -R$xmin_ref/$xmax_ref/$ymin_ref/$ymax_ref -I$incx_ref/$incy_ref -G${GRD}_resamp.grd -V
  
      # Cut to the same region
      gmt grdcut ${GRD}_resamp.grd -R$xmin_ref/$xmax_ref/$ymin_ref/$ymax_ref -G${GRD}_resamp_cut.grd -V
  
      # Rename to _resamp.grd
      rm ${GRD}.grd
      rm ${GRD}_resamp.grd
      mv ${GRD}_resamp_cut.grd ${GRD}.grd
  
      # Store grd descriptions
      gmt grdinfo ${GRD}.grd -C | awk -F"." '{print $1}' >> tmp_name2
      gmt grdinfo ${GRD}.grd -Ir >> tmp_range2
      gmt grdinfo ${GRD}.grd -I >> tmp_inc2
  
      gmt grdinfo ${GRD}.grd -C | awk '{print $11}' >> check_row2
      gmt grdinfo ${GRD}.grd -C | awk '{print $10}' >> check_col2
    end
  
    # Recalculate checkr and checkc
    set rmax = `cat check_row2 | awk 'BEGIN{a=0}{if ($1>0+a) a=$1} END{print a}'`
    set cmax = `cat check_col2 | awk 'BEGIN{a=0}{if ($1>0+a) a=$1} END{print a}'`
  
    set checkr = `cat check_row2 | awk '{print $1-rmax}' rmax="$rmax" | awk '{sum+=$1;}END{print sum;}'`
    set checkc = `cat check_col2 | awk '{print $1-cmax}' cmax="$cmax" | awk '{sum+=$1;}END{print sum;}'`
  
    if ($i == 5) then
      echo "Done too many times and still not converge"
      echo "Please find other ways to do it!"
      echo "---EXIT---"
      break
    endif
  end
  
  # Show result
  echo ""
  paste tmp_name2 tmp_range2 tmp_inc2 check_row2 check_col2
  echo ""

  # Clean up
  rm incx_tmp incy_tmp
  rm xmin_tmp xmax_tmp ymin_tmp ymax_tmp
  rm tmp_name tmp_range tmp_inc
  rm check_row check_col
  rm check_row2 check_col2
  rm incx_tmp2 incy_tmp2
  rm xmin_tmp2 xmax_tmp2 ymin_tmp2 ymax_tmp2
  rm tmp_inc2 tmp_name2 tmp_range2
  rm gmt.history
endif


