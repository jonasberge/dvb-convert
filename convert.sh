#!/bin/bash

PROJX_DIR="project-x"
PROJX_JAR="$PROJX_DIR/ProjectX.jar"

JAVA="java"
JAVA_OPTS="-Djava.awt.headless=true"
PROJX="$JAVA $JAVA_OPTS -jar $PROJX_JAR"

IN_DIR=${IN_DIR:-"input"}
OUT_DIR=${OUTDIR_DIR:-"output"}
DVD_DIR="$OUT_DIR/dvd"
ISO_DIR="$OUT_DIR/iso"

VID_EXT="VID"
AUD_EXT="AUD"

function clear {
    rm -rf $OUT_DIR
    mkdir $OUT_DIR $DVD_DIR $ISO_DIR
}

function filter_convert_out_file {
    grep -o "new File: '\?[^']*'\?" \
        | sed -e "s/new File: '\([^']*\)'/\1/g" \
        | sed -e "s/new File: \([^']*\)/\1/g"
}

function convert {
    $PROJX -out $OUT_DIR $@ \
        | tee /dev/tty \
        | filter_convert_out_file
}

clear
set -x

for FILE_VID in $IN_DIR/*.$VID_EXT; do
    DIR=$(dirname $FILE_VID)
    BASE=$(basename $FILE_VID $VID_EXT)
    BASE="${BASE%.*}"
    FILE_AUD="$DIR/$BASE.$AUD_EXT"

    if [[ -f "$FILE_AUD" ]]; then
        RES_FILES=$(convert $FILE_VID $FILE_AUD)
        RES_FILES=(${RES_FILES[@]})

        RES_VID="${RES_FILES[0]}"
        RES_AUD="${RES_FILES[1]}"

        # combine audio and video
        RES_PAL="$OUT_DIR/${BASE}.pal.mpg"
        ffmpeg -i "$RES_VID" -i "$RES_AUD" -shortest -target pal-dvd "$RES_PAL"
        
        # create dvd directory structure
        DVDAUTH_DIR="$DVD_DIR/$BASE"
        mkdir "$DVDAUTH_DIR"
        dvdauthor -o "$DVDAUTH_DIR" -t "$RES_PAL"
        dvdauthor -o "$DVDAUTH_DIR" -T

        # create dvd iso
        mkisofs -dvd-video -o "$ISO_DIR/$BASE.iso" "$DVDAUTH_DIR"
    fi
done
