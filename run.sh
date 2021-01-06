#!/bin/bash

cd $(dirname $0)
./convert-mp4.sh

echo "Done."
read -p "Press enter to close this window."
