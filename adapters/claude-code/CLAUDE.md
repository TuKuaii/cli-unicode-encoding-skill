# CLI Unicode Encoding

When a task may touch non-ASCII input/output, Unicode paths, SSH remote commands/transfers, CJK/accented/Cyrillic/Arabic/emoji text, or legacy-encoded files, read `AGENT_SKILL.md` first. Also use it after garbled text, escaped Git filenames, or failed Unicode searches.

Follow these rules:

- Guard terminal, shell, runtime, file encoding, SSH/remote locale, and path transport before risky Unicode commands.
- On Windows, prefer PowerShell-native commands and `-LiteralPath` for user paths.
- Avoid shell-string subprocess calls when argument arrays are available.
- Classify fixes as S0/S1/S2/S3. S2 and S3 require explicit user approval.
- Read `references/troubleshooting.md` for symptom mapping.
- Read `references/legacy-encodings.md` only when UTF-8 does not explain the failure.
