#!/bin/bash

# ============================================
# Workflow Runner
# Usage: ./run-workflow.sh <workflow-name>
# ============================================

WORKFLOW_NAME=$1
WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_SCRIPT="$WORKFLOW_DIR/$WORKFLOW_NAME.sh"

if [[ -z "$WORKFLOW_NAME" ]]; then
    echo "Usage: $0 <workflow-name>"
    echo ""
    echo "Available workflows:"
    ls -1 "$WORKFLOW_DIR"/*.sh 2>/dev/null | grep -v "run-workflow.sh" | xargs -n1 basename | sed 's/.sh$//' | sed 's/^/  - /'
    exit 1
fi

if [[ ! -f "$WORKFLOW_SCRIPT" ]]; then
    echo "❌ Workflow not found: $WORKFLOW_NAME"
    echo ""
    echo "Available workflows:"
    ls -1 "$WORKFLOW_DIR"/*.sh 2>/dev/null | grep -v "run-workflow.sh" | xargs -n1 basename | sed 's/.sh$//' | sed 's/^/  - /'
    exit 1
fi

echo "🚀 Executing workflow: $WORKFLOW_NAME"
echo ""

bash "$WORKFLOW_SCRIPT" "$@"
