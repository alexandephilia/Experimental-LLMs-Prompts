# Technical Reference

## How Context Discovery Works

This skill uses a three-phase approach to understand codebases:

### Phase 1: Stack Detection

Reads manifest files (`package.json`, `pyproject.toml`, `Cargo.toml`) to identify:

- Primary language (TypeScript, JavaScript, Python, Rust)
- Framework (React, Next.js, Vue, Django, FastAPI)
- Build tools (Vite, Webpack, Cargo)
- Styling approach (Tailwind, CSS Modules, Sass)
- State management pattern (hooks, Redux, Zustand)
- Package manager/runtime (npm, bun, pnpm, yarn)

### Phase 2: Structure Scanning

Uses `find` and `grep` to map:

- Key directories with file counts
- Root configuration files
- Component inventory with metadata
- useEffect audit (React projects)

### Phase 3: Type/Pattern Extraction

For TypeScript projects:

- Interfaces and type aliases
- Enums and constants
- Component props signatures
- Hook signatures

---

## Script Execution

All scripts navigate to project root using:

```bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"
```

This assumes the skill is installed at `.agent/skills/codebase-context/`.

---

## Output Formats

### detect-stack.sh

Outputs JSON:

```json
{
  "project_root": "/path/to/project",
  "stack": {
    "language": "typescript",
    "framework": "react",
    ...
  },
  "metrics": { ... },
  "detected_files": { ... }
}
```

### scan-structure.sh

Outputs Markdown with:

- Directory listing with file counts
- Root files with line counts
- Component inventory table
- useEffect audit table

### extract-components.sh / extract-types.sh

Output Markdown with component/type inventories.

---

## Dependencies

**Required (universally available):**

- `bash` (POSIX-compatible shell)
- `find`, `grep`, `wc`, `tr`, `sort`, `head`
- `cat`, `basename`, `dirname`

**Optional (enhanced output):**

- `rg` (ripgrep) - faster grep, used if available
- `jq` - JSON processing
- `fd` - faster find, used if available

---

## Extending the Skill

To add new scanners:

1. Create script in `scripts/` directory
2. Follow the path navigation pattern
3. Output structured text (JSON or Markdown)
4. Handle missing files gracefully:
   ```bash
   if [ -f "somefile" ]; then
       # process
   else
       echo "Note: somefile not found"
   fi
   ```
5. Reference from SKILL.md body

---

## Known Limitations

1. **AST Parsing**: Scripts use regex/grep, not proper AST parsing
2. **Monorepos**: Assumes single-root project structure
3. **Large Projects**: Output is capped to prevent token overflow
4. **Binary Files**: Not analyzed
