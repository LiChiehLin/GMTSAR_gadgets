#!bin/csh 
#################################################################
#								                                                #
# This is to resample each grd to the same region and increment #
# for further processing (e.g. 3D decomposition, DPM etc.) 	    #
#								                                                #
# The resampled grds are named with suffix _resamp.grd  	      #
#################################################################

# grds to be resampled to the same region and increments
# suffix .grd is not needed
# e.g. set grd = ('los_ll_02020214' 'los_ll_02140228')
set grd = ('los_ll_02020214' 'los_ll_02140228')

# Get all increments and boundaries
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
set incx_ref = `cat incx_tmp | sort -n -r | awk 'NR==1 {print $1}'`
set incy_ref = `cat incy_tmp | sort -n -r | awk 'NR==1 {print $1}'`
set xmin_ref = `cat xmin_tmp | sort -n -r | awk 'NR==1 {print $1}'`
set xmax_ref = `cat xmax_tmp | sort -n | awk 'NR==1 {print $1}'`
set ymin_ref = `cat ymin_tmp | sort -n -r | awk 'NR==1 {print $1}'`
set ymax_ref = `cat ymax_tmp | sort -n | awk 'NR==1 {print $1}'`


foreach GRD (`echo $grd`)
# Resample to the same increment
  gmt grdsample $GRD.grd -I$incx_ref/$incy_ref -G${GRD}_resamp.grd -V

# Cut to the same region
  gmt grdcut ${GRD}_resamp.grd -R$xmin_ref/$xmax_ref/$ymin_ref/$ymax_ref -G${GRD}_resamp_cut.grd -V

# Rename to _resamp.grd
  rm ${GRD}_resamp.grd
  mv ${GRD}_resamp_cut.grd ${GRD}_resamp.grd
end

# Show result
gmt grdinfo *resamp.grd -C | awk '{print $1}'
gmt grdinfo *resamp.grd -Ir 
gmt grdinfo *resamp.grd -I

# Clean up
rm incx_tmp incy_tmp
rm xmin_tmp xmax_tmp ymin_tmp ymax_tmp
rm gmt.history
