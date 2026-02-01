#!/bin/bash
# mgrep-init.sh - Portable mgrep initialization for any project
# Ensures mgrep watch is running for Skills + project files

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MGREP_LOG="/tmp/mgrep-watch-$(basename "$PROJECT_ROOT").log"
MGREP_PID_FILE="/tmp/mgrep-watch-$(basename "$PROJECT_ROOT").pid"

# Check if mgrep is installed
if ! command -v mgrep &> /dev/null; then
    echo "❌ mgrep not installed. Install: npm install -g @mixedbread-ai/mgrep"
    exit 1
fi

# Check if mgrep watch is already running for this project
if [ -f "$MGREP_PID_FILE" ]; then
    PID=$(cat "$MGREP_PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✓ mgrep watch already running (PID: $PID)"
        exit 0
    else
        rm -f "$MGREP_PID_FILE"
    fi
fi

# Start mgrep watch
echo "⚡ Starting mgrep watch for: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

# Start in background and capture PID
mgrep watch > "$MGREP_LOG" 2>&1 &
MGREP_PID=$!

# Save PID
echo "$MGREP_PID" > "$MGREP_PID_FILE"

# Wait a moment and verify it's running
sleep 2
if ps -p "$MGREP_PID" > /dev/null 2>&1; then
    echo "✓ mgrep watch started (PID: $MGREP_PID)"
    echo "  Log: $MGREP_LOG"
    echo "  Indexing: Skills/, workflows/, and all project files"
else
    echo "❌ Failed to start mgrep watch"
    rm -f "$MGREP_PID_FILE"
    exit 1
fi
