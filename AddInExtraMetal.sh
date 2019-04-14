#!/bin/bash

post="_Extra-05.tif"
while read filename
do
  cp "data/images/$filename" "tmp/images/${filename/.tif/$post}"
  cp "data/masks/$filename" "tmp/masks/${filename/.tif/$post}"
done < data/MetalImagesToDuplicate.txt

# post="_Extra-01.tif"
# for filename in tmp/*.tif; do
#   echo "$filename" "${filename/.tif/$post}"
# done

# for file in $(ls data/images/ | grep Extra)
# do
#     echo $file
# done
