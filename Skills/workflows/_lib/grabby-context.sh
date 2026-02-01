#!/bin/bash

# ============================================
# Grabby Context Generator
# Extracts and formats Grabby Tool context
# ============================================

# Generate full Grabby context for AI
generate_grabby_context() {
    local element_file="${1:-.grabbed_element}"
    
    cat <<EOF
# GRABBY TOOLS CONTEXT

## What is Grabby?
Grabby Inspector is a precision element inspector for AI-assisted development.
It allows you to visually select elements in the browser and capture their data.

## How it works:
1. User adds \`?grab=true\` to URL
2. User holds Cmd/Ctrl and hovers over elements
3. User clicks to capture element data
4. Data is saved to \`.grabbed_element\` file
5. AI reads this file to understand what element was selected

## Current Grabbed Element:
$(format_grabbed_element "$element_file")

## Available Workflows:
- element-redesign: Analyze and propose design improvements
- component-extract: Extract element to reusable component
- style-refactor: Refactor inline styles to Tailwind
- accessibility-audit: Check and fix accessibility issues

## Key Files:
- \`.grabbed_element\`: Current selected element data
- \`.workflow_output/\`: Workflow results
- \`Skills/skills/\`: Available skills (tailwind-css, frontend-design, codebase-context)

EOF
}

# Format grabbed element data for AI
format_grabbed_element() {
    local element_file="$1"
    
    if [[ ! -f "$element_file" ]]; then
        echo "❌ No element grabbed yet"
        return
    fi
    
    local selector=$(jq -r '.selector' "$element_file")
    local tag=$(jq -r '.tagName' "$element_file")
    local classes=$(jq -r '.className' "$element_file")
    local text=$(jq -r '.innerText' "$element_file" | head -c 100)
    local width=$(jq -r '.rect.width' "$element_file")
    local height=$(jq -r '.rect.height' "$element_file")
    
    cat <<EOF
✅ Element captured at $(jq -r '.timestamp' "$element_file")

**Tag**: \`$tag\`
**Selector**: \`$selector\`
**Classes**: \`$classes\`
**Text**: "$text"
**Dimensions**: ${width}x${height}px

**Computed Styles** (key properties):
$(jq -r '.styles | to_entries | map("  - \(.key): \(.value)") | .[:10] | join("\n")' "$element_file")
EOF
}

# Check if element was recently grabbed (within last N seconds)
is_recently_grabbed() {
    local element_file="${1:-.grabbed_element}"
    local max_age_seconds="${2:-300}"  # Default 5 minutes
    
    if [[ ! -f "$element_file" ]]; then
        return 1
    fi
    
    local file_age=$(($(date +%s) - $(stat -f %m "$element_file" 2>/dev/null || stat -c %Y "$element_file")))
    [[ $file_age -lt $max_age_seconds ]]
}
