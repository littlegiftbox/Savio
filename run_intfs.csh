#!/bin/csh

cd $1
#intf_tops_topo.csh batch_tops.config
intf_tops_parallel.csh intf.in batch_tops.config 12
cd ..


