#!/usr/bin/env bash
set -euo pipefail

# detect OS
ID="$(./bin/epm print info -d)"
VERSION_ID="$(./bin/epm print info -v)"
CI_SYSTEM_ID="$ID-$VERSION_ID"

# args
APP="$1"
SAFE_APP="${APP//[^a-zA-Z0-9_]/_}"

# vars
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT_DIR="${CI_PROJECT_DIR:-$REPO_ROOT}"
RESULTS_ROOT="$PROJECT_DIR/epm-results/$CI_SYSTEM_ID"

PLAY_DIR="$RESULTS_ROOT/epm-play-versions"
ERR_DIR="$RESULTS_ROOT/epm-errors"
LOG_DIR="$RESULTS_ROOT/epm-logs"
REQ_DIR="$RESULTS_ROOT/epm-requires"
FILES_DIR="$RESULTS_ROOT/epm-files"
IPFS_DIR="$RESULTS_ROOT/ipfs"
IPFS_PARTS_DIR="$IPFS_DIR/db-parts"

mkdir -p "$PLAY_DIR" "$ERR_DIR" "$LOG_DIR" "$REQ_DIR" "$FILES_DIR"

cd "$REPO_ROOT/bin"

LOG_FILE="$LOG_DIR/$APP.log"

has_failure_markers() {
  # dpkg-shlibdeps reports missing private bundled libraries in successful repacks.
  grep -Ev '^(dpkg-shlibdeps: error: cannot find library |dpkg-shlibdeps: error: cannot continue due to the errors listed above$|dh_shlibdeps: error: )' "$LOG_FILE" | \
    grep -Eq '(^|[[:space:]])ERROR: |^FATAL: |There was some error during (install|run)|^X .+: FAIL$|^make: \*\*\* .* Error [0-9]+|^dh_[^:]+: error: |^dpkg-[^:]+: error: |^WARNING: Can'\''t find converted (deb|rpm)'
}

# IPFS
PLAY_OPTS="--latest"
SPLIT_DOWNLOAD_MODE=0
IPFS_UPDATE_ENABLED=0

if [ -n "${CI_USE_IPFS:-}" ] && [ -f "$PROJECT_DIR/ipfs/eget-ipfs-db.txt" ]; then
  PLAY_OPTS=""
  SPLIT_DOWNLOAD_MODE=1
fi

if [ -n "${CI_USE_IPFS:-}" ] && [ -n "${CI_IPFS_UPDATE:-}" ] && [ "$SPLIT_DOWNLOAD_MODE" -eq 0 ]; then
  IPFS_UPDATE_ENABLED=1
fi

if [ -n "${CI_USE_IPFS:-}" ]; then
  PLAY_OPTS="$PLAY_OPTS --ipfs"

  if [ "$IPFS_UPDATE_ENABLED" -eq 1 ]; then
    export EGET_IPFS_FORCE_LOAD=1
    export EGET_IPFS_API=/ip4/91.232.225.49/tcp/5001

    ./epm -y install kubo

    ipfs --api "$EGET_IPFS_API" diag sys >/dev/null 2>&1 || {
      echo "ERROR: can't access external ipfs API ($EGET_IPFS_API)"

    }

  fi 
fi

IPFS_DB_CAPTURE=0
EGET_DB_PATH="/var/lib/eepm/eget-ipfs-db.txt"
PRE_DB_SNAPSHOT=""
if [ "$IPFS_UPDATE_ENABLED" -eq 1 ]; then
  IPFS_DB_CAPTURE=1
  mkdir -p "$IPFS_PARTS_DIR"
  if [ -f "$EGET_DB_PATH" ]; then
    PRE_DB_SNAPSHOT="$(mktemp)"
    cp -f "$EGET_DB_PATH" "$PRE_DB_SNAPSHOT"
  fi
fi

echo "Installing $APP"

set +e
./epm play $PLAY_OPTS --auto "$APP" 2>&1 | tee "$LOG_FILE"
rc=${PIPESTATUS[0]}
set -e

if [ "$rc" -eq 0 ] && has_failure_markers; then
  echo "Detected failure marker in $LOG_FILE"
  rc=1
fi

# result
if [ "$rc" -eq 0 ]; then
  echo "V $APP: PASS"

  package_name="$(./epm play --package-name "$APP")"

  ./epm print version for package "$package_name" \
    >"$PLAY_DIR/$package_name" \
    2>"$ERR_DIR/$package_name" || true

  ./epm req "$package_name" >"$REQ_DIR/$package_name" 2>&1 || true
  ./epm ql "$package_name" >"$FILES_DIR/$package_name" 2>&1 || true
else
  echo "X $APP: FAIL"
  mv -vf "$LOG_FILE" "$ERR_DIR/$APP.log"
fi

# Save updated IPFS DB and per-app delta for summary merge.
if [ "$IPFS_DB_CAPTURE" -eq 1 ] && [ -f "$EGET_DB_PATH" ]; then
  cp -f "$EGET_DB_PATH" "$IPFS_DIR/eget-ipfs-db.txt"
  if [ -n "$PRE_DB_SNAPSHOT" ] && [ -f "$PRE_DB_SNAPSHOT" ]; then
    grep -Fvx -f "$PRE_DB_SNAPSHOT" "$EGET_DB_PATH" > "$IPFS_PARTS_DIR/$SAFE_APP.txt" || true
  else
    cp -f "$EGET_DB_PATH" "$IPFS_PARTS_DIR/$SAFE_APP.txt"
  fi
fi

if [ -n "$PRE_DB_SNAPSHOT" ] && [ -f "$PRE_DB_SNAPSHOT" ]; then
  rm -f "$PRE_DB_SNAPSHOT"
fi

# cleanup empty error files and dir
if [ -d "$ERR_DIR" ]; then
  find "$ERR_DIR" -type f -size 0 -delete
  rmdir "$ERR_DIR" 2>/dev/null || true
fi

echo "Exit code: $rc"
exit "$rc"
