# GMTSAR-gadgets

Supplementary codes for GMTSAR processing.


###### Batch_processing/
- Detailed explainations are in Batch_processing/Readme.txt. 
- Make computer work at night while you can have a nice sleep and wake up with all the interferograms done. 
  
###### BurstOverlapIntf/
- Burst Overlap Interferometry can be calculated from products from align_tops_esd.csh with mode 2.  
- For this code, you need to finish p2p_S1_TOPS.csh first in order to make this work.  
- "BOI_processing.csh" uses the same naming fashion as MAI_processing.csh.  

###### PasteDEM/
- The dem can be downloaded from https://topex.ucsd.edu/gmtsar/demgen/
- But if the above website goes any malfunctioning, alternatively the dem can be downloaded from https://dwtkns.com/srtm30m/
- However, if download from the above then the dems are cut into small tiles (1 degree).
- You will need to manually paste them to form a big dem file.

###### PixelOffsetTracking/
- make_a_offset.csh will calculate azimuth offset but will not automatically output range offset.  
- "take_r_offset.csh" just extracts range offset from freq_xcorr.dat so it's named "take_r_offset" not "make_r_offset".  


