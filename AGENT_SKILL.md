# CLI Unicode Encoding

Use before CLI, SSH, file, subprocess, or path work may touch Unicode/non-ASCII text: CJK, accents, Cyrillic, Arabic, emoji, non-English paths, legacy files, remote commands, or cross-shell transfers. Prevent mojibake instead of reacting to it.

**Tradeoff:** Bias toward diagnosis and reversible changes over fast global fixes.

## 1. Guard Boundaries First

**Before running risky commands, choose the safest text boundary.**

Check in order:

```text
terminal/font -> shell locale/codepage -> pipe encoding -> runtime defaults -> file encoding -> path quoting -> SSH remote locale -> cross-shell handoff
```

If the boundary is unclear, run inspect-only diagnostics before changing anything.

## 2. Classify Every Fix

**No silent persistent changes.**

- S0 inspect-only: diagnostics, no changes.
- S1 session-only: current shell/process only.
- S2 persistent-user: profile/env/registry/Git global/SSH config; ask first.
- S3 project/data-changing: file conversion, source edits, renames, bulk rewrites; ask first and require backup or tests.

## 3. Prefer Reversible Tests

**Probe first, then run the real command.**

- For risky Unicode operations, run a minimal smoke test before the real command.
- If a command already failed, re-run the exact failing command after each change.
- Try S0/S1 before S2/S3.
- A diagnostic script is not proof; the real command must pass.
- Use bundled scripts only conservatively:
  - `scripts/diagnose-windows-powershell.ps1`: S0 Windows diagnostics.
  - `scripts/windows-session-utf8.ps1`: S1 current PowerShell session UTF-8.
  - `scripts/diagnose-posix.sh`: S0 macOS/Linux diagnostics.

## 4. Do Not Assume UTF-8

**UTF-8 is preferred, not guaranteed.**

Legacy files and tools may use GBK, GB18030, Big5, Shift_JIS/CP932, CP949, Windows-125x, or UTF-16LE. Decode explicitly. Do not bulk-convert unless the user approves and the project has tests or backups.

## 5. Treat SSH as Two Environments

**Local success does not imply remote success.**

Check local shell/client and remote locale separately before sending Unicode-heavy commands. Do not assume SSH forwards `LANG` or `LC_*`. For complex remote commands or Unicode paths, prefer sending a small script over stdin instead of nesting quoted text through multiple shells. Prefer SFTP-mode transfers for complex Unicode paths.

## 6. Keep Paths Literal

**Avoid shell strings for user paths.**

Use argument arrays when available. On Windows PowerShell, use `-LiteralPath`. Avoid PowerShell-to-`cmd /c` handoffs for path-sensitive work. In Python, prefer `pathlib.Path`, explicit `encoding=`, and `subprocess.run([...])`.

## 7. Load Details Only When Needed

**Keep context small.**

- Read `references/troubleshooting.md` for commands, SSH checks, symptom mapping, and path examples.
- Read `references/legacy-encodings.md` only when UTF-8 does not explain a file/tool failure.
- Keep adapter files thin; this file is the authority.
