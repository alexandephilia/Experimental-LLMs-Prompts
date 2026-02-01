#!/bin/bash
# extract-components.sh - Extracts React component and hook signatures
# Outputs structured component inventory with props and purpose
# Usage: ./extract-components.sh [selector] [--list]
#
# With selector: Finds component containing that element
# With --list: Lists all components

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

capitalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) substr($0,2)}'
}

escape_regex() {
    echo "$1" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g'
}

find_component_by_selector() {
    local selector="$1"
    
    # Extract the last element from selector (e.g., "section.p-6.md:p-8.bg-[#FAFAFA]")
    local last_element=$(echo "$selector" | grep -oE '[^ >]+\.[^ >]+$' | tail -1)
    
    if [[ -z "$last_element" ]]; then
        echo "Not found"
        return
    fi
    
    # Extract tag and classes from last element
    local tag=$(echo "$last_element" | cut -d. -f1)
    local raw_classes=$(echo "$last_element" | cut -d. -f2-)
    
    # Check if this is likely a Tailwind class (single short class like "p-6")
    # vs a unique identifier (multiple classes, brackets, etc.)
    local is_likely_tailwind=false
    if [[ "$raw_classes" =~ ^[a-z]+-[0-9]+$ ]] || [[ ${#raw_classes} -lt 8 ]]; then
        is_likely_tailwind=true
    fi
    
    # Split classes by dots for searching
    local classes=$(echo "$raw_classes" | sed 's/\./\n/g' | grep -E '^[a-zA-Z]' | head -5)
    
    local found_file="Not found"
    local candidates=()
    
    # Try 0: Search for the full class string ONLY if it looks like a unique identifier
    # (contains brackets, or is longer, or has multiple classes)
    if [[ "$is_likely_tailwind" == "false" ]]; then
        local escaped_classes=$(escape_regex "$raw_classes")
        local exact_match=$(rg -l "${escaped_classes}" components/ 2>/dev/null)
        if [[ -n "$exact_match" ]]; then
            echo "$exact_match" | head -1
            return
        fi
    fi
    
    # Try 1: Search for files containing the tag name as component
    if [[ -n "$tag" ]]; then
        local pascal_tag=$(capitalize "$tag")
        local match=$(rg -l "export const ${pascal_tag}" components/ 2>/dev/null | head -1)
        if [[ -n "$match" ]]; then
            echo "$match"
            return
        fi
    fi
    
    # Try 2: Search by class names (longer classes only)
    for class in $classes; do
        if [[ ${#class} -gt 4 ]]; then
            local class_cap=$(capitalize "$class")
            local matches=$(rg -l "export const ${class_cap}" components/ 2>/dev/null || true)
            for m in $matches; do
                candidates+=("$m")
            done
        fi
    done
    
    # Remove duplicates
    IFS=$'\n' candidates=($(printf '%s\n' "${candidates[@]}" | sort -u))
    unset IFS
    
    if [[ ${#candidates[@]} -gt 0 ]]; then
        echo "${candidates[0]}"
        return
    fi
    
    # Try 3: Search by id attribute in selector
    local id=$(echo "$selector" | grep -oE '#[a-zA-Z0-9_-]+' | sed 's/#//' | head -1)
    if [[ -n "$id" ]]; then
        local match=$(rg -l "id=['\"]${id}['\"]" components/ 2>/dev/null | head -1)
        if [[ -n "$match" ]]; then
            echo "$match"
            return
        fi
    fi
    
    echo "Not found"
}

# Check for components directory
if [[ ! -d "components" ]]; then
    echo "No components/ directory found"
    exit 0
fi

# Check for ripgrep
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) not installed"
    exit 1
fi

# Parse arguments
SELECTOR=""
LIST_ALL=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            LIST_ALL=true
            shift
            ;;
        -*)
            shift
            ;;
        *)
            SELECTOR="$1"
            shift
            ;;
    esac
done

# If selector provided, find matching component
if [[ -n "$SELECTOR" ]]; then
    find_component_by_selector "$SELECTOR"
    exit 0
fi

# List all components (default behavior)
echo "# Component Signatures"
echo ""

echo "## React Components"
echo ""

# Find exported components with their props interface
rg -l "export (const|function|default)" components/ 2>/dev/null | while read -r file; do
    component_name=$(basename "$file" | sed 's/\.[^.]*$//')

    echo "### \`$component_name\`"
    echo "**File:** \`$file\`"
    echo ""

    # Extract props interface if exists
    props_interface=$(rg "interface ${component_name}Props" "$file" -A 10 2>/dev/null | head -15 || true)
    if [[ -n "$props_interface" ]]; then
        echo "**Props:**"
        echo '```typescript'
        echo "$props_interface"
        echo '```'
    fi

    # Extract function signature
    signature=$(rg "export (const|function) ${component_name}" "$file" 2>/dev/null | head -1 || true)
    if [[ -n "$signature" ]]; then
        echo "**Signature:** \`$signature\`"
    fi

    echo ""
done | head -200  # Limit output

echo "## Custom Hooks"
echo ""

# Find custom hooks (use* pattern)
rg "export (const|function) use\w+" components/ hooks/ 2>/dev/null | while read -r line; do
    file="${line%%:*}"
    sig="${line#*:}"
    hook_name=$(echo "$sig" | grep -oE "use\w+" | head -1)

    if [[ -n "$hook_name" ]]; then
        echo "- \`$hook_name\` - \`$(basename "$file")\`"
    fi
done | sort -u | head -30

echo ""

echo "## Component Patterns Detected"
echo ""

# Detect common patterns
if rg -q "useState" components/ 2>/dev/null; then
    echo "- ✓ useState (local state)"
fi

if rg -q "useRef" components/ 2>/dev/null; then
    echo "- ✓ useRef (DOM/value references)"
fi

if rg -q "useEffect" components/ 2>/dev/null; then
    effect_count=$(rg -c "useEffect" components/ 2>/dev/null | awk -F: '{sum += $2} END {print sum}')
    echo "- ⚠ useEffect ($effect_count instances - review for necessity)"
fi

if rg -q "useMemo|useCallback" components/ 2>/dev/null; then
    echo "- ✓ useMemo/useCallback (memoization)"
fi

if rg -q "createContext|useContext" components/ 2>/dev/null; then
    echo "- ✓ Context API (state sharing)"
fi

if rg -q "framer-motion|motion\." components/ 2>/dev/null; then
    echo "- ✓ Motion animations"
fi
