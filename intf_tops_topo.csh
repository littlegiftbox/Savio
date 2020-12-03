#!/bin/csh -f
#
# Generate topo_ra files before intf_tops_parallel.csh
# In batch_tops_config, stage will always be set to 2
# YL 
# Dec 2020 

  if ($#argv != 1) then
    echo ""
    echo "Usage: intf_tops_topo.csh batch_tops.config"
    echo "dem.grd required in /topo"
    echo "supermaster required in batch_tops.config"
    echo ""
    exit 1
  endif

  if (! -f $1) then
    echo "no config file:" $1
    exit
  endif
#
# read parameters from config file
#
  set stage = `grep proc_stage $2 | awk '{print $3}'`
  set master = `grep master_image $2 | awk '{print $3}'`
  set topo_phase = `grep topo_phase $2 | awk '{print $3}'`
  set shift_topo = `grep shift_topo $2 | awk '{print $3}'`
  set region_cut = `grep region_cut $2 | awk '{print $3}'`
  set switch_land = `grep switch_land $2 | awk '{print $3}'`

##################################
# 1 - start from make topo_ra  #
##################################

#
# clean up
#
  cleanup.csh topo
#
# make topo_ra
#
  if ($topo_phase == 1) then
    echo " "
    echo "DEM2TOPOPHASE.CSH - START"
    echo "USER SHOULD PROVIDE DEM FILE"
    cd topo
    cp ../raw/$master.PRM ./master.PRM
    ln -s ../raw/$master.LED .
    if (-f dem.grd) then
      if ("x$region_cut" == "x") then
        dem2topo_ra.csh master.PRM dem.grd
      else
        cut_slc master.PRM junk $region_cut 1
        mv junk.PRM master.PRM
        dem2topo_ra.csh master.PRM dem.grd
      endif
    else
      echo "no DEM file found: " dem.grd
      exit 1
    endif
    cd ..
    echo "DEM2TOPOPHASE.CSH - END"

#
#  shift topo_ra
#  
    if ($shift_topo == 1) then
      echo " "
      echo "OFFSET_TOPO - START"
      cd topo
      ln -s ../raw/$master.SLC .
      slc2amp.csh master.PRM 4 amp-$master.grd
      offset_topo amp-$master.grd topo_ra.grd 0 0 7 topo_shift.grd
      cd ..
      echo  "OFFSET_TOPO - END"
    else if ($shift_topo == 0) then
      echo "NO TOPOPHASE SHIFT "
    else
      echo "Wrong paramter: shift_topo "$shift_topo
      exit 1
    endif
  else if ($topo_phase == 0) then
    echo "NO TOPOPHASE IS SUBSTRACTED"
  else
    echo "Wrong paramter: topo_phase "$topo_phase
    exit 1
  endif
