#!/bin/bash

SOURCE_DIR=${SOURCE_DIR:-./data/source}
OUTPUT_DIR=${OUTPUT_DIR:-./data/geotiff}
mkdir -p ${OUTPUT_DIR}/

MONTHS=${MONTHS:-"01 02 03 04 05 06 07 08 09 10 11 12"}
function ord() {
    LC_CTYPE=C printf '%d' "'$1"
}

# calculate UL/LR coordinates for BMNG grid (A1..D2)
function ullr() {
    i=${1:0:1}
    j=${1:1:2}
    ulx=$(( -180 + (($(ord $i) - 65) * 90)))
    llx=$(($ulx + 90))
    uly=$((90 + (-90 * ($j - 1))))
    lly=$(($uly - 90))
    echo "$ulx $uly $llx $lly"
}

regex=".*([ABCD][12]).png"
for file in ${SOURCE_DIR}/*.png; do
    if [[ $file =~ $regex ]]; then
        extent="${BASH_REMATCH[1]}"
        corners=$(ullr $extent)
        output=$(basename ${file} .png).tif
        echo "Converting ${file} into tiled EPSG:4326 GeoTIFF geo-referenced at ${corners}"...
        if [ -f "${OUTPUT_DIR}/${output}" ]; then
            echo "...skipped as ${output} already exists."
            continue
        fi
        gdal_translate -of GTiff -co COMPRESS=DEFLATE -co TILED=yes -a_srs EPSG:4326 -a_ullr ${corners} ${file} ${OUTPUT_DIR}/${output}
    fi
done



for MONTH in ${MONTHS}; do
    BASE_URL="BASE_URL_$MONTH"
    BASE_FILE=world.topo.bathy.2004${MONTH}.3x21600x21600

    gdalbuildvrt -resolution highest world.topo.bathy.2004${MONTH}_4326.vrt ${OUTPUT_DIR}/world.topo.bathy.2004${MONTH}.3x21600x21600.*.tif

    gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3857 world.topo.bathy.2004${MONTH}_4326.vrt world.topo.bathy.2004${MONTH}_3857.vrt

    gdal_translate -of GTiff  \
        -co TILED=YES \
        -co COMPRESS=JPEG \
        -co PHOTOMETRIC=YCBCR \
        -co JPEG_QUALITY=95 \
        -co NUM_THREADS=ALL_CPUS \
        --config GDAL_CACHEMAX 4096 \
        world.topo.bathy.2004${MONTH}_3857.vrt \
        world.topo.bathy.2004${MONTH}_3857.tif

    gdaladdo \
        --config COMPRESS_OVERVIEW JPEG \
        --config PHOTOMETRIC_OVERVIEW YCBCR \
        --config INTERLEAVE_OVERVIEW PIXEL \
        --config GDAL_CACHEMAX 4096 \
        --config GDAL_NUM_THREADS ALL_CPUS \
        -r average \
        world.topo.bathy.2004${MONTH}_3857.tif

done
