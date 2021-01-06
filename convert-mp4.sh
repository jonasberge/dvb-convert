#!/bin/bash

# include environment
if [[ -f .env ]]; then
    . ./.env
fi

PROJX_DIR="project-x"
PROJX_JAR="$PROJX_DIR/ProjectX.jar"

JAVA="java"
JAVA_OPTS="-Djava.awt.headless=true"
PROJX="$JAVA $JAVA_OPTS -jar $PROJX_JAR"

IN_DIR=${IN_DIR:-"./input"}
IN_DIR=${1:-$IN_DIR}

OUT_DIR=${OUT_DIR:-"./output"}
OUT_DIR=${2:-$OUT_DIR}

CONV_DIR="$OUT_DIR/conv"
ERR_LOG="$OUT_DIR/err.log"

VID_EXT="VID"
AUD_EXT="AUD"

STRIP_LEN=17

function filter_convert_out_file {
    grep -o "new File: '\?[^']*'\?" \
        | sed -e "s/new File: '\([^']*\)'/\1/g" \
        | sed -e "s/new File: \([^']*\)/\1/g"
}

function convert {
    $PROJX "$@" \
        | tee /dev/tty \
        | filter_convert_out_file
}

function sanitize {
    echo "$@" | sed -e 's/[^A-Za-z0-9._-]/_/g'
}

function clear {
    rm -rf $OUT_DIR/*
}

clear
set -x

mkdir -p "$OUT_DIR"
mkdir -p "$CONV_DIR"

for FILE_VID in $IN_DIR/**/*.$VID_EXT; do
    DIR=$(dirname "$FILE_VID")
    FOLDER="${DIR#$IN_DIR/}"
    BASE=$(basename "$FILE_VID" $VID_EXT)
    BASE="${BASE%.*}"
    FILE_AUD="$DIR/$BASE.$AUD_EXT"

    if [[ ! -f "$FILE_AUD" ]]; then
        echo "WARN: no .$AUD_EXT file ($FILE_AUD) for $FILE_VID" > "$ERR_LOG"
        continue
    fi

    # strip prefix if name is long enough
    # used to remove the timestamp prefix of receiver recordings
    if [ ${#BASE} -gt $STRIP_LEN ]; then
        BASE="${BASE:$STRIP_LEN}"
    fi

    BASE_SAN=$(sanitize $BASE)

    # remux files to something usable
    CONV_SUB_DIR="$CONV_DIR/$FOLDER"
    mkdir -p "$CONV_SUB_DIR"
    RES_FILES=$(convert -out "$CONV_SUB_DIR" -name "$BASE_SAN" "$FILE_VID" "$FILE_AUD")

    IFS=$'\n' read -rd '' -a RES_FILES <<<"$RES_FILES"
    RES_VID="${RES_FILES[0]}"
    RES_AUD="${RES_FILES[1]}"

    FFMPEG_OUT="$OUT_DIR/$BASE.mp4"
    FFMPEG_OUT_SAN="$OUT_DIR/$BASE_SAN.mp4"

    # combine to mp4
    ffmpeg -y -i "$RES_VID" -i "$RES_AUD" -c:v libx264 "$FFMPEG_OUT_SAN"
    mv "$FFMPEG_OUT_SAN" "$FFMPEG_OUT"
done
