---
name: cli-unicode-encoding
description: Prevent and diagnose CLI Unicode, non-ASCII, mojibake, locale, code page, path, filename, SSH, and legacy encoding problems. Automatically use before running shell commands, Git commands, Python/Node subprocesses, file reads/writes/searches, SSH/scp/sftp/rsync transfers, or cross-shell operations that may touch CJK, accented, Cyrillic, Arabic, emoji, non-English paths, spaces/brackets/globs, or legacy text files; also use after garbled text, question marks, escaped Git filenames, failed Unicode searches, or broken remote command output.
---

# CLI Unicode Encoding

Use `AGENT_SKILL.md` in this skill folder as the authority. Keep context small: load `references/troubleshooting.md` only for commands, SSH checks, symptom mapping, or path examples; load `references/legacy-encodings.md` only when UTF-8 does not explain the failure.

## Codex-specific rules

- Prefer PowerShell-native commands and `-LiteralPath` on Windows.
- Avoid `cmd /c` handoffs for path-sensitive work.
- Classify fixes as S0/S1/S2/S3; S2 and S3 require explicit user approval.
- Before risky Unicode operations, guard terminal, shell, runtime, file encoding, SSH/remote locale, and path transport; if failure already occurred, diagnose those before changing source code.
