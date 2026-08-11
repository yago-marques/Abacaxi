# Agent Instructions

## After writing or editing Swift code

Run `Scripts/on-write-code-check.sh <file>` (or with no argument to lint everything) before considering the change done. It runs SwiftLint across all modules and, once `.claude/CODE_STYLE.md` has content, prints it so you can self-check the code you just wrote against it.

In Claude Code this runs automatically (`.claude/settings.json` PostToolUse hook on `Write`/`Edit`). In Codex or any other agent without an equivalent hook, run it yourself as a standing habit after touching `.swift` files.
