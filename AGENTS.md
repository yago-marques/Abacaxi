# Agent Instructions

## After writing or editing Swift code

Run `Scripts/on-write-code-check.sh <file>` (or with no argument to run `AllTests`) before considering the change done. It runs SwiftLint across all modules, executes the affected module's iOS unit-test target (or the aggregate scheme with no argument), and prints `.claude/CODE_STYLE.md` for self-checking.

In Claude Code this runs automatically (`.claude/settings.json` PostToolUse hook on `Write`/`Edit`). In Codex or any other agent without an equivalent hook, run it yourself as a standing habit after touching `.swift` files.
