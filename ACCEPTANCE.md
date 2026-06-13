# Acceptance Notes

This document explains what the CLI Unicode Encoding skill is expected to prevent, diagnose, and not guarantee.

## Acceptance Position

The skill is accepted if it helps an agent avoid common Unicode corruption before running risky CLI/SSH/file/path operations, and gives a short diagnostic path when prevention is not enough.

It does not claim to solve every Unicode problem on every AI, OS, shell, terminal, SSH server, filesystem, or legacy tool. It is a prevention and triage guardrail, not a universal transcoder.

## Expected Token Behavior

Default load:

- `AGENT_SKILL.md`: about 740 tokens.
- Codex adapter: about 311 tokens.
- Claude Code adapter: about 203 tokens.
- Cursor adapter: about 216 tokens.

Progressive disclosure:

- Load `references/troubleshooting.md` only for command examples, SSH checks, symptom mapping, or path examples.
- Load `references/legacy-encodings.md` only when UTF-8 does not explain a file/tool failure.
- Run scripts instead of pasting long diagnostic commands when available.

Acceptance: common prevention should usually require the adapter plus `AGENT_SKILL.md`, not every reference file.

## Problem-by-Problem Acceptance Matrix

| Problem | Expected result | Coverage | Evidence |
| --- | --- | --- | --- |
| Agent is about to run a command with non-ASCII text | Agent should guard text boundaries before the real command | Prevents many failures | `AGENT_SKILL.md` rules 1 and 3 |
| Windows PowerShell pipe uses ASCII while console is UTF-8 | Agent should detect `$OutputEncoding` and try session-only UTF-8 | Prevents/diagnoses | `diagnose-windows-powershell.ps1`, `windows-session-utf8.ps1` |
| Windows PowerShell 5.1 misreads UTF-8 `.ps1` literals | Scripts should avoid non-ASCII literals | Prevents in bundled scripts | Windows scripts are ASCII-only and generate Unicode by code point |
| Git escapes non-ASCII filenames | Agent should suggest `core.quotepath false` only as S2 | Diagnoses/prevents display issue | `references/troubleshooting.md` symptom mapping |
| Python stdio is GBK/CP936 on Windows | Agent should detect runtime default before blaming app code | Diagnoses/prevents | Windows diagnostic script prints Python stdout/preferred encodings |
| ripgrep misses text in legacy files | Agent should try explicit `--encoding` | Diagnoses | `references/troubleshooting.md`, `references/legacy-encodings.md` |
| File is GBK, Big5, Shift_JIS, CP949, Windows-125x, or UTF-16LE | Agent should decode explicitly and avoid blind conversion | Diagnoses/prevents data damage | `references/legacy-encodings.md` |
| Non-English path with spaces/brackets/globs fails | Agent should use literal paths and argument arrays | Prevents many failures | `AGENT_SKILL.md` rules 6; troubleshooting path examples |
| Agent builds shell strings with user paths | Agent should avoid shell strings where arrays are available | Prevents many failures | `AGENT_SKILL.md` rule 6 |
| PowerShell-to-`cmd /c` path handoff corrupts or misquotes text | Agent should avoid the handoff for path-sensitive work | Prevents many failures | `AGENT_SKILL.md` rules 1 and 6 |
| SSH command includes Unicode text | Agent should check local shell/client and remote locale first | Prevents/diagnoses | `AGENT_SKILL.md` rule 5; SSH boundary reference |
| SSH does not forward `LANG`/`LC_*` | Agent should not assume forwarding and should test remote locale | Prevents/diagnoses | `AGENT_SKILL.md` rule 5; troubleshooting SSH checks |
| Complex SSH command has nested quotes and Unicode paths | Agent should prefer stdin script transfer | Prevents many failures | `references/troubleshooting.md` SSH boundary |
| `scp` wildcard/glob with Unicode path fails | Agent should prefer SFTP-mode transfer and avoid legacy remote shell globbing | Prevents many failures | `references/troubleshooting.md` SSH file transfer notes |
| Inline Python/Node script embeds a non-ASCII path and is piped through the shell | Agent should write a temporary script and pass paths as arguments or a UTF-8 argument file | Prevents many failures | `AGENT_SKILL.md` rule 6; troubleshooting inline script examples |
| Terminal displays boxes | Agent should check font coverage, not only encoding | Diagnoses | `references/troubleshooting.md` symptom mapping |
| Remote filenames are already mojibake | Agent should classify rename/transcode as S3 | Avoids unsafe fix | `AGENT_SKILL.md` rules 2 and 5 |
| User asks for permanent environment changes | Agent should ask first for S2/S3 | Prevents unsafe persistence | `AGENT_SKILL.md` rule 2 |
| Project source files need encoding conversion | Agent should ask first and require backup/tests | Prevents data loss | `AGENT_SKILL.md` rule 2 and 4 |

## What It Can Solve Well

- Most agent-caused CLI Unicode mistakes caused by wrong shell defaults, pipes, path quoting, subprocess strings, or premature global fixes.
- Many Windows-first Unicode problems involving PowerShell, Python, Git, ripgrep, and non-English paths.
- Many SSH Unicode failures when the issue is local/remote locale mismatch, quoting, or transfer mode.
- Many legacy-file read/search failures when the file is not UTF-8 but has a known regional encoding.

## What It Can Only Diagnose

- Terminal font glyph gaps.
- Tools that only support a legacy local code page.
- Remote servers where the user cannot change locale or SSH server configuration.
- Files that were already irreversibly corrupted by a previous wrong decode/encode cycle.
- Application protocols, databases, archives, Office documents, or APIs with their own internal encoding bugs.

## What It Cannot Guarantee

- Universal behavior across every AI agent or every old shell/tool version.
- Correct recovery of text after data has already been lossy-converted to `????`.
- Safe automatic conversion of unknown project files.
- That SSH will forward locale variables; server-side config may block it.
- That a terminal can display every Unicode glyph; font coverage still matters.

## Acceptance Checks

Automated/local checks:

1. Codex adapter validates with the skill validator.
2. Windows diagnostic script runs without persistent changes.
3. Windows session UTF-8 script changes only the current PowerShell process.
4. Windows scripts contain no non-ASCII string literals, so Windows PowerShell 5.1 can read them safely.
5. Repository self-check script passes.

Static checks:

1. `AGENT_SKILL.md` contains prevention-first rules, not only reactive debugging.
2. `AGENT_SKILL.md` contains S0/S1/S2/S3 fix classification.
3. `references/troubleshooting.md` contains Windows, macOS/Linux, SSH, file encoding, and path examples.
4. `references/legacy-encodings.md` covers common regional legacy encodings.
5. Adapters are thin and point back to `AGENT_SKILL.md`.

Manual/external checks:

1. Test SSH against at least one UTF-8 Linux host.
2. Test SSH against a host with `C`/`POSIX` locale if available.
3. Test SFTP or modern SFTP-mode `scp` with a non-English filename.
4. Test `rg --encoding` against one known GBK or Shift_JIS sample file.

## Acceptance Decision

Accepted with explicit limits:

- Accepted as a compact prevention-first guardrail for agents.
- Accepted as complete for common CLI, path, file, Git, Python, ripgrep, and SSH Unicode boundaries.
- Not accepted as a promise to fix every possible Unicode problem or recover already-lost text.

## Current Validation Result

Validated locally on Windows:

- Codex adapter validation: passed.
- `scripts/diagnose-windows-powershell.ps1`: passed; reports PowerShell, console, Git, Python, and Unicode smoke test without persistent changes.
- `scripts/windows-session-utf8.ps1`: passed; changes only current-session encodings and prints a Unicode smoke test.
- Windows PowerShell scripts are ASCII-only: passed.
- `scripts/check-repo.ps1`: passed.

Measured current approximate token sizes:

- `AGENT_SKILL.md`: about 740 tokens.
- `references/troubleshooting.md`: about 1156 tokens.
- `references/legacy-encodings.md`: about 464 tokens.
- Codex adapter: about 311 tokens.
- Claude Code adapter: about 203 tokens.
- Cursor adapter: about 216 tokens.

Not validated in this local run:

- Real SSH server locale behavior.
- SFTP/SCP transfer with Unicode filenames.
- Real GBK/Shift_JIS/CP949 sample file search.
- macOS/Linux runtime execution of `scripts/diagnose-posix.sh`.
