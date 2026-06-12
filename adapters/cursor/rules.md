# CLI Unicode Encoding Rule

Use this rule before commands may touch Unicode or non-ASCII text, including CJK, accents, Cyrillic, Arabic, Thai, emoji, non-English paths, SSH remote commands or transfers, and legacy-encoded files. Also use it after mojibake, escaped Git filenames, or missing Unicode search results.

Read `AGENT_SKILL.md` before changing code. If more detail is needed, read:

- `references/troubleshooting.md`
- `references/legacy-encodings.md`

Rules:

- Guard text boundaries first: terminal, shell, runtime, file encoding, path transport.
- On Windows PowerShell, use `-LiteralPath` for user paths.
- Use explicit file encodings.
- Avoid shell strings for subprocesses when argument arrays are available.
- Treat SSH as local shell/client plus remote shell/locale.
- Classify fixes as S0/S1/S2/S3. S2 and S3 require explicit user approval.
