#!bin/csh

# RawFolder.dat is from
# ls -d year* > RawFolder.dat
#Example: ls -d 2018* > RawFolder.dat
set Raw = RawFolder.dat
## topodir: put absolute path
set topodir = "/Document/TopographyFolder"


##Start program
set tmp = `cat $Raw | wc -l`
set Row = `echo "$tmp-1" | bc -l` 
set PWD = `pwd`

foreach Num (`seq 1 1 $Row`)
set Reflong = `cat $Raw | awk 'NR==Num {print $0}' Num="$Num"`
set Alilong = `cat $Raw | awk 'NR==Num+1 {print $0}' Num="$Num"`
set RefImg = `ls $Reflong | awk 'NR==1 {print $1}'`
set AliImg = `ls $Alilong | awk 'NR==1 {print $1}'`
set Ref = `echo $Reflong | cut -c 5-8`
set Ali = `echo $Alilong | cut -c 5-8`

set Dir = `echo ${Ref}_${Ali}`

mkdir $Dir
cd $Dir
mkdir topo
cd topo
#### Link topo
ln -s $topodir/dem.grd .
cd ../
mkdir raw
cd raw
ln -s ../topo/dem.grd .
#### Link Reference xml and tiff and orbit
ln -s ../../$Reflong/$RefImg/annotation/*.xml .
ln -s ../../$Reflong/$RefImg/measurement/*.tiff .
cp ../../$Reflong/*.EOF .
#### Link Aligned xml and tiff and orbit
ln -s ../../$Alilong/$AliImg/annotation/*.xml .
ln -s ../../$Alilong/$AliImg/measurement/*.tiff .
cp ../../$Alilong/*.EOF .

cd $PWD
end
