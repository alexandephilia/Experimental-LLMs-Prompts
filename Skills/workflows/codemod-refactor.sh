#!/bin/bash
set -e

# ============================================
# CODEMOD REFACTOR WORKFLOW
# AST-based code transformations using Codemod CLI
# Usage: codemod-refactor.sh <transform_file> <target_dir> [--dry-run]
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
TRANSFORM_FILE=""
TARGET_DIR=""
DRY_RUN=false
LANGUAGE="typescript"

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --language)
            LANGUAGE="$2"
            shift 2
            ;;
        *)
            if [[ -z "$TRANSFORM_FILE" ]]; then
                TRANSFORM_FILE="$1"
            elif [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$TRANSFORM_FILE" ]] || [[ -z "$TARGET_DIR" ]]; then
    echo "Usage: codemod-refactor.sh <transform_file> <target_dir> [--dry-run] [--language <lang>]"
    echo ""
    echo "Examples:"
    echo "  # Dry-run to preview changes"
    echo "  codemod-refactor.sh ./fix-useEffect.ts ./src --dry-run"
    echo ""
    echo "  # Apply changes"
    echo "  codemod-refactor.sh ./fix-useEffect.ts ./src"
    echo ""
    echo "  # Specify language"
    echo "  codemod-refactor.sh ./transform.ts ./src --language javascript"
    echo ""
    echo "Supported languages: typescript, javascript, python, java, cpp, php, kotlin, etc."
    exit 1
fi

# Check if codemod is installed
if ! command -v codemod &> /dev/null; then
    echo -e "${RED}✗${NC} Codemod CLI is not installed"
    echo ""
    echo "Install with: npm install -g codemod"
    exit 1
fi

# Check if transform file exists
if [[ ! -f "$TRANSFORM_FILE" ]]; then
    echo -e "${RED}✗${NC} Transform file not found: $TRANSFORM_FILE"
    exit 1
fi

# Check if target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}✗${NC} Target directory not found: $TARGET_DIR"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "  🔍 CODEMOD DRY-RUN (Preview Only)"
else
    echo "  ⚡ CODEMOD REFACTOR (Applying Changes)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Transform:${NC} $TRANSFORM_FILE"
echo -e "${BLUE}Target:${NC} $TARGET_DIR"
echo -e "${BLUE}Language:${NC} $LANGUAGE"
echo ""

# Build codemod command
CODEMOD_CMD="npx codemod jssg run \"$TRANSFORM_FILE\" --language $LANGUAGE -t \"$TARGET_DIR\" --allow-dirty --no-interactive"

if [[ "$DRY_RUN" == "true" ]]; then
    CODEMOD_CMD="$CODEMOD_CMD --dry-run"
fi

# Run codemod
echo -e "${YELLOW}⚡${NC} Running codemod..."
echo ""

eval "$CODEMOD_CMD"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${GREEN}✓${NC} Dry-run complete (no changes applied)"
    echo ""
    echo "To apply changes, run without --dry-run:"
    echo "  bash Skills/workflows/codemod-refactor.sh $TRANSFORM_FILE $TARGET_DIR"
else
    echo -e "${GREEN}✓${NC} Refactor complete"
fi
echo ""
