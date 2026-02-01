#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib/common.sh"

ELEMENT_FILE="${1:-.grabbed_element}"
OUTPUT_DIR=".workflow_output"
OUTPUT_FILE="$OUTPUT_DIR/redesign-proposal.md"
CONTEXT_FILE="$OUTPUT_DIR/grabby-context.md"

ensure_dir "$OUTPUT_DIR"

if [[ ! -f "$ELEMENT_FILE" ]]; then
    error "No grabbed element found. Add ?grab=true to URL and grab an element first."
fi

is_recently_grabbed() {
    local max_age_seconds="${1:-300}"
    if [[ ! -f "$ELEMENT_FILE" ]]; then
        return 1
    fi
    local file_age=$(($(date +%s) - $(stat -f %m "$ELEMENT_FILE" 2>/dev/null || stat -c %Y "$ELEMENT_FILE")))
    [[ $file_age -lt $max_age_seconds ]]
}

generate_grabby_context() {
    local selector=$(jq -r '.selector' "$ELEMENT_FILE" 2>/dev/null || echo "unknown")
    local tag=$(jq -r '.tagName' "$ELEMENT_FILE" 2>/dev/null || echo "unknown")
    local classes=$(jq -r '.className' "$ELEMENT_FILE" 2>/dev/null || echo "none")
    local text=$(jq -r '.innerText' "$ELEMENT_FILE" 2>/dev/null | head -c 100 || echo "")
    local width=$(jq -r '.rect.width' "$ELEMENT_FILE" 2>/dev/null || echo "0")
    local height=$(jq -r '.rect.height' "$ELEMENT_FILE" 2>/dev/null || echo "0")

    cat > "$CONTEXT_FILE" <<EOF
# GRABBY TOOLS CONTEXT

**Generated**: $(timestamp)
**Source**: element-redesign.sh

## Element

- **Tag**: \`$tag\`
- **Selector**: \`$selector\`
- **Classes**: \`$classes\`
- **Dimensions**: ${width}x${height}px

**Text**: "$text"

## Workflow

**Element Redesign** - Analyzing element and proposing design improvements.

EOF
    log "Context generated: $CONTEXT_FILE"
}

find_component_path() {
    local selector="$1"
    local script="Skills/skills/codebase-context/scripts/extract-components.sh"

    if [[ -x "$script" ]]; then
        bash "$script" "$selector" 2>/dev/null || echo "Not found"
    else
        echo "Not found"
    fi
}

main() {
    log "Element Redesign Workflow started"

    if ! is_recently_grabbed 300; then
        warn "Element was grabbed more than 5 minutes ago"
        info "Consider grabbing a fresh element"
    fi

    generate_grabby_context

    local selector=$(get_element_selector "$ELEMENT_FILE")
    local tag=$(get_element_tag "$ELEMENT_FILE")
    local classes=$(get_element_classes "$ELEMENT_FILE")
    local width=$(jq -r '.rect.width' "$ELEMENT_FILE")
    local height=$(jq -r '.rect.height' "$ELEMENT_FILE")
    local component_path=$(find_component_path "$selector")
    local styles=$(jq -r '.styles | to_entries | map("- **\(.key)**: \(.value)") | join("\n")' "$ELEMENT_FILE")
    local tag_cap=$(echo "$tag" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')

    log "Analyzing: $tag ($selector)"

    {
        echo "# Element Redesign Proposal"
        echo ""
        echo "**Generated**: $(timestamp)"
        echo ""
        echo "## Current Element"
        echo ""
        echo "- **Tag**: \`$tag\`"
        echo "- **Selector**: \`$selector\`"
        echo "- **Classes**: \`$classes\`"
        echo "- **Component**: \`$component_path\`"
        echo "- **Dimensions**: ${width}x${height}px"
        echo ""
        echo "## Element Data"
        echo ""
        echo "\`\`\`json"
        cat "$ELEMENT_FILE"
        echo "\`\`\`"
        echo ""
        echo "## Design Analysis"
        echo ""
        echo "### Current Styles"
        echo "$styles"
        echo ""
        echo "### Dimensions"
        echo "- Width: ${width}px"
        echo "- Height: ${height}px"
        echo ""
        echo "## Design Assessment"
        echo ""
        echo "### Strengths"
        echo "- Semantic HTML (\`$tag\` element)"
        echo "- Tailwind classes detected: $classes"
        echo ""
        echo "### Opportunities"
        echo "- Typography improvements"
        echo "- Color palette refinement"
        echo "- Spacing consistency"
        echo "- Motion/animation enhancements"
        echo "- Accessibility enhancements"
        echo ""
        echo "## Redesign Options"
        echo ""
        echo "### OPTION 1: Minimal Refinement"
        echo "**Goal**: Small improvements while keeping current design"
        echo ""
        echo "**Changes**:"
        echo "- Refine typography (font weight, line height)"
        echo "- Improve color contrast if needed"
        echo "- Add subtle border or shadow"
        echo "- Enhance focus states"
        echo ""
        echo "**Tailwind**:"
        echo "\`\`\`html"
        echo "<$tag class=\"$classes text-gray-700 leading-relaxed\">"
        echo "  <!-- content -->"
        echo "</$tag>"
        echo "\`\`\`"
        echo ""
        echo "**Pros**: Low risk, quick implementation"
        echo "**Cons**: Limited visual impact"
        echo ""
        echo "---"
        echo ""
        echo "### OPTION 2: Modern Refresh"
        echo "**Goal**: Update to modern design patterns"
        echo ""
        echo "**Changes**:"
        echo "- Add glassmorphism effects"
        echo "- Include subtle animations"
        echo "- Improve responsive behavior"
        echo "- Update color palette"
        echo "- Add hover interactions"
        echo ""
        echo "**Tailwind**:"
        echo "\`\`\`html"
        echo "<$tag class=\"$classes"
        echo "  bg-white/80 backdrop-blur-md"
        echo "  rounded-2xl shadow-lg"
        echo "  border border-gray-100"
        echo "  hover:shadow-xl transition-shadow"
        echo "  duration-300\">"
        echo "  <!-- content -->"
        echo "</$tag>"
        echo "\`\`\`"
        echo ""
        echo "**Pros**: Significant improvement, maintainable"
        echo "**Cons**: Requires more testing"
        echo ""
        echo "---"
        echo ""
        echo "### OPTION 3: Complete Redesign"
        echo "**Goal**: Reimagine the element from scratch"
        echo ""
        echo "**Changes**:"
        echo "- New visual hierarchy"
        echo "- Modern component patterns"
        echo "- Motion-rich interactions"
        echo "- Accessibility-first approach"
        echo "- Performance optimization"
        echo ""
        echo "**Tailwind**:"
        echo "\`\`\`html"
        echo "<$tag class=\""
        echo "  relative overflow-hidden"
        echo "  bg-gradient-to-br from-gray-50 to-gray-100"
        echo "  rounded-3xl p-8"
        echo "  shadow-[0_8px_30px_rgb(0,0,0,0.04)]"
        echo "  border border-gray-200/50"
        echo "  motion-safe:hover:scale-[1.02]"
        echo "  motion-safe:hover:shadow-[0_20px_40px_rgb(0,0,0,0.08)]"
        echo "  transition-all duration-500\">"
        echo "  <!-- content -->"
        echo "</$tag>"
        echo "\`\`\`"
        echo ""
        echo "**Pros**: Best long-term solution"
        echo "**Cons**: High effort, needs thorough testing"
        echo ""
        echo "## Motion Enhancements"
        echo ""
        echo "Using Motion for React (\`motion/react\`):"
        echo ""
        echo "\`\`\`tsx"
        echo "import { motion } from 'motion/react';"
        echo ""
        echo "const $tag_cap = () => ("
        echo "  <motion.$tag"
        echo "    className=\"$classes\""
        echo "    initial={{ opacity: 0, y: 20 }}"
        echo "    animate={{ opacity: 1, y: 0 }}"
        echo "    whileHover={{ scale: 1.02 }}"
        echo "    transition={{ type: \"spring\", stiffness: 300, damping: 20 }}"
        echo "  >"
        echo "    {/* content */}"
        echo "  </motion.$tag>"
        echo ");"
        echo "\`\`\`"
        echo ""
        echo "## Recommended Next Steps"
        echo ""
        echo "1. **Review** this proposal with your team"
        echo "2. **Choose** an option based on timeline and goals"
        echo "3. **Implement** changes in: \`$component_path\`"
        echo "4. **Test** across different viewports and states"
        echo "5. **Validate** accessibility with screen readers"
        echo ""
        echo "## AI Prompt Suggestions"
        echo ""
        echo "To get specific recommendations, ask:"
        echo "- \"Refine the typography for this $tag element\""
        echo "- \"Add glassmorphism to this element using Tailwind\""
        echo "- \"Suggest accessibility improvements for this $tag\""
        echo "- \"How can I make this more responsive?\""
        echo "- \"What modern design patterns fit this element?\""
        echo ""
        echo "---"
        echo ""
        echo "*Generated by Grabby Tools - Element Redesign Workflow*"
    } > "$OUTPUT_FILE"

    log "Proposal saved to: $OUTPUT_FILE"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ELEMENT REDESIGN COMPLETE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Element: $tag"
    echo "Component: $component_path"
    echo "Options: Minimal / Modern / Complete"
    echo ""
    echo "📄 Proposal: $OUTPUT_FILE"
    echo "📄 Context: $CONTEXT_FILE"
    echo ""

    echo "$OUTPUT_FILE"
}

main "$@"
