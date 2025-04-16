#!/bin/bash

# chmod +x server.sh
# ./server.sh

# > Note: Requires Vercel serve global install.
# >> sudo npm install -g serve

# > Note: Requires Python 3, if not using Vercel serve.
# >> brew install python3

DEV_SERVER_PORT="${1:-3000}"

if [ -n "$DEV_SERVER_PORT" ]; then
  if command -v serve &> /dev/null; then
    serve -p "$DEV_SERVER_PORT"
  else
    python3 -m http.server "$DEV_SERVER_PORT"
  fi
fi
