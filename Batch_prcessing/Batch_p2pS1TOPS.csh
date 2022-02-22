#!bin/csh

##config: Put the configuration file's full name
set config = config.s1a.txt
##Raw: The same as MakeFolder.csh and Batch_align.csh
set Raw = RawFolder.dat
set tmp = `cat $Raw | wc -l`
set Row = `echo "$tmp-1" | bc -l`
set PWD = `pwd`

##Specify the subswath you want to work on
set subswath = 1
###################
# p2p_S1_TOPS.csh #
###################
foreach Num (`seq 1 1 $Row`)
set Ref = `cat $Raw | awk 'NR==Num {print $0}' Num="$Num" | cut -c 5-8`
set Reflong = `cat $Raw | awk 'NR==Num {print $0}' Num="$Num"`
set Ali = `cat $Raw | awk 'NR==Num+1 {print $0}' Num="$Num" | cut -c 5-8`
set Alilong = `cat $Raw | awk 'NR==Num+1 {print $0}' Num="$Num"`
set Dir = `echo ${Ref}_${Ali}`
echo $Dir

#### Get reference and aligned prefix
cd $Dir/F${subswath}/raw
set ref = `ls *${Reflong}* | awk -F. 'NR==1 {print $1}'`
set ali = `ls *${Alilong}* | awk -F. 'NR==1 {print $1}'`
cd ../

#### p2p_S1_TOPS.csh
p2p_S1_TOPS.csh $ref $ali $config

cd $PWD
end



