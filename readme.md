# Conver BEV Adresses with BASH

Since the original script in Python I was wondering if there is no better way to convert the BEV address data to an easily usable format in a more perfoment manner.

With this code, only BASH (and GDAL for coordinate transformation) is used to perform table joins on BEV address data.

This version is surprisingly performant, even though I was not able to stick to my original restrictions. These were not to use temporary files, but pipe all data. There happened some mix up of data when not using temporary files, so in the end, I did use those.

To execute the script you need to have

  * a BASH shell
  * gdal command line tools installed and available in the PATH (namely "gdaltransform")
  * BEV Adress data: ADRESSE.csv, GEMEINDE.csv and ORTSCHAFT.csv

The script is called with ./perform.sh and generates an output file named 4326.csv that contains BEV Address data in EPSG:4326 .
