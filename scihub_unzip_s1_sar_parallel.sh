#!/bin/csh
# Unzip the downloaded data
# Dec 2020
# YL

if ($#argv != 2) then
	echo ""
	echo "Usage: scihub_unzip_s1_sar_parallel.sh data.list Ncores"
	echo ""
	exit
endif

rm -f unzip_s1a_parallel.cmd

foreach file (`awk '{print $0}' $1`)
	echo "unzip $file" >> unzip_s1a_parallel.cmd
end

parallel --jobs $2 < unzip_s1a_parallel.cmd
