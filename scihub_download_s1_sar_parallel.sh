#!/bin/bash
# Download data as shown in the search_results. 
# Feb. 14, 2018. by Kathryn Materna
#
# Last updated Dec 2020
# By YL
# Incorporate parallel


if [[ "$#" -eq 0 ]]; then
  echo ""
  echo "This script downloads the results of data queries"
  echo "Usage: ./scihub_download_s1_sar_parallel.sh -options"
  echo "Example: ./scihub_download_s1_sar.sh -i search_results.txt"
  echo "Current parallel version only works for single input file."
  echo ""
  exit 1
fi

# Remove command files
rm -f download_s1a_parallel.cmd

# Read the search results. It could be multiple calls of the -i flag. 
while getopts i: opt; do
    case $opt in
        i) multi+=("$OPTARG");;
    esac
done
shift $((OPTIND -1))

#echo "The whole list of values is '${multi[@]}'"  # a debugging line. 


# Defining parameters
id_results=uuid_file.txt

#Where will the data live? 
mkdir -p DATA


# WILL FIX THIS TO CAT ANY DATA IN ANY FILE
# THIS WILL BE IN A LOOP OVER POTENTIALLY MULTIPLE $RAW_RESULTS files
# Processing the raw results to get unique id names
rm $id_results
for val in "${multi[@]}"; do
    grep -E 'uuid|<title>S1' $val >> $id_results
done

# the -i '' is because of mac computers. Might need to delete the '' on a linux machine. 
sed -i "" 's/<str name=\"uuid\">//g' $id_results
sed -i "" 's/<title>//g' $id_results
sed -i "" 's/<\/title>//g' $id_results
sed -i "" 's/<\/str>//g' $id_results


counter=0
while read p; do
  if [ $counter = 0 ]; then
  	title=$p
  	counter=1
  	continue
  else
    uuid=$p
  fi
  echo $title
  echo $uuid
  
  # DATA (full thing- will take a long time)!
  # Skip downloading data if it already exists!
  if [ -d  DATA/"$title".SAFE ]; then
    echo "File exists. Skip downloading process."
  elif [ -f  DATA/"$title".SAFE.zip ]; then
    echo "Zip File exists. Skip downloading process."
  else
    # make command list for all jobs
    echo "wget -c --no-check-certificate --http-user=yuexinli@berkeley.edu  --http-password=Give_me_5  -O DATA/"$title".zip "https://datapool.asf.alaska.edu/SLC/SA/$title.zip"" >> download_s1a_parallel.cmd 

  # Takes a few hours for each SAFE.zip.
  # Each one can be unzipped with unzip.
  #unzip DATA/$title.zip
  #rm DATA/$title.zip
  
  fi

  counter=0

done < $id_results  

# Currently ncores is hard-coded to be 4
  t1=`date`
  parallel --jobs 4 < download_s1a_parallel.cmd
  t2=`date`
  #echo $t1,$t2
  echo "Downloading job started on $t1 and finished on $t2." | mail -s "Sentinel Download Finished" yuexinli@berkeley.edu


