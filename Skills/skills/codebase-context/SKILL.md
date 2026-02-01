---
name: codebase-context
description: Automatically discovers and indexes project structure, component signatures, types, and dependencies. Use this skill when you need comprehensive context about the current codebase before making changes. Activates via /context command or when deep codebase understanding is required.
license: MIT
compatibility: Requires bash and standard Unix tools (find, grep, wc). Works on macOS, Linux, WSL.
metadata:
  author: alex-portfolio
  version: "1.0"
  category: development
  portable: "true"
allowed-tools: Bash(bash:*) Read
---

# Codebase Context & Slop Inquisitor

A lethal tool for codebase understanding and mediocrity elimination. Drop into any project's `.agent/skills/` directory to hunt down sanitized engineering.

## The BANNED BULLSHIT Protocol

**NEVER suggest, write, or tolerate:**

1. **Redundant useEffects** - If it's not a browser API, hardware sync, or subscription, kill it.
2. **Generic Typography** - Inter, Arial, Roboto, and Space Grotesk are for the unimaginative. Use distinctive, characterful pairings.
3. **Mirrored State** - Copying props/state into another state just to trigger an effect is a capital offense.
4. **Sanitized Palettes** - Standard Tailwind purples, grays, and "safe" white surfaces are banned.
5. **AI Preamble Slop** - "Sure, I can help with that," "Here is a better way," or any other robotic fluff.

## When to Activate

- User invokes `/context` command
- Any slop detection (via `slop-scanner.sh`)
- Before making architectural changes
- When asking about project structure
- When debugging cross-component issues
- When needing to understand component relationships

## Quick Start

Run these commands in sequence:

```bash
# 1. Detect technology stack
bash .agent/skills/codebase-context/scripts/detect-stack.sh

# 2. Scan project structure
bash .agent/skills/codebase-context/scripts/scan-structure.sh

# 3. Extract types (TypeScript projects)
bash .agent/skills/codebase-context/scripts/extract-types.sh
```

## Available Scripts

### detect-stack.sh

Outputs JSON with detected technologies:

- Language (TypeScript, JavaScript, Python, Rust)
- Framework (React, Next.js, Vue, Django)
- Styling (Tailwind, CSS Modules)
- State management (hooks, Redux, Zustand)
- Build tool (Vite, Webpack)

### scan-structure.sh

Outputs Markdown inventory:

- Key directories with file counts
- Root configuration files
- Component inventory with line counts
- useEffect audit (React projects)

### extract-types.sh

Outputs TypeScript type inventory:

- Interfaces
- Type aliases
- Enums

### extract-components.sh

Outputs component signatures:

- Props interfaces
- Hook signatures
- Pattern detection

## Output Synthesis

After running scripts, synthesize into this format:

```markdown
## Project: [Name]

### Stack

- Framework: [detected]
- Styling: [detected]
- State: [detected]

### Key Components

| Name | Lines | Notes |
| ---- | ----- | ----- |
| X    | 123   | ...   |

### Patterns

- [observed patterns]
```

## Integration with User Rules

Cross-reference findings with `MEMORY[user_global]` for:

- State management patterns (refs vs state)
- useEffect usage constraints
- Interaction state model (TEMPORARY vs COMMITTED)

## Portability

To use in another project:

```bash
cp -r .agent/skills/codebase-context /new-project/.agent/skills/
```

See [REFERENCE.md](references/REFERENCE.md) for technical details.
