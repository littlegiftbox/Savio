#!/bin/csh -f
#
# Yuexin Li
# Dec 2020

if ($#argv != 1) then
	echo ""
	echo "Preprocess and align tops image stacks"
	echo "Make sure to run this after"
	echo "1) running s1a_autoprep.csh"
	echo "2) putting supermaster at first line in data.in"
	echo "3) dem.grd properly linked in raw folder"
	echo "Please specify the subswath, e.g. F1"
	echo ""
	exit 1
endif

cd $1/raw
preproc_batch_tops.csh data.in dem.grd 2 > run.log
cd ../.. 
