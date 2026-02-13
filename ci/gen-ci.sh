#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GEN_DIR="$SCRIPT_DIR/gen-ci.d"

. "$GEN_DIR/header.sh"
. "$GEN_DIR/download.sh"
. "$GEN_DIR/tests.sh"
. "$GEN_DIR/summary.sh"

# Presets
FULL_TEST="${FULL_TEST:-}"
GET_VERSION="${GET_VERSION:-}"
if [ -n "$FULL_TEST" ] && [ -n "$GET_VERSION" ]; then
  echo "ERROR: FULL_TEST and GET_VERSION cannot be set together" >&2
  exit 1
fi

USE_DOWNLOAD=0
USE_IPFS=0
USE_IPFS_UPDATE=0
RESULTS_DIR="experiments"
RESULTS_LABEL="custom"

if [ -n "$FULL_TEST" ]; then
  systems="alt:sisyphus debian:bookworm fedora:latest"
  USE_DOWNLOAD=1
  USE_IPFS=1
  USE_IPFS_UPDATE=0
  CI_APPS=""
  RESULTS_DIR="epm-results"
  RESULTS_LABEL="full-test"
elif [ -n "$GET_VERSION" ]; then
  systems="alt:p11"
  USE_DOWNLOAD=0
  USE_IPFS=1
  USE_IPFS_UPDATE=1
  CI_APPS=""
  RESULTS_DIR="version"
  RESULTS_LABEL="get-version"
fi

# Get applications list
if [ -n "${CI_APPS:-}" ]; then
  apps="$CI_APPS"
else
  apps=$(./bin/epmp --short 2>/dev/null)
fi

# Get systems list
if [ -n "${systems:-}" ]; then
  :
elif [ -n "${CI_SYSTEMS:-}" ]; then
  systems="$CI_SYSTEMS"
else
  systems="alt:sisyphus debian:bookworm"
fi

# IPFS download stage switch (off by default)
if [ -z "$GET_VERSION" ] && [ -n "${CI_DOWNLOAD:-}" ]; then
  USE_DOWNLOAD=1
fi

# IPFS play flag (off by default)
if [ -n "${CI_USE_IPFS:-}" ] || [ "$USE_DOWNLOAD" -eq 1 ]; then
  USE_IPFS=1
fi

if [ -n "${CI_IPFS_UPDATE:-}" ] && [ -z "$FULL_TEST" ]; then
  USE_IPFS_UPDATE=1
  USE_IPFS=1
fi

header

if [ "$USE_DOWNLOAD" -eq 1 ]; then
  download_jobs
  publish_job
fi

check_anchors
tests
summary
