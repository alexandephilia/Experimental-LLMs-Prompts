#!/bin/bash
set -e

# ============================================
# GRABBY AWARE WORKFLOW
# Main entry point - auto-detects .grabbed_element
# Generates context and shows available actions
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib/common.sh"
source "$SCRIPT_DIR/_lib/grabby-context.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

ELEMENT_FILE=".grabbed_element"
OUTPUT_DIR=".workflow_output"
CONTEXT_FILE="$OUTPUT_DIR/grabby-context.md"

ensure_dir "$OUTPUT_DIR"

is_recently_grabbed() {
    local max_age_seconds="${1:-300}"
    if [[ ! -f "$ELEMENT_FILE" ]]; then
        return 1
    fi
    local file_age=$(($(date +%s) - $(stat -f %m "$ELEMENT_FILE" 2>/dev/null || stat -c %Y "$ELEMENT_FILE")))
    [[ $file_age -lt $max_age_seconds ]]
}

main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║     GRABBY TOOLS - WORKFLOW RUNNER   ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    if [[ ! -f "$ELEMENT_FILE" ]]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  NO ELEMENT GRABBED"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Add ?grab=true to your URL and:"
        echo "  1. Hold Cmd/Ctrl and hover over elements"
        echo "  2. Click to capture"
        echo ""
        echo "Available workflows:"
        echo "  • bash Skills/workflows/accessibility-audit.sh"
        echo "  • bash Skills/workflows/component-extract.sh"
        echo "  • bash Skills/workflows/style-refactor.sh"
        echo "  • bash Skills/workflows/element-redesign.sh"
        echo ""
        exit 0
    fi

    if ! is_recently_grabbed 300; then
        warn "Element was grabbed more than 5 minutes ago"
    fi

    log "Generating Grabby context..."
    generate_grabby_context "$ELEMENT_FILE" > "$CONTEXT_FILE"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ELEMENT CAPTURED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    format_grabbed_element "$ELEMENT_FILE"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  AVAILABLE WORKFLOWS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Run a workflow:"
    echo ""
    echo "  1️⃣  bash Skills/workflows/accessibility-audit.sh"
    echo "      Check WCAG compliance and accessibility"
    echo ""
    echo "  2️⃣  bash Skills/workflows/component-extract.sh"
    echo "      Extract to reusable React/Vue component"
    echo ""
    echo "  3️⃣  bash Skills/workflows/style-refactor.sh"
    echo "      Convert inline styles to Tailwind"
    echo ""
    echo "  4️⃣  bash Skills/workflows/element-redesign.sh"
    echo "      Analyze and propose design improvements"
    echo ""
    echo "Or pass a workflow name:"
    echo "  bash Skills/workflows/run-workflow.sh accessibility-audit"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    log "Context saved to: $CONTEXT_FILE"
    echo ""
    echo "📄 Context: $CONTEXT_FILE"
    echo ""
}

main "$@"
