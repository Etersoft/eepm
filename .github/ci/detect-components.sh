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

  grep -Fxq "$app" <<< "$PLAY_LIST"
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

collect_play_apps() {
  local file app

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ "$file" =~ ^(play\.d/|pack\.d/|repack\.d/) ]] || continue

    if app="$(resolve_play_app "$file")"; then
      expand_play_app_targets "$app"
    else
      echo "Skip '$file' (can't resolve to epm play app)" >&2
    fi

  done <<< "$CHANGED_FILES" | sort -u
}

report_multiple_editions() {
  local apps_text="$1"
  local target app message
  local -A edition_counts=()
  local -A edition_targets=()

  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    app="${target%%=*}"
    edition_counts["$app"]=$(( ${edition_counts["$app"]:-0} + 1 ))

    if [[ -n "${edition_targets["$app"]:-}" ]]; then
      edition_targets["$app"]+=", $target"
    else
      edition_targets["$app"]="$target"
    fi
  done <<< "$apps_text"

  while IFS= read -r app; do
    [[ "${edition_counts["$app"]}" -gt 1 ]] || continue
    message="$app: multiple editions detected; running tests for all editions: ${edition_targets["$app"]}"
    echo "$message"
    echo "::notice title=Multiple editions detected::$message"

    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
      printf -- '- %s\n' "$message" >> "$GITHUB_STEP_SUMMARY"
    fi
  done < <(printf '%s\n' "${!edition_counts[@]}" | sort)
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
PLAY_LIST="$(bin/epm play --short | normalize_name | sort -u)"

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
    play_apps="$(collect_play_apps)"
    echo "Apps from changed scripts:"
    echo "${play_apps:-<none>}"
   
    if [[ -z "$play_apps" ]]; then
      echo "No apps to test after filtering."
      continue
    fi

    report_multiple_editions "$play_apps"
  fi

  components+=("$component")
  IFS=',' read -r -a system_list <<< "$systems"

  if [[ "$component" == "play" ]]; then
    while IFS= read -r app; do
      [[ -z "$app" ]] && continue

      for system in "${system_list[@]}"; do
        system="$(trim "$system")"
        [[ -z "$system" ]] && continue
        entries+=("{\"component\":\"$component\",\"system\":\"$system\",\"target\":\"$app\",\"app\":\"$app\"}")
      done
    done <<< "$play_apps"
  else
    for system in "${system_list[@]}"; do
      system="$(trim "$system")"
      [[ -z "$system" ]] && continue
      entries+=("{\"component\":\"$component\",\"system\":\"$system\",\"target\":\"$component\",\"app\":\"\"}")
    done
  fi

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
