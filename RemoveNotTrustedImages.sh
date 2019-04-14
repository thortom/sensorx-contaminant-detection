#!/bin/bash

while read filename
do
  mv "data/images/$filename" "data/NotTrusted/images/$filename"
  mv "data/masks/$filename" "data/NotTrusted/masks/$filename"
done < data/AdditionalNotTrustedImagesRemoved.txt

while read filename
do
  mv "data/images/$filename" "data/NotTrusted/images/$filename"
  mv "data/masks/$filename" "data/NotTrusted/masks/$filename"
done < data/NoBoneImages.txt
