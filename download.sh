#!/bin/bash

# Downloads BMNG PNGs from NASA servers for specified month (default is August - minimal snow cover)

OUTPUT_DIR=${OUTPUT_DIR:-./data/source}
mkdir -p ${OUTPUT_DIR}/

MONTHS=${MONTHS:-"01 02 03 04 05 06 07 08 09 10 11 12"}

# From https://visibleearth.nasa.gov/collection/1484/blue-marble?page=1
# Topography and Bathymetry - different months have different IDs:

# January
BASE_URL_01=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73580/

# February
BASE_URL_02=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73605/

# March
BASE_URL_03=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73630/

# April
BASE_URL_04=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73655/

# May
BASE_URL_05=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73701/

# June
BASE_URL_06=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73726/

# July
BASE_URL_07=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/

# August
BASE_URL_08=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73776/

# September
BASE_URL_09=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73801/

# October
BASE_URL_10=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73826/

# November
BASE_URL_11=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73884/

# December
BASE_URL_12=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/


for MONTH in ${MONTHS}; do
    BASE_URL="$BASE_URL_$MONTH"
    BASE_FILE=world.topo.bathy.2004${MONTH}.3x21600x21600
    for i in A B C D; do
        for j in 1 2; do
            FILE="${BASE_FILE}.${i}${j}.png"
            curl -L -C - -o "${OUTPUT_DIR}/${FILE}" "${BASE_URL}/${FILE}"
        done
    done
done
