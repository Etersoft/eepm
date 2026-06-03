download_jobs()
{
  cat <<'EOF'
download_all_p11:
  stage: download_test
  allow_failure: true
  image: alt:p11
  tags:
    - access
  before_script:
    - ./bin/epm -y repo set etersoft
    - ./bin/epm update
    - ./bin/epm -y install wget glibc-pthread file patool squashfs-tools fontconfig
    - ./bin/epm play --auto --ipfs kubo
  script:
    - mkdir -p ipfs/logs ipfs/errors
    - echo "NOTE detailed download output is hidden see artifacts ipfs/logs and ipfs/errors"
EOF
  for app in $apps; do
    cat <<EOF
    - echo "Sleep 90s before download ${app}"
    - sleep 90
    - if ! bash ./ci/prepare_ipfs.sh ${app} >/dev/null 2>&1; then echo "WARN download failed ${app}, see ipfs/errors/${app}-download.log"; else echo "OK download ${app}"; fi
EOF
  done
  cat <<'EOF'
  artifacts:
    when: always
    expire_in: 7 days
    paths:
      - ipfs

EOF
}

publish_job()
{
  cat <<'EOF'
publish_download_logs:
  stage: publish_download_logs
  image: alt:p11
  tags:
    - access
  when: always
  dependencies:
    - download_all_p11
  before_script:
    - ./bin/epm -y repo set etersoft
    - ./bin/epm update
    - ./bin/epm -y install git rsync
  script:
    - echo "Publishing logs and IPFS DB"
    - echo "IPFS files $(find ipfs -type f | wc -l)"
    - du -sh ipfs || true
    - bash ./ci/push-ipfs-db.sh
  artifacts:
    when: always
    expire_in: 7 days
    paths:
      - ipfs

EOF
}
