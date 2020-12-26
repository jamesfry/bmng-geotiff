#!/bin/bash

OUTPUT_DIR=${OUTPUT_DIR:-data}

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
for file in ${OUTPUT_DIR}/*.png; do
    if [[ $file =~ $regex ]]; then
        extent="${BASH_REMATCH[1]}"
        corners=$(ullr $extent)
        output=$(basename ${file} .png).tif
        echo "Converting ${file} into tiled EPSG:4326 GeoTIFF geo-referenced at ${corners}"...
        if [ -f "data/${output}" ]; then
            echo "...skipped as ${output} already exists."
            continue
        fi
        gdal_translate -of GTiff -co COMPRESS=DEFLATE -co TILED=yes -a_srs EPSG:4326 -a_ullr ${corners} ${file} ${OUTPUT_DIR}/${ouput}
    fi
done

gdalbuildvrt -resolution highest bmng_4326.vrt ${OUTPUT_DIR}/*.tif

gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3857 bmng_4326.vrt bmng_3857.vrt

gdal_translate -of GTiff  \
    -co TILED=YES \
    -co COMPRESS=JPEG \
    -co PHOTOMETRIC=YCBCR \
    -co JPEG_QUALITY=95 \
    -co NUM_THREADS=ALL_CPUS \
    --config GDAL_CACHEMAX 4096 \
    bmng_3857.vrt \
    bmng_3857.tif

gdaladdo \
    --config COMPRESS_OVERVIEW JPEG \
    --config PHOTOMETRIC_OVERVIEW YCBCR \
    --config INTERLEAVE_OVERVIEW PIXEL \
    --config GDAL_CACHEMAX 4096 \
    --config GDAL_NUM_THREADS ALL_CPUS \
    -r average \
    bmng_3857.tif