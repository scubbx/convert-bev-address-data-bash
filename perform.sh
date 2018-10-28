#!/bin/bash

# The complete dataset has to contain 2384440 lines (as many as there are in ADRESSE.csv). Compare with "cat ADRESSE.csv | wc -l" and "./perform.sh | wc -l".

# we have to remove the header, otherwise we will encounter problems with sorting later on. (tail -n +2 $FILE)
# For reference, the headers of the files are:
# ADRESSE:
# ADRCD GKZ OKZ PLZ SKZ ZAEHLSPRENGEL HAUSNRTEXT HAUSNRZAHL1 HAUSNRBUCHSTABE1 HAUSNRVERBINDUNG1 HAUSNRZAHL2 HAUSNRBUCHSTABE2 HAUSNRBEREICH GNRADRESSE HOFNAME RW   HW   EPSG QUELLADRESSE BESTIMMUNGSART
# 1.1   1.2 1.3 1.4 1.5 1.6           1.7        1.8         1.9              1.10              1.11        1.12             1.13          1.14       1.15    1.16 1.17 1.18 1.19         1.20  
#
# GEMEINDE:
# GKZ GEMEINDENAME
# 2.1 2.2
#
# ORTSCHAFT:
# GKZ OKZ ORTSNAME
# 2.1 2.2 2.3

# First we join ADRESSE with GEMEINDE. Both are input files are stripped of the header. Both files are already sorted, so no need to do that.
# For whatever reason there seems to be a CR at the end of each line. This is removed with the "tr" command.
join -t ";" -1 2 -2 1 -o 1.1   1.2 1.3 1.15    1.16 1.17 1.18 2.2          1.4 1.7        1.8          1.9           1.10        1.11        1.12          1.13          <(tail -n +2 ADRESSE.csv) <(tail -n +2 GEMEINDE.csv) | tr -d '\r' |
# Output is:             ADRCD GKZ OKZ Hofname RW   HW   EPSG GEMEINDENAME PLZ HAUSNRTEXT HAUSNRZAHL1  HAUSNRBUCHST1 HAUSNRVERB1 HAUSNRZAHL2 HAUSNRBUCHST2 HAUSNRBEREICH 
# new pipe input:        1.1   1.2 1.3 1.4     1.5  1.6  1.7  1.8          1.9 1.10       1.11         1.12          1.13        1.14        1.15          1.16

# The previous output is joined with ORTSNAME. Since the joining field is now OKZ, we have to sort the previous output as well as the new file ORTSCHAFT by the field OKZ. Also the header is removed from the ORTSCHAFT file.
join -t ";" -1 3 -2 2 -o 1.1   1.2 1.3 1.8          1.4     1.5 1.6 1.7  1.9 1.10       1.11        1.12          1.13        1.14        1.15          1.16          2.3     <(sort -t ";" -k 3 -) <(tail -n +2 ORTSCHAFT.csv | sort -t ";" -k 2 -) | tr -d '\r' > joined.csv
# Output is:             ADRCD GKZ OKZ GEMEINDENAME Hofname RW  HW  EPSG PLZ HAUSNRTEXT HAUSNRZAHL1 HAUSNRBUCHST1 HAUSNRVERB1 HAUSNRZAHL2 HAUSNRBUCHST2 HAUSNRBEREICH ORTSNAME
# new pip input:         1.1   1.2 1.3 1.4          1.5     1.6 1.7 1.8  1.9 1.10       1.11        1.12          1.13        1.14        1.15          1.16          1.17

# Split by EPSG
cat joined.csv | grep ";31254;" > 31254.csv
cat joined.csv | grep ";31255;" > 31255.csv
cat joined.csv | grep ";31256;" > 31256.csv

# Transform to EPGS:4326
paste -d ";" 31254.csv <(cat 31254.csv | cut -d ";" -f 6,7 | tr ";" " " | gdaltransform -s_srs EPSG:31254 -t_srs EPSG:4326 -output_xy | tr " " ";") > 4326_1.csv
paste -d ";" 31255.csv <(cat 31255.csv | cut -d ";" -f 6,7 | tr ";" " " | gdaltransform -s_srs EPSG:31255 -t_srs EPSG:4326 -output_xy | tr " " ";") > 4326_2.csv
paste -d ";" 31256.csv <(cat 31256.csv | cut -d ";" -f 6,7 | tr ";" " " | gdaltransform -s_srs EPSG:31256 -t_srs EPSG:4326 -output_xy | tr " " ";") > 4326_3.csv

# Merge into one single file
cat 4326_1.csv 4326_2.csv 4326_3.csv |

# And add the header
cat - | (echo "ADRCD;GKZ;OKZ;GEMEINDENAME;HOFNAME;RW;HW;EPSG;PLZ;HAUSNRTEXT;HAUSNRZAHL1;HAUSNRBUCHST1;HAUSNRVERB1;HAUSNRZAHL2;HAUSNRBUCHST2;HAUSNRBEREICH;ORTSNAME;LON;LAT" && cat -) > 4326.csv 

# Remove temporary files
rm -f 31254.csv 31255.csv 31256.csv 4326_1.csv 4326_2.csv 4326_3.csv

