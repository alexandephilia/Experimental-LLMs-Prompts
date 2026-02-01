#!/bin/bash
set -e

# ============================================
# ACCESSIBILITY AUDIT WORKFLOW
# Checks grabbed element for a11y issues
# Auto-detects .grabbed_element if not provided
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib/common.sh"

ELEMENT_FILE="${1:-.grabbed_element}"
OUTPUT_DIR=".workflow_output"
OUTPUT_FILE="$OUTPUT_DIR/accessibility-audit.md"
CONTEXT_FILE="$OUTPUT_DIR/grabby-context.md"

ensure_dir "$OUTPUT_DIR"

# Auto-detect element if not provided as argument
if [[ ! -f "$ELEMENT_FILE" ]]; then
    error "No grabbed element found. Add ?grab=true to URL and grab an element first."
fi

# Check if element is fresh (within 5 minutes)
is_recently_grabbed() {
    local max_age_seconds="${1:-300}"
    if [[ ! -f "$ELEMENT_FILE" ]]; then
        return 1
    fi
    local file_age=$(($(date +%s) - $(stat -f %m "$ELEMENT_FILE" 2>/dev/null || stat -c %Y "$ELEMENT_FILE")))
    [[ $file_age -lt $max_age_seconds ]]
}

# Generate grabby-context.md
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
**Source**: accessibility-audit.sh

## Element

- **Tag**: \`$tag\`
- **Selector**: \`$selector\`
- **Classes**: \`$classes\`
- **Dimensions**: ${width}x${height}px

**Text**: "$text"

## Workflow

**Accessibility Audit** - Checking element for WCAG compliance issues.

EOF
    log "Context generated: $CONTEXT_FILE"
}

check_accessibility() {
    local element_file="$1"
    local issues=()

    local tag=$(jq -r '.tagName' "$element_file")
    local attributes=$(jq -r '.attributes' "$element_file")
    local inner_text=$(jq -r '.innerText' "$element_file")

    if [[ "$tag" == "IMG" ]]; then
        local alt=$(echo "$attributes" | jq -r '.alt // empty')
        [[ -z "$alt" ]] && issues+=("❌ Missing alt attribute")
    fi

    if [[ "$tag" == "BUTTON" || "$tag" == "A" ]]; then
        [[ -z "$inner_text" ]] && issues+=("❌ No visible text (needs aria-label)")
    fi

    if [[ ${#issues[@]} -eq 0 ]]; then
        echo "✅ No obvious accessibility issues found"
    else
        printf '%s\n' "${issues[@]}"
    fi
}

main() {
    log "Accessibility Audit Workflow started"

    if ! is_recently_grabbed 300; then
        warn "Element was grabbed more than 5 minutes ago"
        info "Consider grabbing a fresh element"
    fi

    generate_grabby_context

    local selector=$(get_element_selector "$ELEMENT_FILE")
    local tag=$(get_element_tag "$ELEMENT_FILE")

    log "Auditing: $tag ($selector)"

    local issues=$(check_accessibility "$ELEMENT_FILE")

    local tag_recommendations
    case "$tag" in
        "BUTTON")
            tag_recommendations="- Ensure button has visible text or aria-label
- Add aria-pressed for toggle buttons
- Add aria-expanded for dropdown triggers"
            ;;
        "A")
            tag_recommendations="- Ensure link text is descriptive
- Avoid 'click here' or 'read more'
- Add aria-current for current page"
            ;;
        "IMG")
            tag_recommendations="- Add descriptive alt text
- Use alt='' for decorative images
- Consider aria-describedby for complex images"
            ;;
        "INPUT")
            tag_recommendations="- Associate with <label> element
- Add aria-required for required fields
- Add aria-invalid for error states"
            ;;
        *)
            tag_recommendations="- Review ARIA authoring practices for $tag"
            ;;
    esac

    cat > "$OUTPUT_FILE" <<EOF
# Accessibility Audit

**Generated**: $(timestamp)

## Element

- **Tag**: \`$tag\`
- **Selector**: \`$selector\`

## Audit Results

$issues

## Accessibility Checklist

### Semantic HTML
- [ ] Using appropriate semantic tag
- [ ] Proper heading hierarchy (if applicable)
- [ ] Form labels associated with inputs

### Keyboard Navigation
- [ ] Focusable with Tab key
- [ ] Visible focus indicator
- [ ] Operable with keyboard only

### Screen Readers
- [ ] Has accessible name (text, aria-label, or aria-labelledby)
- [ ] Role is appropriate
- [ ] State changes announced (aria-live if needed)

### Visual
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Not relying on color alone
- [ ] Text is resizable
- [ ] Touch targets are at least 44x44px

### ARIA Attributes

Current attributes:
\`\`\`json
$(jq '.attributes' "$ELEMENT_FILE")
\`\`\`

## Recommended Improvements

### For $tag elements:

$tag_recommendations

## Testing Tools

- **axe DevTools**: Browser extension for automated testing
- **NVDA/JAWS**: Screen reader testing (Windows)
- **VoiceOver**: Screen reader testing (macOS/iOS)
- **Keyboard only**: Navigate without mouse
- **Color contrast checker**: WebAIM Contrast Checker

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM Articles](https://webaim.org/articles/)

---

*Generated by Grabby Tools - Accessibility Audit Workflow*
EOF

    log "Audit saved to: $OUTPUT_FILE"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ACCESSIBILITY AUDIT COMPLETE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Element: $tag"
    echo "Issues: $issues"
    echo ""
    echo "📄 Audit: $OUTPUT_FILE"
    echo "📄 Context: $CONTEXT_FILE"
    echo ""

    echo "$OUTPUT_FILE"
}

main "$@"
