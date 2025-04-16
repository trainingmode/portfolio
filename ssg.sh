#!/bin/bash

#########################################
####                                 ####
####  SSG (SAUSAGE)                  ####
####  Alfred R. Duarte               ####
####                                 ####
#########################################
####                                 ####
####  Run ssg.sh to build, serve, &  ####
####  automatically rebuild on any   ####
####  changes made to your project.  ####
####                                 ####
#########################################

# chmod +x ssg.sh build.sh server.sh
# ./ssg.sh

# > Note: Requires chokidar-cli global install.
# >> sudo npm install -g chokidar-cli

# > Note: Development server requires Vercel serve or Python 3.
# >> sudo npm install -g serve
# >> brew install python3

WATCH_FOLDER="."
BUILD_SCRIPT="./build.sh"
DEV_SERVER_SCRIPT="./server.sh"

DEV_SERVER_PORT="${1}"

INPUT_DIRECTORY="${2:-markdown}"
OUTPUT_DIRECTORY="${3:-projects}"

build() {
  echo "🪏🤠 BUILDING: $INPUT_DIRECTORY/ → $OUTPUT_DIRECTORY/"
  start_time=$(date +%s%N)
  $BUILD_SCRIPT "$INPUT_DIRECTORY" "$OUTPUT_DIRECTORY"
  duration=$(($(date +%s%N) - start_time))
  echo "🤠🎉 BUILD $OUTPUT_DIRECTORY/ COMPLETED in $((duration / 1000000)) ms."
}

serve() {
  $DEV_SERVER_SCRIPT "$DEV_SERVER_PORT" &
  echo "🐴🤠 RUNNING DEV SERVER: $!"
}

build
serve &

while IFS= read -r filepath; do
  echo "🔍🤠 OBSERVED CHANGE: $filepath"
  build
  echo "🌀🤠 Reload your browser to see changes."
done < <(chokidar "$WATCH_FOLDER" -i "$OUTPUT_DIRECTORY" -i "*.sh" -i "~tmp.*.md" --initial false)
