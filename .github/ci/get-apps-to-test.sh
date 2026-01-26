#!/usr/bin/env bash
set -euo pipefail

# whitelist workdir
git config --global --add safe.directory "$PWD"

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is not set}"

BASE="${BASE_SHA:-}"
HEAD="${HEAD_SHA:-}"

if [[ -z "$BASE" ]]; then
  echo "BASE_SHA/HEAD_SHA is empty; nothing to test."
  echo "apps=" >> "$GITHUB_OUTPUT"
  echo "count=0" >> "$GITHUB_OUTPUT"
  exit 0
fi

echo "Base: $BASE"
echo "Head: $HEAD"

if ! git cat-file -e "$BASE^{commit}" 2>/dev/null; then
  echo "Base commit not in local repo, fetching it..."
  git fetch --no-tags --prune origin "$BASE"
fi

if ! git cat-file -e "$HEAD^{commit}" 2>/dev/null; then
  echo "Head commit not in local repo, fetching it..."
  git fetch --no-tags --prune origin "$HEAD"
fi

CHANGED_FILES="$(git diff --name-only "$BASE" "$HEAD")"
echo "Changed files:"
echo "$CHANGED_FILES"

# Test if play.d/ pack.d/ repack.d/ has any changes
if ! echo "$CHANGED_FILES" | grep -Eq '^(play\.d/|pack\.d/|repack\.d/)'; then
  echo "No changes in play.d/, pack.d/, repack.d/ -> nothing to test."
  echo "apps=" >> "$GITHUB_OUTPUT"
  echo "count=0" >> "$GITHUB_OUTPUT"
  exit 0
fi

mapfile -t CHANGED_APPS < <(
  echo "$CHANGED_FILES" \
    | grep -E '^(play\.d/|pack\.d/|repack\.d/)' \
    | sed 's|.*/||' \
    | sed 's/\..*$//' \
    | tr '[:upper:]' '[:lower:]' \
    | sort -u
)

echo "Apps from changed scripts:"
printf '%s\n' "${CHANGED_APPS[@]}"

# Filter 
mapfile -t PLAY_LIST < <(bin/epm play --short | tr '[:upper:]' '[:lower:]' | sort -u)

tmp="$(mktemp)"
printf '%s\n' "${PLAY_LIST[@]}" > "$tmp"

APPS=()
for c in "${CHANGED_APPS[@]}"; do

  if grep -Fxq "$c" "$tmp"; then
    APPS+=("$c")
  else
    echo "Skip '$c' (not in epm play --short)"
  fi

done

rm -f "$tmp"

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No apps to test after filtering."
  echo "apps=" >> "$GITHUB_OUTPUT"
  echo "count=0" >> "$GITHUB_OUTPUT"
  exit 0
fi

echo "Apps to test:"
printf '%s\n' "${APPS[@]}"

{
  echo "apps<<EOF"
  printf '%s\n' "${APPS[@]}"
  echo "EOF"
  echo "count=${#APPS[@]}"
} >> "$GITHUB_OUTPUT"
