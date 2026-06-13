# Troubleshooting

## Layer checklist

Check these layers in order:

1. Terminal host: Windows Terminal, VS Code terminal, classic console, macOS Terminal, iTerm2, Linux terminal.
2. Display font: missing glyphs can look like encoding failure.
3. Shell encoding: Windows code page, PowerShell console encodings, Unix locale.
4. Pipe encoding: PowerShell `$OutputEncoding`, process stdin/stdout defaults.
5. Runtime defaults: Python, Node, Java, Git, ripgrep, old native Windows tools.
6. File encoding: UTF-8, UTF-8 BOM, UTF-16LE, GBK, Big5, Shift_JIS, CP949, Windows-125x.
7. Path transport: quoting, wildcard expansion, shell mixing, SSH, WSL/Windows path conversion.

## Symptom mapping

| Symptom | Likely cause | First check |
| --- | --- | --- |
| Output becomes `????` | Data cannot be represented in active output encoding | Code page, locale, stdout encoding |
| Output looks like `Ã¤Â¸...` | UTF-8 bytes decoded as Windows-1252 or similar | Terminal/shell decode layer |
| Git shows `\346\226...` | Git quotes non-ASCII paths | `core.quotepath false` |
| Search misses Unicode text | File is not decoded with the right encoding | `rg --encoding ...` |
| Python prints mojibake | Python stdio is not UTF-8 | `PYTHONUTF8`, `PYTHONIOENCODING` |
| Text file opens as garbage | File uses legacy encoding or UTF-16 | Detect/try specific file encoding |
| Path with non-English text fails | Shell string quoting or wildcard expansion | Argument arrays, `-LiteralPath` |
| Boxes appear instead of letters | Font lacks glyphs | Terminal font coverage |

## Windows PowerShell tests

```powershell
$PSVersionTable.PSVersion
chcp
[Console]::InputEncoding.WebName
[Console]::OutputEncoding.WebName
$OutputEncoding.WebName
```

Session-local UTF-8 baseline:

```powershell
chcp 65001
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
```

Do not persist this until the failing command works in the current session.

## macOS/Linux tests

```bash
locale
locale charmap
printf 'Unicode test: 中文 café русский عربى 😀\n'
python3 -c "import sys, locale; print(sys.stdout.encoding); print(locale.getpreferredencoding(False))"
```

If locale is `C` or `POSIX`, switch to a UTF-8 locale such as `C.UTF-8` or a regional UTF-8 locale.

## File encoding tests

Try explicit reads before converting files:

```powershell
Get-Content -LiteralPath .\file.txt -Encoding utf8
Get-Content -LiteralPath .\file.txt -Encoding ansi
```

Search with explicit encoding:

```powershell
rg "text" --encoding utf-8
rg "关键词" --encoding gbk
rg "検索語" --encoding shift_jis
rg "ключ" --encoding windows-1251
```

Python explicit read:

```python
from pathlib import Path

path = Path("file.txt")
text = path.read_text(encoding="utf-8")
```

## Path handling examples

PowerShell:

```powershell
Get-Content -LiteralPath 'D:\项目\[demo]\café.txt' -Encoding utf8
```

Python:

```python
from pathlib import Path
import subprocess

path = Path(r"D:\项目\[demo]\café.txt")
text = path.read_text(encoding="utf-8")
subprocess.run(["git", "add", str(path)], check=True)
```

Avoid:

```python
subprocess.run(f'git add "{path}"', shell=True)
```

## Inline scripts and pipes

On Windows, piping inline scripts that contain non-ASCII literals or paths can cross a fragile encoding boundary. Avoid this pattern for path-sensitive checks:

```powershell
@'
from pathlib import Path
print(Path(r"D:\项目\[demo]\café.txt").exists())
'@ | python -
```

Prefer a script file plus arguments:

```powershell
$script = Join-Path $env:TEMP 'unicode-check.py'
@'
from pathlib import Path
import sys

print(Path(sys.argv[1]).exists())
'@ | Set-Content -LiteralPath $script -Encoding utf8
python $script 'D:\项目\[demo]\café.txt'
Remove-Item -LiteralPath $script
```

This keeps the path in the process argument boundary instead of embedding it inside script source sent through a pipe.

If even command-line arguments may cross an unsafe shell/locale boundary, pass the path through a UTF-8 argument file:

```powershell
$pathFile = Join-Path $env:TEMP 'unicode-path.txt'
$script = Join-Path $env:TEMP 'unicode-check.py'

Set-Content -LiteralPath $pathFile -Value 'D:\项目\[demo]\café.txt' -Encoding utf8
@'
from pathlib import Path
import sys

path = Path(Path(sys.argv[1]).read_text(encoding="utf-8").strip())
print(path.exists())
'@ | Set-Content -LiteralPath $script -Encoding utf8

python $script $pathFile
Remove-Item -LiteralPath $script, $pathFile
```

This avoids embedding the non-ASCII path in script source and keeps the command argument ASCII-only.

## SSH boundary

SSH adds at least two text environments: local shell/client and remote shell/program. Diagnose both sides.

Inspect local client and remote locale:

```bash
ssh -V
ssh host 'locale; locale charmap; printf "Unicode test: 中文 café русский عربى 😀\n"'
```

Try a session-only remote UTF-8 locale:

```bash
LANG=C.UTF-8 LC_ALL=C.UTF-8 ssh host 'locale; printf "Unicode test: 中文 café русский عربى 😀\n"'
```

If this works, persistent fixes may involve the remote user's shell profile or OpenSSH `SendEnv`/`AcceptEnv`; classify those as S2 and ask for approval.

For complex commands, avoid sending deeply nested non-ASCII strings through local shell -> ssh -> remote shell. Prefer stdin scripts:

```bash
ssh host 'sh -s' <<'EOF'
printf '%s\n' 'Unicode test: 中文 café русский عربى 😀'
EOF
```

For file transfer:

- Prefer `sftp` or modern OpenSSH SFTP-mode `scp` for Unicode paths.
- Avoid legacy `scp` wildcard/glob patterns for non-ASCII paths.
- If remote filenames are already mojibake, renaming or transcoding is S3 and needs approval plus backup or tests.

## Persistence checklist

Before writing to profile, registry, global Git config, or user environment variables:

- Confirm the temporary setting fixes the failing command.
- Confirm it does not break the tool that originally expected a legacy encoding.
- Tell the user what is being persisted and how to reverse it.
