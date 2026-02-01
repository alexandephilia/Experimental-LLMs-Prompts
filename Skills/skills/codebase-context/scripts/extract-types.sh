#!/bin/bash
# extract-types.sh - Extracts TypeScript type definitions
# Outputs interface and type inventory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "# Type Definitions"
echo ""

# Check for TypeScript
if [[ ! -f "tsconfig.json" ]]; then
    echo "No tsconfig.json found - not a TypeScript project"
    exit 0
fi

if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) not installed"
    exit 1
fi

# Find dedicated types file
TYPES_FILE=""
for candidate in "types.ts" "types/index.ts" "src/types.ts" "src/types/index.ts"; do
    if [[ -f "$candidate" ]]; then
        TYPES_FILE="$candidate"
        break
    fi
done

if [[ -n "$TYPES_FILE" ]]; then
    echo "## Main Types File: \`$TYPES_FILE\`"
    echo ""
    echo '```typescript'
    cat "$TYPES_FILE"
    echo '```'
    echo ""
fi

echo "## Interfaces"
echo ""

# Extract all interface definitions
rg "^(export )?interface \w+" --type ts -o 2>/dev/null | while read -r line; do
    file="${line%%:*}"
    iface="${line#*:}"
    name=$(echo "$iface" | grep -oE "interface \w+" | sed 's/interface //')
    echo "- \`$name\` ← \`$file\`"
done | sort -u | head -50

echo ""
echo "## Type Aliases"
echo ""

# Extract type aliases
rg "^(export )?type \w+ =" --type ts -o 2>/dev/null | while read -r line; do
    file="${line%%:*}"
    typedef="${line#*:}"
    name=$(echo "$typedef" | grep -oE "type \w+" | sed 's/type //')
    echo "- \`$name\` ← \`$file\`"
done | sort -u | head -30

echo ""
echo "## Enums"
echo ""

# Extract enums
rg "^(export )?enum \w+" --type ts -o 2>/dev/null | while read -r line; do
    file="${line%%:*}"
    enumdef="${line#*:}"
    name=$(echo "$enumdef" | grep -oE "enum \w+" | sed 's/enum //')
    echo "- \`$name\` ← \`$file\`"
done | sort -u | head -20
