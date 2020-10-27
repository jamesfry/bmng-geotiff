#!/bin/bash

# Downloads BMNG PNGs from NASA servers for specified month (default is August - minimal snow cover)

OUTPUT_DIR=${OUTPUT_DIR:-data}
mkdir -p ${OUTPUT_DIR}/

MONTH=${MONTH:-08}

# From https://visibleearth.nasa.gov/collection/1484/blue-marble?page=1
# August, with Topography and Bathymetry
BASE_URL=https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73776
BASE_FILE=world.topo.bathy.2004${MONTH}.3x21600x21600

for i in A B C D; do
    for j in 1 2; do
        FILE="${BASE_FILE}.${i}${j}.png"
        curl -L -C - -o "${OUTPUT_DIR}/${FILE}" "${BASE_URL}/${FILE}"
    done
done
