#!/bin/bash
# detect-stack.sh - Detects project technology stack
# Outputs JSON with detected technologies
# Universal: uses only standard tools (no fd dependency)

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

# Initialize detection results
FRAMEWORK="unknown"
STYLING="unknown"
STATE="unknown"
BUILD="unknown"
LANGUAGE="unknown"
RUNTIME="unknown"

# Detect from package.json
if [ -f "package.json" ]; then
    LANGUAGE="javascript"
    
    # Check for TypeScript
    if grep -q '"typescript"' package.json 2>/dev/null || [ -f "tsconfig.json" ]; then
        LANGUAGE="typescript"
    fi
    
    # Detect framework
    if grep -q '"next"' package.json 2>/dev/null; then
        FRAMEWORK="nextjs"
    elif grep -q '"react"' package.json 2>/dev/null; then
        FRAMEWORK="react"
    elif grep -q '"vue"' package.json 2>/dev/null; then
        FRAMEWORK="vue"
    elif grep -q '"svelte"' package.json 2>/dev/null; then
        FRAMEWORK="svelte"
    elif grep -q '"@angular/core"' package.json 2>/dev/null; then
        FRAMEWORK="angular"
    fi
    
    # Detect build tool
    if grep -q '"vite"' package.json 2>/dev/null; then
        BUILD="vite"
    elif grep -q '"webpack"' package.json 2>/dev/null; then
        BUILD="webpack"
    elif grep -q '"parcel"' package.json 2>/dev/null; then
        BUILD="parcel"
    elif grep -q '"esbuild"' package.json 2>/dev/null; then
        BUILD="esbuild"
    fi
    
    # Detect styling
    if grep -q '"tailwindcss"' package.json 2>/dev/null; then
        STYLING="tailwind"
    elif grep -q '"styled-components"' package.json 2>/dev/null; then
        STYLING="styled-components"
    elif grep -q '"@emotion"' package.json 2>/dev/null; then
        STYLING="emotion"
    elif grep -q '"sass"' package.json 2>/dev/null; then
        STYLING="sass"
    else
        STYLING="css"
    fi
    
    # Detect state management
    if grep -q '"zustand"' package.json 2>/dev/null; then
        STATE="zustand"
    elif grep -q '"@reduxjs/toolkit"' package.json 2>/dev/null || grep -q '"redux"' package.json 2>/dev/null; then
        STATE="redux"
    elif grep -q '"mobx"' package.json 2>/dev/null; then
        STATE="mobx"
    elif grep -q '"jotai"' package.json 2>/dev/null; then
        STATE="jotai"
    elif grep -q '"recoil"' package.json 2>/dev/null; then
        STATE="recoil"
    else
        STATE="hooks"
    fi
    
    # Detect runtime
    if [ -f "bun.lockb" ]; then
        RUNTIME="bun"
    elif [ -f "pnpm-lock.yaml" ]; then
        RUNTIME="pnpm"
    elif [ -f "yarn.lock" ]; then
        RUNTIME="yarn"
    else
        RUNTIME="npm"
    fi
fi

# Detect from pyproject.toml (Python projects)
if [ -f "pyproject.toml" ]; then
    LANGUAGE="python"
    if grep -q 'django' pyproject.toml 2>/dev/null; then
        FRAMEWORK="django"
    elif grep -q 'fastapi' pyproject.toml 2>/dev/null; then
        FRAMEWORK="fastapi"
    elif grep -q 'flask' pyproject.toml 2>/dev/null; then
        FRAMEWORK="flask"
    fi
    BUILD="python"
    STATE="n/a"
    STYLING="n/a"
fi

# Detect from Cargo.toml (Rust projects)
if [ -f "Cargo.toml" ]; then
    LANGUAGE="rust"
    if grep -q 'axum' Cargo.toml 2>/dev/null; then
        FRAMEWORK="axum"
    elif grep -q 'actix' Cargo.toml 2>/dev/null; then
        FRAMEWORK="actix"
    fi
    BUILD="cargo"
    STATE="n/a"
    STYLING="n/a"
fi

# Count components using find
COMPONENT_COUNT=0
if [ -d "components" ]; then
    COMPONENT_COUNT=$(find components/ -name "*.tsx" -o -name "*.jsx" 2>/dev/null | wc -l | tr -d ' ')
fi

# Check for tailwind config
HAS_TAILWIND="false"
if [ -f "tailwind.config.js" ] || [ -f "tailwind.config.ts" ]; then
    HAS_TAILWIND="true"
fi

# Check for vite config
HAS_VITE="false"
if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
    HAS_VITE="true"
fi

# Output JSON
cat << EOF
{
  "project_root": "$PROJECT_ROOT",
  "stack": {
    "language": "$LANGUAGE",
    "framework": "$FRAMEWORK",
    "styling": "$STYLING",
    "state_management": "$STATE",
    "build_tool": "$BUILD",
    "runtime": "$RUNTIME"
  },
  "metrics": {
    "component_count": $COMPONENT_COUNT
  },
  "detected_files": {
    "package_json": $([ -f "package.json" ] && echo "true" || echo "false"),
    "tsconfig": $([ -f "tsconfig.json" ] && echo "true" || echo "false"),
    "tailwind_config": $HAS_TAILWIND,
    "vite_config": $HAS_VITE
  }
}
EOF
