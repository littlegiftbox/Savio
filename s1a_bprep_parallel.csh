#!/bin/csh -f
#
#Yuexin Li
#

if ($#argv != 2) then
    echo ""
    echo "Script to prepare the data for raw_orig"
    echo "Usage: s1a_bprep.csh DATA Ncores"
    echo "DATA is where all your .SAFE data lives"
    echo ""
    exit 1
endif


rm -rf raw_orig
mkdir raw_orig

#optional
#rm -rf F1 F2 F3
#mkdir F1 F2 F3

set DIR=`pwd`
set datadir=$DIR/$1
set orbdir='/global/scratch/yuexinli/S1_Orbits'
cd raw_orig

foreach file ($datadir/*.SAFE)
    echo $file
    set YMD=`echo $file | awk '{print substr($1,length($1)-54,8)}'`
    echo $YMD
    set new_name="${YMD}_manifest.safe"
    cp $file/manifest.safe .
    mv manifest.safe $new_name
    foreach n(1 2 3)
     set nn = `echo $n | awk '{printf("%d",$0+3)}'`
     set subfile=F$n
     set filename1=`ls $file/annotation/*vv*.xml | sed -n ${n}p | awk '{print $1}'`
     set filename2=`echo $filename1 | awk '{print substr($1,1,length($1)-5)}'`
     set filename3=${filename2}${nn}.xml
     echo $filename3
     if ( -e $filename3 ) then
         echo "cp $file/annotation/*00$nn.xml ." < s1a_bprep.cmd
         echo "cp $file/measurement/*00$nn.tiff ." < s1a_bprep.cmd
     else
        echo "cp $file/annotation/*00$n.xml ." < s1a_bprep.cmd
        echo "cp $file/measurement/*00$n.tiff . " < s1a_bprep.cmd
     endif
    end
end

cp $orbdir/*.EOF .
cp $orbdir/s1a-aux-cal.xml .

parallel --jobs $2 < s1a_bprep.cmd

echo "Well done! raw_orig is ready for you. "

cd ..
