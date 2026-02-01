#!/bin/bash
set -e

# ============================================
# SKILL QUERY SYSTEM (MGREP-POWERED)
# Autonomous semantic search with auto-indexing
# Usage: query-skill.sh [--web] [--answer] <natural language query>
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../skills"
WATCH_PID_FILE="/tmp/mgrep-watch-$(basename "$PROJECT_ROOT").pid"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse flags
WEB_SEARCH=false
ANSWER_MODE=false
QUERY_ARGS=()

for arg in "$@"; do
    if [[ "$arg" == "--web" ]]; then
        WEB_SEARCH=true
    elif [[ "$arg" == "--answer" ]]; then
        ANSWER_MODE=true
    else
        QUERY_ARGS+=("$arg")
    fi
done

QUERY="${QUERY_ARGS[*]}"

if [[ -z "$QUERY" ]]; then
    echo "Usage: query-skill.sh [--web] [--answer] <natural language query>"
    echo ""
    echo "Examples:"
    echo "  query-skill.sh \"how to implement smooth scroll animations\""
    echo "  query-skill.sh \"tailwind grid layout patterns\""
    echo "  query-skill.sh --web \"latest React 19 features\""
    echo "  query-skill.sh --web --answer \"what are React Server Components\""
    echo ""
    echo "Flags:"
    echo "  --web       Search web + local files (requires internet)"
    echo "  --answer    Get summarized answer (better for AI token efficiency)"
    echo ""
    echo "Powered by mgrep - semantic search for AI workflows"
    exit 1
fi

# Check if mgrep is installed
if ! command -v mgrep &> /dev/null; then
    echo -e "${RED}✗${NC} mgrep is not installed"
    echo ""
    echo "Install with: npm install -g @mixedbread/mgrep"
    exit 1
fi

# Auto-start mgrep watch if not running (only for local search)
if [[ "$WEB_SEARCH" == "false" ]]; then
    if [[ -f "$WATCH_PID_FILE" ]]; then
        WATCH_PID=$(cat "$WATCH_PID_FILE")
        if ! ps -p "$WATCH_PID" > /dev/null 2>&1; then
            rm -f "$WATCH_PID_FILE"
        fi
    fi

    if [[ ! -f "$WATCH_PID_FILE" ]]; then
        echo -e "${YELLOW}⚡${NC} Starting mgrep indexing..."
        cd "$SKILLS_DIR"
        nohup mgrep watch --max-file-count 2000 --max-file-size 2097152 > /dev/null 2>&1 &
        echo $! > "$WATCH_PID_FILE"
        sleep 3  # Wait for initial indexing
        echo -e "${GREEN}✓${NC} Index ready"
        echo ""
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ "$WEB_SEARCH" == "true" ]]; then
    if [[ "$ANSWER_MODE" == "true" ]]; then
        echo "  🌐 SEMANTIC SEARCH (Web + Local, Answer Mode): $QUERY"
    else
        echo "  🌐 SEMANTIC SEARCH (Web + Local): $QUERY"
    fi
else
    if [[ "$ANSWER_MODE" == "true" ]]; then
        echo "  🔍 SEMANTIC SEARCH (Local, Answer Mode): $QUERY"
    else
        echo "  🔍 SEMANTIC SEARCH (Local): $QUERY"
    fi
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run mgrep semantic search
cd "$SKILLS_DIR"
MGREP_CMD="mgrep"

if [[ "$WEB_SEARCH" == "true" ]]; then
    MGREP_CMD="$MGREP_CMD --web"
fi

if [[ "$ANSWER_MODE" == "true" ]]; then
    MGREP_CMD="$MGREP_CMD --answer"
else
    MGREP_CMD="$MGREP_CMD -m 15 -c"
fi

eval "$MGREP_CMD \"$QUERY\" ."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓${NC} Search complete"
echo ""
