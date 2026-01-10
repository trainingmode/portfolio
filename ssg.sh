#!/bin/bash

#########################################
####                                 ####
####  SASHA — Static Site Generator  ####
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

# > Note: Requires Bash >4 & Pandoc.
# >> brew install bash pandoc

# > Note: Requires chokidar-cli global install.
# >> sudo npm install -g chokidar-cli

# > Note: Development server requires Vercel serve or Python 3.
# >> sudo npm install -g serve
# >> brew install python3

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

WATCH_FOLDER="."
BUILD_SCRIPT="./build.sh"
DEV_SERVER_SCRIPT="./server.sh"

CONFIG_FILE="${1:-ssg.config}"
INPUT_DIRECTORY="${2:-markdown}"
OUTPUT_DIRECTORY="${3:-portfolio}"
TEMPLATE_DIRECTORY="${4:-templates}"
IGNORE_FILE="${5:-.ssgignore}"

LOCKDIR="${SCRIPT_DIR}/.ssg.lock"

cleanup() {
  pids="$(jobs -pr 2>/dev/null || true)"
  if [ -n "${pids:-}" ]; then
    kill $pids 2>/dev/null || true
  fi
  rm -rf "$LOCKDIR" 2>/dev/null || true
}

acquire_lock() {
  if mkdir "$LOCKDIR" 2>/dev/null; then
    echo "$$" > "$LOCKDIR/pid"
    trap cleanup EXIT INT TERM HUP
    return 0
  fi

  if [ -f "$LOCKDIR/pid" ]; then
    other_pid="$(cat "$LOCKDIR/pid" 2>/dev/null || true)"
    if [ -n "${other_pid:-}" ] && kill -0 "$other_pid" 2>/dev/null; then
      echo "🧯🤠 LOCKED: Another ssg.sh is already running (pid $other_pid)."
      echo "          Stop it (Ctrl+C in that terminal) or: kill $other_pid"
      exit 1
    fi
  fi

  echo "🧹🤠 LOCK: Found a stale lock. Clearing it and continuing..."
  rm -rf "$LOCKDIR" 2>/dev/null || true
  if mkdir "$LOCKDIR" 2>/dev/null; then
    echo "$$" > "$LOCKDIR/pid"
    trap cleanup EXIT INT TERM HUP
    return 0
  fi

  echo "ERROR: Could not acquire lock at '$LOCKDIR'."
  exit 1
}

build() {
  echo "🪏🤠 BUILDING: $INPUT_DIRECTORY/ → $OUTPUT_DIRECTORY/"
  start_time=$(date +%s%N)
  $BUILD_SCRIPT "$CONFIG_FILE" "$INPUT_DIRECTORY" "$OUTPUT_DIRECTORY" "$TEMPLATE_DIRECTORY"
  duration=$(($(date +%s%N) - start_time))
  echo "🤠🎉 BUILD $OUTPUT_DIRECTORY/ COMPLETED in $((duration / 1000000)) ms."
}

serve() {
  source "$CONFIG_FILE"
  $DEV_SERVER_SCRIPT "$PORT" &
  echo "🐴🤠 RUNNING DEV SERVER: $!"
}

acquire_lock
build
serve

# Build Ignore List

ssg_ignore=(-i "$OUTPUT_DIRECTORY" -i "*.sh" -i "*~tmp.XXXXXX.md" -i ".git/" -i ".git/**" -i ".DS_Store")
if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    ssg_ignore+=( -i "$pattern" )
  done < "$IGNORE_FILE"
fi

# Watch for Changes

while IFS= read -r filepath; do
  echo "🔍🤠 OBSERVED CHANGE: $filepath"
  build
  echo "🌀🤠 Reload your browser to see changes."
done < <(chokidar "$WATCH_FOLDER" "${ssg_ignore[@]}" --initial false)
