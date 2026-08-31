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

extract_static_values() {
  local file="$1"
  local var_pattern="$2"
  local value_pattern="$3"

  [[ -f "$file" ]] || return 0

  awk -v var_pattern="$var_pattern" -v value_pattern="$value_pattern" '
    /^[[:space:]]*#/ { next }
    {
      line = $0
      sub(/^[[:space:]]*/, "", line)
      if (line !~ "^(" var_pattern ")=") {
        next
      }

      sub(/^[^=]*=/, "", line)
      sub(/[[:space:]]+#.*$/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)

      if (line ~ /^"[^"]*"$/ || line ~ /^\047[^\047]*\047$/) {
        line = substr(line, 2, length(line) - 2)
      }

      if (line ~ value_pattern) {
        print tolower(line)
      }
    }
  ' "$file"
}

extract_static_play_names() {
  local file="$1"

  extract_static_values "$file" "PKGNAME|BASEPKGNAME|REPOPKGNAME|PRODUCT" "^[[:alnum:]_.+-]+$"
}

extract_static_product_alternatives() {
  local file="$1"

  extract_static_values "$file" "PRODUCTALT" "^([[:alnum:]_.+-]+|\047\047|[[:space:]])+$"
}

normalize_name() {
  tr '[:upper:]' '[:lower:]'
}

is_play_app() {
  local app="$1"

  grep -Fxq "$app" <<< "$PLAY_LIST_TEXT"
}

find_play_app_by_alias() {
  local candidate="$1"
  local play_script app alias

  if is_play_app "$candidate"; then
    echo "$candidate"
    return 0
  fi

  for play_script in play.d/*.sh; do
    [[ -f "$play_script" ]] || continue
    app="$(basename "$play_script" .sh | normalize_name)"

    is_play_app "$app" || continue

    while IFS= read -r alias; do
      if [[ "$alias" == "$candidate" ]]; then
        echo "$app"
        return 0
      fi
    done < <(extract_static_play_names "$play_script")
  done

  return 1
}

resolve_play_app() {
  local file="$1"
  local candidate app

  while IFS= read -r candidate; do
    [[ -z "$candidate" ]] && continue

    if app="$(find_play_app_by_alias "$candidate")"; then
      echo "$app"
      return 0
    fi
  done < <(
    {
      basename "$file" .sh | normalize_name
      extract_static_play_names "$file"
    } | awk 'NF && !seen[$0]++'
  )

  return 1
}

expand_play_app_targets() {
  local app="$1"
  local play_script="play.d/$app.sh"
  local alternatives alt
  local -a editions

  alternatives="$(extract_static_product_alternatives "$play_script")"

  # The bare app name selects the first PRODUCTALT entry.
  echo "$app"

  read -r -a editions <<< "$alternatives"
  [[ "${#editions[@]}" -gt 1 ]] || return 0

  for alt in "${editions[@]:1}"; do
    [[ "$alt" == "''" ]] && continue
    echo "$app=$alt"
  done
}

# Test if play.d/ pack.d/ repack.d/ has any changes
if ! echo "$CHANGED_FILES" | grep -Eq '^(play\.d/|pack\.d/|repack\.d/)'; then
  echo "No changes in play.d/, pack.d/, repack.d/ -> nothing to test."
  echo "apps=" >> "$GITHUB_OUTPUT"
  echo "count=0" >> "$GITHUB_OUTPUT"
  exit 0
fi

PLAY_LIST_TEXT="$(bin/epm play --short | normalize_name | sort -u)"
mapfile -t APPS < <(
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ "$file" =~ ^(play\.d/|pack\.d/|repack\.d/) ]] || continue

    if app="$(resolve_play_app "$file")"; then
      expand_play_app_targets "$app"
    else
      echo "Skip '$file' (can't resolve to epm play app)" >&2
    fi
  done <<< "$CHANGED_FILES" | sort -u
)

echo "Apps from changed scripts:"
printf '%s\n' "${APPS[@]}"

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
