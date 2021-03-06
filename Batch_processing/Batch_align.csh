#!bin/csh

##config: put absolute path and the specific configuration text file
##Example:
##set config = /Document/config.s1a.txt
set config = /Document/ConfigFolder/config.s1a.txt
##Raw: Same as MakeFolder.csh
set Raw = RawFolder.dat
##subswath: Specify the subswath you want to work on
set subswath = 1


##Start program
set tmp = `cat $Raw | wc -l`
set Row = `echo "$tmp-1" | bc -l`
set PWD = `pwd`

################################################
# Align images with align_tops_esd.csh mode 2  #
################################################
foreach Num (`seq 1 1 $Row`)
set Ref = `cat $Raw | awk 'NR==Num {print $0}' Num="$Num" | cut -c 5-8`
set Ali = `cat $Raw | awk 'NR==Num+1 {print $0}' Num="$Num" | cut -c 5-8`
set Dir = `echo ${Ref}_${Ali}`
echo $Dir

cd $Dir/raw
#### Get all the prefix and file names
set ref_prefix = `ls *iw${subswath}-slc-vv-*${Ref}* | awk -F. 'NR==1 {print $1}'`
set ali_prefix = `ls *iw${subswath}-slc-vv-*${Ali}* | awk -F. 'NR==1 {print $1}'`
ls *.EOF > tmp
set ref_orbit = `sort -n -k 2 -t V tmp | awk 'NR==1 {print $0}'`
set ali_orbit = `sort -n -k 2 -t V tmp | awk 'NR==2 {print $0}'`
echo $ref_orbit
echo $ali_orbit

#### Run align_tops_esd.csh mode 2
align_tops_esd.csh $ref_prefix $ref_orbit $ali_prefix $ali_orbit dem.grd 2

### Arrange p2p_S1_TOPS.csh environment
cd ../
mkdir F${subswath}
cd F${subswath}
mkdir topo
cd topo/
ln -s ../../topo/dem.grd
cd ../
mkdir raw
cd raw/
mv ../../raw/*F${subswath}* .
cd ../
cp $config .
cd $PWD
end

