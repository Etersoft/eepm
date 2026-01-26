#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is not set}"

BASE="${BASE_SHA:-}"
HEAD="${HEAD_SHA:-}"
MAP_FILE=".github/ci/components.map"

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

ensure_commit_exists() {
  local sha="$1"
  local label="$2"
  
  if git cat-file -e "$sha^{commit}" 2>/dev/null; then
    return 0
  fi

  echo "$label commit not in local repo, fetching it..."
  git fetch --no-tags --prune origin "$sha"
}

empty_outputs() {
  {
    echo 'matrix={"include":[]}'
    echo 'count=0'
    echo 'components='
    echo 'apps='
    echo 'changed_files='
  } >> "$GITHUB_OUTPUT"
}

component_changed() {
  local paths_csv="$1"
  local path file files

  IFS=',' read -r -a paths <<< "$paths_csv"
  files="$CHANGED_FILES"
  
  while IFS= read -r file; do

    [[ -z "$file" ]] && continue
  
    for path in "${paths[@]}"; do
      path="$(trim "$path")"
  
      [[ -z "$path" ]] && continue
  
      if [[ "$path" == */ ]]; then
        [[ "$file" == "$path"* ]] && return 0
      else
        [[ "$file" == "$path" || "$file" == "$path/"* ]] && return 0
      fi

    done
  done <<< "$files"
  
  return 1
}

collect_play_apps() {
  local changed_apps play_list app
  changed_apps="$(
    echo "$CHANGED_FILES" \
      | grep -E '^(play\.d/|pack\.d/|repack\.d/)' \
      | sed 's|.*/||' \
      | sed 's/\..*$//' \
      | tr '[:upper:]' '[:lower:]' \
      | sort -u
  )"

  if [[ -z "$changed_apps" ]]; then
    return 0
  fi

  play_list="$(bin/epm play --short | tr '[:upper:]' '[:lower:]' | sort -u)"
  
  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
   
    if grep -Fxq "$app" <<< "$play_list"; then
      echo "$app"
    else
      echo "Skip '$app' (not in epm play --short list)"
    fi

  done <<< "$changed_apps"
}


if [[ -z "$BASE" || -z "$HEAD" ]]; then
  echo "BASE_SHA/HEAD_SHA is empty; nothing to test."
  empty_outputs
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "No git work tree found; nothing to test."
  empty_outputs
  exit 0
fi

echo "Base: $BASE"
echo "Head: $HEAD"

ensure_commit_exists "$BASE" "Base"
ensure_commit_exists "$HEAD" "Head"

if MERGE_BASE="$(git merge-base "$BASE" "$HEAD" 2>/dev/null)"; then
  echo "Merge base: $MERGE_BASE"
  CHANGED_FILES="$(git diff --name-only "$MERGE_BASE" "$HEAD")"
else
  echo "Warning: can't determine merge-base; fallback to direct base..head diff."
  CHANGED_FILES="$(git diff --name-only "$BASE" "$HEAD")"
fi

echo "Changed files:"
echo "$CHANGED_FILES"

if [[ -z "$CHANGED_FILES" ]]; then
  echo "No changed files."
  empty_outputs
  exit 0
fi


entries=()
components=()
play_apps=''

while IFS='|' read -r component path_list systems; do
  component="$(trim "${component:-}")"
  path_list="$(trim "${path_list:-}")"
  systems="$(trim "${systems:-}")"

  [[ -z "$component" ]] && continue
  [[ "$component" =~ ^# ]] && continue
  [[ -z "$path_list" || -z "$systems" ]] && continue

  if ! component_changed "$path_list"; then
    continue
  fi

  if [[ "$component" == "play" ]]; then
    play_apps="$(collect_play_apps | grep -v "^Skip '" || true)"
    echo "Apps from changed scripts:"
    echo "${play_apps:-<none>}"
   
    if [[ -z "$play_apps" ]]; then
      echo "No apps to test after filtering."
      continue
    fi
  fi

  components+=("$component")
  IFS=',' read -r -a system_list <<< "$systems"
  
  for system in "${system_list[@]}"; do
    system="$(trim "$system")"
    [[ -z "$system" ]] && continue
    entries+=("{\"component\":\"$component\",\"system\":\"$system\"}")
  done

done < "$MAP_FILE"

if [[ "${#entries[@]}" -eq 0 ]]; then
  empty_outputs
  exit 0
fi

components_csv="$(printf '%s\n' "${components[@]}" | sort -u | paste -sd, -)"
matrix="{\"include\":["
matrix+=$(IFS=,; echo "${entries[*]}")
matrix+="]}"

{
  echo "matrix=$matrix"
  echo "count=${#entries[@]}"
  echo "components=$components_csv"
  echo "apps<<EOF"
  printf '%s\n' "$play_apps"
  echo "EOF"
  echo "changed_files<<EOF"
  printf '%s\n' "$CHANGED_FILES"
  echo "EOF"
} >> "$GITHUB_OUTPUT"
