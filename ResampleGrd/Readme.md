#### Resample 2 or more grds to the same region and increments (a.k.a. the same size)
How to use this code:
1. Download this code and put it in the directory along with the to-be-resampled grds
2. Modify the variables in *Resamp.csh*
3. Execute the code `csh Resamp.csh`

##### Resampled grds will have suffix `_resamp.grd`
-----
3 variables need to be modified:
- grddir: The directory you put the grds in
- grd: The names of the grds. 2 or more is fine **(Omit the suffix .grd)** 
- mode (When you have multiple different increments):
  - 1: from fine pixel spacing to coarse pixel spacing 
  - 2: from coarse pixel spacing to fine pxiel spacing 
