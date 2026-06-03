#!/usr/bin/env bash
set -euo pipefail

echo "Collecting CI results"

# Get epm version (major.minor)
EPM_VERSION=$("$CI_PROJECT_DIR/bin/epm" --version --short | cut -d. -f1,2)
echo "EPM version: $EPM_VERSION"

RESULTS_REPO_URL="https://gitlab.eterfund.ru/EPM/epm-play-ci-results.git"
WORKDIR="results"
RESULTS_DIR="${CI_RESULTS_DIR:-epm-results}"
RESULTS_LABEL="${CI_RESULTS_LABEL:-custom}"

merge_ipfs_db() {
  local os_dir="$1"
  local ipfs_dir target_db merged_db dedup_db part

  ipfs_dir="$os_dir/ipfs"
  target_db="$os_dir/eget-ipfs-db.txt"

  if [ ! -d "$ipfs_dir" ]; then
    if [ -s "$target_db" ]; then
      echo "WARNING: $ipfs_dir is missing, keeping existing $target_db"
      return 0
    fi
    echo "WARNING: $ipfs_dir is missing and $target_db is empty or absent, skipping IPFS DB update"
    return 0
  fi

  merged_db="$(mktemp)"
  dedup_db="$(mktemp)"

  if [ -f "$ipfs_dir/eget-ipfs-db.txt" ]; then
    cat "$ipfs_dir/eget-ipfs-db.txt" >> "$merged_db"
  fi

  if [ -d "$ipfs_dir/db-parts" ]; then
    for part in "$ipfs_dir"/db-parts/*.txt; do
      [ -f "$part" ] || continue
      cat "$part" >> "$merged_db"
    done
  fi

  if [ -s "$merged_db" ]; then
    awk 'NF && !seen[$0]++' "$merged_db" > "$dedup_db"
  fi

  if [ -s "$dedup_db" ]; then
    mv -f "$dedup_db" "$target_db"
  elif [ -s "$target_db" ]; then
    echo "WARNING: merged IPFS DB is empty, keeping existing $target_db"
  else
    echo "WARNING: merged IPFS DB is empty and $target_db is empty or absent, skipping IPFS DB update"
  fi

  rm -f "$merged_db" "$dedup_db"
  rm -rf "$ipfs_dir" || true
}

META_DIR="meta"
if [ "$RESULTS_DIR" != "epm-results" ]; then
  META_DIR="${RESULTS_DIR}/meta"
fi

# Clone target branch if exists, otherwise clone default and create new branch
if git clone -b "${EPM_VERSION}" "$RESULTS_REPO_URL" "$WORKDIR" 2>/dev/null; then
    cd "$WORKDIR"
else
    git clone "$RESULTS_REPO_URL" "$WORKDIR"
    cd "$WORKDIR"
    git checkout -b "${EPM_VERSION}"
fi

# git configuration
git config user.name "Builder Robot"
git config user.email "builder-robot@etersoft.ru"

# clean old data
rm -rf "${RESULTS_DIR}"/*/epm-logs "${RESULTS_DIR}"/*/epm-errors "$META_DIR" || true

# copy all results
mkdir -p "$RESULTS_DIR"
rsync -a "$CI_PROJECT_DIR/epm-results/" "${RESULTS_DIR}/" || true

# collect full play list
if [ "$RESULTS_DIR" = "version" ]; then
  mkdir -p "$RESULTS_DIR/ALTLinux-p11/epm-play-versions"
  "$CI_PROJECT_DIR/bin/epm" --short --version > "$RESULTS_DIR/ALTLinux-p11/epm-play-versions/eepm"
  "$CI_PROJECT_DIR/bin/epm" play --full-list-all > "$RESULTS_DIR/ALTLinux-p11/epm-play-list.txt"
fi

# merge IPFS DB with old lines and per-app updates
if [ "$RESULTS_DIR" = "version" ]; then
  merge_ipfs_db "$RESULTS_DIR/ALTLinux-p11"
fi

# ci info
mkdir -p "$META_DIR"
echo "$CI_PIPELINE_ID" > "${META_DIR}/pipeline-id"
echo "$CI_COMMIT_SHA" > "${META_DIR}/commit-sha"
date -u +%Y-%m-%dT%H:%M:%SZ > "${META_DIR}/timestamp"

# commit
git add .
git commit -m "CI results (${RESULTS_LABEL}): pipeline $CI_PIPELINE_ID" || {
    echo "Nothing to commit"
    exit 0
}

# push to version branch
git remote set-url origin "https://builder-robot:${CI_PUSH_TOKEN}@gitlab.eterfund.ru/EPM/epm-play-ci-results.git"
git push origin "${EPM_VERSION}" 2>/dev/null
