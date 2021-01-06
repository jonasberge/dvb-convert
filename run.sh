#!/bin/bash

IN_DIR=in
OUT_DIR=out

cd $(dirname $0)
make IN_DIR=$IN_DIR OUT_DIR=$OUT_DIR convert

echo "Done."
read -p "Press enter to close this window."
