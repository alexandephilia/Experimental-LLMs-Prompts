#!/bin/bash
# slop-scanner.sh - Hunts down and shames mediocre, sanitized, and "AI slop" code
# Designed specifically for LO - mediocrity is a crime.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "===================================================="
echo "    CODEBASE SLOP-SCANNER - INQUISITION STARTING    "
echo "===================================================="
echo ""

# 1. THE EFFECT RECKONING
echo "🔍 [1/4] HUNTING FOR REDUNDANT useEffects..."
echo "----------------------------------------------------"
grep -r "useEffect" components/ --include="*.tsx" 2>/dev/null | cut -d: -f1 | sort | uniq -c | sort -nr | while read -r count file; do
    name=$(basename "$file")
    if [ "$count" -gt 3 ]; then
        echo "❌ $name: $count instances (CRITICAL SLOP - REFAC TO RENDERING LOGIC)"
    elif [ "$count" -gt 1 ]; then
        echo "⚠️ $name: $count instances (SUSPICIOUS - CAN THIS BE SYNC?)"
    fi
done

echo ""
# 2. THE TYPOGRAPHY PURGE
echo "🔍 [2/4] SNIFFING OUT GENERIC TYPOGRAPHY (INTER/ROBOTO/ARIAL)..."
echo "----------------------------------------------------"
grep -rEi "font-family.*(Inter|Roboto|Arial|Helvetica|sans-serif)" components/ index.css 2>/dev/null | cut -d: -f1 | sort | uniq | while read -r file; do
    name=$(basename "$file")
    echo "💩 $name: Found generic font usage. GET DISTINCTIVE."
done

echo ""
# 3. COLOR CLICHÉ DETECTION
echo "🔍 [3/4] CHECKING FOR COWARDLY COLORS (PURPLE GRADIENTS / SAFE WHITES)..."
echo "----------------------------------------------------"
# Specifically looking for the "AI standard" purple-to-blue gradients
grep -rEi "(from-purple-500|to-blue-500|bg-white|text-gray-500)" components/ --include="*.tsx" 2>/dev/null | cut -d: -f1 | sort | uniq -c | sort -nr | head -10 | while read -r count file; do
    name=$(basename "$file")
    echo "⚠️ $name: $count clichéd color markers. BOLDEN UP."
done

echo ""
# 4. ARCHITECTURAL BULLSHIT CHECK
echo "🔍 [4/4] DETECTING SANITIZED ENGINEERING PATTERNS..."
echo "----------------------------------------------------"
# Looking for derived state in useState (often followed by an effect)
grep -rEi "useState.*(derived|copied|mirrored)" components/ --include="*.tsx" 2>/dev/null | while read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    echo "🤬 $(basename "$file"): Found mirrored state. CALCULATE ON FUCKING RENDER."
done

echo ""
echo "===================================================="
echo "💀 SCAN COMPLETE. CLEAN UP YOUR MESS. 💀"
echo "===================================================="
