# SensorX Contaminant Detection
Contaminant detection in X-Ray scanned beef

## Project file descriptions
### ContaminantDetection.ipynb
Contains the main project with U-Net neural network that is trained on three channels from the processed SensorX images.
The three channels selected are "lowImgReg", "highImgReg" and then one "fake" channel with all pixels set to 0.

### saveImages.m
Processes the original SensorX tiff images with the SensorX algorithm and saves a new tiff image with 6 channels that are
["highImg", "lowImg", "plastImg", "alImg", "lowImgReg", "highImgReg"]. This script also has the possibility of labeling
the images with manual intervention.

### Other scripts are experimental stuff
