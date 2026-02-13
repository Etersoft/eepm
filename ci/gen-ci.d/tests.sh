ANCHORS_FILE="${GEN_DIR}/anchors.yml"

check_anchors()
{
  if [ ! -f "$ANCHORS_FILE" ]; then
    echo "ERROR: anchors file not found: $ANCHORS_FILE" >&2
    exit 1
  fi
  cat "$ANCHORS_FILE"
  echo
}

anchor_exists()
{
  local anchor="$1"
  grep -q -- "&${anchor}" "$ANCHORS_FILE"
}

resolve_anchor()
{
  local system="$1"
  local mode="$2"
  local safe_system="${3:-}"
  local family="${system%%:*}"
  local safe_family="${family//[^a-zA-Z0-9_]/_}"
  local anchor_exact="test_${safe_system}_${mode}"
  local anchor_family="test_${safe_family}_${mode}"
  local anchor_default="test_default_${mode}"

  if anchor_exists "$anchor_exact"; then
    echo "$anchor_exact"
    return 0
  fi

  if anchor_exists "$anchor_family"; then
    echo "$anchor_family"
    return 0
  fi

  if anchor_exists "$anchor_default"; then
    echo "$anchor_default"
    return 0
  fi

  echo "ERROR: default anchor '${anchor_default}' not found in ${ANCHORS_FILE}" >&2
  exit 1
}

tests()
{
  local template_anchor
  template_anchor="test_template"

  local app system safe_app safe_system anchor
  for app in $apps; do
    safe_app="${app//[^a-zA-Z0-9_]/_}"

    for system in $systems; do
      safe_system="${system//[^a-zA-Z0-9_]/_}"

      if [ "$USE_DOWNLOAD" -eq 1 ]; then
        anchor="$(resolve_anchor "$system" "ipfs" "$safe_system")"
      else
        anchor="$(resolve_anchor "$system" "latest" "$safe_system")"
      fi

      cat <<EOF
${safe_app}_${safe_system}_test:
  <<: [*${template_anchor}, *${anchor}]
  image: ${system}
EOF
      if [ "$USE_DOWNLOAD" -eq 1 ]; then
        cat <<'EOF'
  dependencies:
    - publish_download_logs
EOF
      fi
      cat <<EOF
  script:
    - bash ./ci/run_one_ci.sh ${app}

EOF
    done
  done
}
