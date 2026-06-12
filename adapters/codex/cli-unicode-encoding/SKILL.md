---
name: cli-unicode-encoding
description: Prevent and diagnose command-line Unicode, non-ASCII, mojibake, path, filename, locale, SSH, code page, and legacy encoding problems across Windows, macOS, Linux, PowerShell, Git, Python, Node-style CLIs, ripgrep, and agent shell usage. Use before commands may touch CJK/accented/Cyrillic/Arabic/emoji text, non-English paths, SSH transfers, legacy files, or cross-shell text; also use when garbled text, question marks, escaped Git filenames, or failed Unicode searches already occurred.
---

# CLI Unicode Encoding

Use the repository root `AGENT_SKILL.md` as the authority. Keep context small: load `references/troubleshooting.md` only for commands, SSH checks, symptom mapping, or path examples; load `references/legacy-encodings.md` only when UTF-8 does not explain the failure.

## Codex-specific rules

- Prefer PowerShell-native commands and `-LiteralPath` on Windows.
- Avoid `cmd /c` handoffs for path-sensitive work.
- Classify fixes as S0/S1/S2/S3; S2 and S3 require explicit user approval.
- Before risky Unicode operations, guard terminal, shell, runtime, file encoding, SSH/remote locale, and path transport; if failure already occurred, diagnose those before changing source code.
