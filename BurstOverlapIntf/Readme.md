### Calculate the displacement within the burst overlapping area
> With help from Xu, Xiaohua (Eric)

----
How to use this code:  
1. Execute `align_tops_esd.csh` with mode 2
2. Execute `p2p_S1_TOPS.csh`
3. Execute `BOI_processing.csh` back in `raw/` directory (the one when performing alignment)

----
4 variables to be put in:
1. Reference prefix 
2. coherence threshold (pixels below it will be omitted)
3. increment (Set 0.001 and 0.001 for both should be fine)

This code might not perform satisfactorily
