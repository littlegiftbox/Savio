#!/bin/bash
# Download data as shown in the search_results. 
# Feb. 14, 2018.

if [[ "$#" -eq 0 ]]; then
  echo ""
  echo "This script downloads the results of data queries"
  echo "Usage: ./scihub_download_s1_sar.sh -options"
  echo "Example: ./scihub_download_s1_sar.sh -i search_results1.txt -i search_results2.txt"
  echo "Please provide one or more input files."
  echo ""
  exit 1
fi


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
#mkdir -p MANIFEST


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
    wget -c --no-check-certificate --http-user=yuexinli@berkeley.edu  --http-password=Give_me_5  -O DATA/"$title".zip "https://datapool.asf.alaska.edu/SLC/SA/$title.zip"

  # Takes a few hours for each SAFE.zip.
  # Each one can be unzipped with unzip.
  unzip DATA/$title.zip
  rm DATA/$title.zip
  
  fi

  counter=0
  
done <$id_results
