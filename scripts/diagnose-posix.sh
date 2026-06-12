#!/usr/bin/env sh
set -eu

printf '%s\n\n' "CLI Unicode Encoding Diagnostics - POSIX shell"

printf '%s\n' "[Locale]"
if command -v locale >/dev/null 2>&1; then
  locale
  printf 'charmap='
  locale charmap 2>/dev/null || printf 'unavailable\n'
else
  printf '%s\n' "locale: unavailable"
fi

printf '\n%s\n' "[Python]"
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import sys,locale; print('stdout=' + str(sys.stdout.encoding)); print('preferred=' + str(locale.getpreferredencoding(False)))"
elif command -v python >/dev/null 2>&1; then
  python -c "import sys,locale; print('stdout=' + str(sys.stdout.encoding)); print('preferred=' + str(locale.getpreferredencoding(False)))"
else
  printf '%s\n' "python: unavailable"
fi

printf '\n%s\n' "[Unicode smoke test]"
printf '%s\n' "Unicode test: 中文 café русский عربى 😀"

printf '\n%s\n' "[Suggested next steps]"
printf '%s\n' "1. If locale is C or POSIX, test a UTF-8 locale such as C.UTF-8 before persisting changes."
printf '%s\n' "2. If a specific file is garbled, try explicit file encodings before changing shell startup files."
printf '%s\n' "3. Persist locale changes only after a temporary shell test fixes the exact failure."
