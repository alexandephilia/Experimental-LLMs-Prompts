# Codebase Context Skill

A portable, project-agnostic skill for discovering and indexing codebase structure. Drop this folder into any project's `.agent/skills/` directory to give Claude comprehensive project context.

## Quick Start

```bash
# Copy to a new project
cp -r .agent/skills/codebase-context /path/to/new-project/.agent/skills/

# Run stack detection
bash .agent/skills/codebase-context/scripts/detect-stack.sh

# Run structure scan
bash .agent/skills/codebase-context/scripts/scan-structure.sh
```

## What This Skill Does

1. **Stack Detection** (`detect-stack.sh`)

   - Identifies language (TypeScript, JavaScript, Python, Rust)
   - Detects framework (React, Next.js, Vue, Django, etc.)
   - Finds styling approach (Tailwind, CSS Modules, etc.)
   - Identifies state management pattern
   - Outputs structured JSON

2. **Structure Scan** (`scan-structure.sh`)

   - Maps key directories with file counts
   - Lists root configuration files
   - Creates component inventory with line counts
   - Audits useEffect usage (critical for React projects)

3. **Component Extraction** (`extract-components.sh`)

   - Extracts component signatures and props
   - Lists custom hooks
   - Identifies common patterns

4. **Type Extraction** (`extract-types.sh`)
   - Inventories TypeScript interfaces
   - Lists type aliases
   - Catalogs enums

## Directory Structure

```
codebase-context/
├── SKILL.md           # Anthropic-compatible skill definition
├── README.md          # This file
├── scripts/
│   ├── detect-stack.sh
│   ├── scan-structure.sh
│   ├── extract-components.sh
│   └── extract-types.sh
└── templates/         # (future) Output templates
```

## Portability Requirements

- **No external tools required** - Uses only `bash`, `find`, `grep`, `wc`
- **Optional tools for enhanced output**: `rg` (ripgrep), `fd`, `jq`
- **POSIX-compatible** - Works on macOS, Linux, WSL
- **Relative paths only** - No hardcoded project paths
- **Zero dependencies** - No npm/pip packages required

## Integration with Claude

Claude can reference this skill when:

- User invokes `/context` command
- Deep codebase understanding is needed
- Before making architectural changes
- Debugging cross-component issues

The SKILL.md file follows Anthropic's Agent Skills specification and will be automatically discovered by supporting tools.

## Extending This Skill

Add new scripts to `scripts/` directory following the pattern:

1. Use POSIX-compatible bash
2. Navigate to project root using: `cd "$(dirname "$0")/../../../.."`
3. Output structured text (Markdown or JSON)
4. Handle missing files/directories gracefully

## License

MIT - Free to use and modify
