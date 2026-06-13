# CLI Unicode Encoding Skill

一份给 Agent 和中文用户都能用的 CLI Unicode 编码排障指南。

它不只解决中文，也覆盖所有非 ASCII 文本在命令行里的常见问题，例如：

- 中文、日文、韩文
- 法语/德语/西班牙语等带重音字符
- 西里尔文、希腊文、阿拉伯文、泰文
- emoji
- 各类中文或非英文路径、文件名

重点平台是 Windows，因为 Windows CLI 的编码层最多、历史包袱最重；同时也包含 macOS/Linux 的快速检查。

## 适用场景

这不是“乱码之后才用”的排障文档，而是 **执行前规避乱码** 的约束。只要命令会碰到非 ASCII 文本、跨 shell、SSH、文件编码或非英文路径，就先按这个 skill 的规则处理。

- CLI 输出变成乱码、问号、方块或 `Ã¤Â¸...`
- 用户输入的非英文字符丢失或变形
- Git 把非英文文件名显示成 `\346\226...`
- Python/Node/Java/ripgrep 等工具读写非 UTF-8 文件失败
- Agent 操作包含中文、空格、括号、emoji 的路径时失败
- Windows PowerShell、cmd、Git Bash、WSL、macOS/Linux 之间文本不一致
- SSH 远程执行或传输文件时，非英文字符变成乱码

## 仓库结构

```text
AGENT_SKILL.md
ACCEPTANCE.md
LICENSE
README.md
references/
  troubleshooting.md
  legacy-encodings.md
scripts/
  diagnose-windows-powershell.ps1
  windows-session-utf8.ps1
  diagnose-posix.sh
  install-codex-skill.ps1
  check-repo.ps1
adapters/
  codex/
    cli-unicode-encoding/
      SKILL.md
      agents/openai.yaml
  claude-code/
    CLAUDE.md
  cursor/
    rules.md
```

`AGENT_SKILL.md` 是唯一权威主干。各 adapter 只告诉具体 Agent 什么时候触发、如何引用主干。

## 脚本策略

本仓库提供保守脚本：

- 诊断脚本只打印环境和建议，不修改系统。
- `windows-session-utf8.ps1` 只修改当前 PowerShell 会话，不写 `$PROFILE`、注册表、Git 全局配置或用户环境变量。
- 持久化修改必须由用户明确确认后再做。

修复分级：

- S0 inspect-only：只诊断，不修改。
- S1 session-only：只影响当前 shell 或进程。
- S2 persistent-user：修改 profile、环境变量、注册表或 Git global config，必须明确确认。
- S3 project/data-changing：转换文件、改源码、改仓库策略或批量重写，必须明确确认并有备份或测试。

Windows 诊断：

```powershell
.\scripts\diagnose-windows-powershell.ps1
```

Windows 当前会话 UTF-8 测试：

```powershell
.\scripts\windows-session-utf8.ps1
```

macOS/Linux 诊断：

```bash
sh ./scripts/diagnose-posix.sh
```

## 快速修复：Windows PowerShell

先在当前 PowerShell 会话里临时测试：

```powershell
chcp 65001
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
```

如果确实修复了问题，再写入 `$PROFILE`：

```powershell
New-Item -ItemType Directory -Force (Split-Path $PROFILE)
New-Item -ItemType File -Force $PROFILE
notepad $PROFILE
```

加入：

```powershell
chcp 65001 > $null
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
```

推荐优先使用 PowerShell 7 和 Windows Terminal。Windows PowerShell 5.1 对重定向、管道和默认文件编码更容易踩坑。

## 快速检查：macOS/Linux

```bash
locale
locale charmap
python3 -c "import sys, locale; print(sys.stdout.encoding); print(locale.getpreferredencoding(False))"
printf 'Unicode test: 中文 café русский عربى 😀\n'
```

通常希望看到 UTF-8 locale，例如 `en_US.UTF-8`、`zh_CN.UTF-8` 或 `C.UTF-8`。

## SSH 快速检查

```bash
ssh host 'locale; locale charmap; printf "Unicode test: 中文 café русский عربى 😀\n"'
LANG=C.UTF-8 LC_ALL=C.UTF-8 ssh host 'locale; printf "Unicode test: 中文 café русский عربى 😀\n"'
```

不要假设 SSH 一定会转发 `LANG` / `LC_*`。复杂远程命令优先通过 stdin 传脚本，减少多层 shell 引号导致的乱码和转义问题。

## Git 非英文文件名

```powershell
git config --global core.quotepath false
git config --global i18n.commitEncoding utf-8
git config --global i18n.logOutputEncoding utf-8
```

`core.quotepath false` 会让 Git 直接显示 Unicode 路径，而不是转义成八进制。

## Python CLI

当前会话临时测试：

```powershell
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
```

确认有效后再持久化：

```powershell
[Environment]::SetEnvironmentVariable('PYTHONUTF8', '1', 'User')
[Environment]::SetEnvironmentVariable('PYTHONIOENCODING', 'utf-8', 'User')
```

## 非 UTF-8 文件

不要假设所有文本都是 UTF-8。老项目、老工具、政府/学校/企业资料经常使用本地旧编码。

例如：

```powershell
rg "关键词" --encoding gbk
rg "検索語" --encoding shift_jis
rg "ключ" --encoding windows-1251
```

PowerShell 读取时显式指定编码：

```powershell
Get-Content -LiteralPath .\file.txt -Encoding utf8
Get-Content -LiteralPath .\legacy.txt -Encoding ansi
```

## 安装到 Agent

### 通用 Agent

把下面这些文件放进你的 Agent instructions / project docs：

```text
AGENT_SKILL.md
references/troubleshooting.md
references/legacy-encodings.md
```

要求 Agent：在运行可能碰到 CLI、SSH、Unicode 路径、非 UTF-8 文件或跨 shell 文本的命令前，先读 `AGENT_SKILL.md`，再按需读 `references/`。

### Codex

推荐使用安装脚本创建自包含 skill：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-codex-skill.ps1 -Force
```

安装后会生成：

```text
%USERPROFILE%\.codex\skills\cli-unicode-encoding
```

这个目录包含 Codex `SKILL.md`、`AGENT_SKILL.md`、`references/` 和 `scripts/`，不依赖仓库原始路径。

### Claude Code

把 `adapters/claude-code/CLAUDE.md` 的内容合并进项目的 `CLAUDE.md`，并保留 `AGENT_SKILL.md` 与 `references/`。

### Cursor

把 `adapters/cursor/rules.md` 合并进 Cursor rules，并保留 `AGENT_SKILL.md` 与 `references/`。

## 发布到 GitHub

```powershell
cd '<path-to>\cli-unicode-encoding-skill'
git add .
git commit -m "Add universal CLI Unicode encoding skill"
git branch -M main
git remote add origin https://github.com/<your-name>/cli-unicode-encoding-skill.git
git push -u origin main
```

建议发布前选择许可证，比如 MIT、Apache-2.0 或 CC BY 4.0。许可证是法律选择，这里不替你默认决定。

## 发布前检查

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-repo.ps1
```
