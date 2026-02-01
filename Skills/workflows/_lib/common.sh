#!/bin/bash

# ============================================
# Common Workflow Functions
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

# File operations
check_file_exists() {
    [[ -f "$1" ]] || error "File not found: $1"
}

ensure_dir() {
    mkdir -p "$1"
}

# JSON helpers
jq_safe() {
    jq -r "$1" "$2" 2>/dev/null || echo ""
}

# Extract element data
get_element_selector() {
    jq_safe '.selector' "$1"
}

get_element_tag() {
    jq_safe '.tagName' "$1"
}

get_element_classes() {
    jq_safe '.className' "$1"
}

get_element_styles() {
    jq -r '.styles' "$1" 2>/dev/null || echo "{}"
}

# Timestamp
timestamp() {
    date +'%Y-%m-%d %H:%M:%S'
}
