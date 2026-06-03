#!/usr/bin/env bash
set -euo pipefail

echo "=== Publishing IPFS DB ==="

# Get epm version (major.minor)
EPM_VERSION=$("$CI_PROJECT_DIR/bin/epm" --version --short | cut -d. -f1,2)
echo "EPM version: $EPM_VERSION"

# repo vars
IPFS_REPO_URL="https://gitlab.eterfund.ru/EPM/epm-play-ci-results.git"
WORKDIR="ipfs-results"

# check
if [ ! -f "ipfs/eget-ipfs-db.txt" ]; then
  echo "ERROR: ipfs/eget-ipfs-db.txt not found"
  exit 1
fi

# Clone target branch if exists, otherwise clone default and create new branch
if git clone -b "${EPM_VERSION}" "$IPFS_REPO_URL" "$WORKDIR" 2>/dev/null; then
    cd "$WORKDIR"
else
    git clone "$IPFS_REPO_URL" "$WORKDIR"
    cd "$WORKDIR"
    git checkout -b "${EPM_VERSION}"
fi

# git setup
git config user.name "Builder Robot"
git config user.email "builer-robot@etersoft.ru"

# clean old data
rm -rf ipfs/logs/ ipfs/errors/ || true

# prepare dirs
mkdir -p ipfs/logs ipfs/errors ipfs/meta

# replace DB and logs
cp -f ../ipfs/eget-ipfs-db.txt ipfs/eget-ipfs-db.txt
rsync -a ../ipfs/logs/ ipfs/logs/ || true
rsync -a ../ipfs/errors/ ipfs/errors/ || true

# meta info
echo "$CI_PIPELINE_ID" > ipfs/meta/pipeline-id
echo "$CI_COMMIT_SHA"  > ipfs/meta/commit-sha
date -u +%Y-%m-%dT%H:%M:%SZ > ipfs/meta/timestamp

# commit
git add ipfs

git commit -m "IPFS DB update (pipeline $CI_PIPELINE_ID)" || {
  echo "Nothing to commit"
  exit 0
}

# push to version branch
git remote set-url origin "https://builder-robot:${CI_PUSH_TOKEN}@gitlab.eterfund.ru/EPM/epm-play-ci-results.git"
git push origin "${EPM_VERSION}" 2>/dev/null

echo "=== IPFS DB and download log's published ==="
