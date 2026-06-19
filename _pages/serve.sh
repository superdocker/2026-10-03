#!/bin/bash
cd "$(dirname "$0")"

PORT="${1:-8080}"

echo "Preview: http://localhost:$PORT"

open "http://localhost:$PORT" 2>/dev/null

python3 -m http.server "$PORT"
