# Legacy Encodings

Use this reference when UTF-8 does not explain the problem.

## Common regional encodings

| Language/region | Common legacy encodings |
| --- | --- |
| Simplified Chinese | GBK, GB18030, CP936 |
| Traditional Chinese | Big5, CP950 |
| Japanese | Shift_JIS, CP932, EUC-JP, ISO-2022-JP |
| Korean | CP949, EUC-KR |
| Western Europe | Windows-1252, ISO-8859-1 |
| Central/Eastern Europe | Windows-1250, ISO-8859-2 |
| Cyrillic | Windows-1251, KOI8-R |
| Greek | Windows-1253, ISO-8859-7 |
| Turkish | Windows-1254, ISO-8859-9 |
| Hebrew | Windows-1255, ISO-8859-8 |
| Arabic | Windows-1256, ISO-8859-6 |
| Thai | Windows-874, TIS-620 |
| Windows text exports | UTF-16LE, often with BOM |

## Practical rules

- Prefer decoding files explicitly over changing the whole terminal.
- If a file came from old Chinese Windows software, try GBK or GB18030.
- If a file came from old Japanese Windows software, try CP932 before plain Shift_JIS.
- If a file came from old Microsoft Office or Windows export tools, check for UTF-16LE.
- If search misses text but opening in an editor looks fine, the editor may be auto-detecting a legacy encoding.
- Do not bulk-convert files unless project policy and tests support it.

## ripgrep examples

```powershell
rg "关键词" --encoding gbk
rg "關鍵詞" --encoding big5
rg "検索語" --encoding shift_jis
rg "검색어" --encoding euc-kr
rg "ключ" --encoding windows-1251
```

## Python examples

```python
from pathlib import Path

path = Path("legacy.txt")
for encoding in ["utf-8", "utf-8-sig", "gb18030", "cp932", "cp949", "windows-1252", "utf-16"]:
    try:
        text = path.read_text(encoding=encoding)
    except UnicodeDecodeError:
        continue
    print(f"decoded as {encoding}")
    break
```

Use this loop only for diagnosis. Once the correct encoding is known, read the file with that encoding directly.
