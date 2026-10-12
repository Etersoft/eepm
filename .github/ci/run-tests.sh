#!/usr/bin/env bash
set -euo pipefail

APPS_TEXT="${APPS_TEXT:-}"

if [[ -z "$APPS_TEXT" ]]; then
  echo "APPS_TEXT is empty; nothing to run."
  exit 0
fi

echo "Apps to test:"
echo "$APPS_TEXT"

# Some vendor RPM repositories publish primary.xml.zst metadata. Minimal CI
# images do not necessarily include its decompressor.
./bin/epm assure zstdcat zstd </dev/null

while IFS= read -r app; do
  [[ -z "$app" ]] && continue
  echo
  echo "=============================="
  echo "TEST APP: $app"
  echo "=============================="
  bash ./ci/run_one_ci.sh "$app" </dev/null
done <<< "$APPS_TEXT"
