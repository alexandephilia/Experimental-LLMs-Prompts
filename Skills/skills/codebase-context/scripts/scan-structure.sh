#!/bin/bash
# scan-structure.sh - Scans project structure and outputs tree with annotations
# Uses find as primary tool (universally available)

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "# Project Structure: $(basename "$PROJECT_ROOT")"
echo ""
echo "## Key Directories"
echo ""

# Check each directory
check_dir() {
    local dir="$1"
    local desc="$2"
    if [ -d "$dir" ]; then
        local count
        count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        echo "- \`$dir/\` - $desc ($count files)"
    fi
}

check_dir "components" "React UI components"
check_dir "components/showcases" "Component showcases"
check_dir "hooks" "Custom React hooks"
check_dir "utils" "Utility functions"
check_dir "lib" "Library code and helpers"
check_dir "api" "API routes"
check_dir "public" "Static assets"
check_dir ".agent" "Agent configuration"

echo ""
echo "## Root Files"
echo ""

check_file() {
    local file="$1"
    local desc="$2"
    if [ -f "$file" ]; then
        local lines
        lines=$(wc -l < "$file" | tr -d ' ')
        echo "- \`$file\` - $desc ($lines lines)"
    fi
}

check_file "package.json" "Project manifest"
check_file "tsconfig.json" "TypeScript config"
check_file "vite.config.ts" "Vite build config"
check_file "App.tsx" "Main app component"
check_file "main.tsx" "Entry point"
check_file "index.html" "HTML template"
check_file "types.ts" "Type definitions"
check_file "constants.ts" "Constants"
check_file "index.css" "Global styles"

echo ""
echo "## Component Inventory"
echo ""

if [ -d "components" ]; then
    echo "| Component | Lines | Has useEffect |"
    echo "|-----------|-------|---------------|"
    
    # Find direct children of components/ only (not subdirs)
    find components/ -maxdepth 1 -name "*.tsx" -type f 2>/dev/null | sort | while read -r file; do
        name=$(basename "$file" .tsx)
        lines=$(wc -l < "$file" | tr -d ' ')
        has_effect="No"
        if grep -q "useEffect" "$file" 2>/dev/null; then
            has_effect="**Yes**"
        fi
        echo "| \`$name\` | $lines | $has_effect |"
    done
fi

echo ""
echo "## Showcase Components"
echo ""

if [ -d "components/showcases" ]; then
    find components/showcases/ -name "*.tsx" -type f 2>/dev/null | sort | while read -r file; do
        name=$(basename "$file" .tsx)
        lines=$(wc -l < "$file" | tr -d ' ')
        has_effect="No"
        if grep -q "useEffect" "$file" 2>/dev/null; then
            has_effect="(has useEffect)"
        fi
        echo "- \`$name\` - $lines lines $has_effect"
    done
fi

echo ""
echo "## useEffect Audit"
echo ""

total_effects=$(grep -r "useEffect" components/ --include="*.tsx" 2>/dev/null | wc -l | tr -d ' ')
echo "Total useEffect instances in components/: **$total_effects**"
echo ""

if [ "$total_effects" -gt 0 ]; then
    echo "| File | Count |"
    echo "|------|-------|"
    grep -c "useEffect" components/*.tsx 2>/dev/null | grep -v ":0" | while IFS=: read -r file count; do
        name=$(basename "$file" .tsx)
        echo "| \`$name\` | $count |"
    done
fi
