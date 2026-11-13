#!/bin/bash

set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
TD="$(mktemp -d "${TMPDIR:-/var/tmp}/eepm-1c-test.XXXXXX")"
trap 'rm -rf "$TD"' EXIT
mkdir -p "$TD/bin"

# Package fixtures only need metadata; no vendor code is executed in these tests.
cat > "$TD/bin/epm" <<'EOF'
#!/bin/sh
case "$1 $2" in
    'tool which') command -v "$3" ;;
    'tool erc') exit 0 ;;
    'print name') basename "$5" | sed -e 's/\.deb$//' -e 's/\.rpm$//' ;;
    'print arch') if [ -f "$5.arch" ]; then cat "$5.arch"; else echo x86_64; fi ;;
    'print version-release') if [ -f "$5.version" ]; then cat "$5.version"; else echo 8.3.27.1508-1; fi ;;
    *) exit 1 ;;
esac
EOF
chmod +x "$TD/bin/epm"
export PATH="$TD/bin:$PATH"

select_packages()
{
    local dir="$1"
    ( cd "$dir" && bash "$REPO/pack.d/1c83-universal.sh" source.zip "$dir/result" )
}

mkdir "$TD/full"
touch "$TD/full/1c-enterprise-8.3-client.deb" "$TD/full/1c-enterprise-8.3-client-nls.deb" \
    "$TD/full/1c-enterprise-8.3-thin-client.deb" "$TD/full/1c-enterprise-8.3-thin-client-nls.deb"
select_packages "$TD/full"
[ "$(wc -l < "$TD/full/result")" = 2 ]
! grep -q thin-client "$TD/full/result"
echo 'PASS: full client excludes thin client and its NLS'

mkdir "$TD/thin"
touch "$TD/thin/1c-enterprise-8.3-thin-client.rpm" "$TD/thin/1c-enterprise-8.3-thin-client-nls.rpm"
select_packages "$TD/thin"
[ "$(wc -l < "$TD/thin/result")" = 2 ]
echo 'PASS: standalone thin client keeps both components'

mkdir "$TD/versions"
touch "$TD/versions/1c-enterprise-8.3-client.rpm" "$TD/versions/1c-enterprise-8.5-thin-client.rpm"
select_packages "$TD/versions"
[ "$(wc -l < "$TD/versions/result")" = 2 ]
echo 'PASS: a different version does not suppress the thin client'

printf '%s\n' i586 > "$TD/full/1c-enterprise-8.3-thin-client.deb.arch"
printf '%s\n' 8.3.27.1508-2 > "$TD/full/1c-enterprise-8.3-thin-client-nls.deb.version"
select_packages "$TD/full"
[ "$(wc -l < "$TD/full/result")" = 4 ]
echo 'PASS: same package-name prefix is insufficient to suppress a different architecture or build'

mkdir "$TD/mixed"
touch "$TD/mixed/1c-enterprise-8.3-client.deb" "$TD/mixed/1c-enterprise-8.3-common.rpm"
if select_packages "$TD/mixed" ; then
    echo 'FAIL: mixed formats accepted' >&2
    exit 1
fi
echo 'PASS: mixed package formats rejected'

mkdir -p "$TD/play" "$TD/sources"
cp "$REPO/play.d/1c.sh" "$TD/play/1c.sh"
cat > "$TD/play/common.sh" <<'EOF'
fatal() { echo "$*" >&2; exit 1; }
override_pkgname() { :; }
epm() { printf '%s\n' "$EPM_OPTIONS" "$@" >> "$CALLS"; }
EOF
export CALLS="$TD/calls" EPM_OPTIONS=--interactive
touch "$TD/sources/client.deb" "$TD/sources/client.rpm" "$TD/sources/client.deb64.zip" \
    "$TD/sources/client.rpm64.zip" "$TD/sources/setup-full-8.3.27.1508-x86_64.run"
for source in "$TD/sources"/* ; do
    bash "$TD/play/1c.sh" --run "$source"
done
[ "$(grep -c -- --interactive "$CALLS")" = 5 ]
! grep -q -- --auto "$CALLS"
echo 'PASS: all source paths inherit interactive options without forcing --auto'

# A failed installer must not produce a package even if it left a payload dir.
cat > "$TD/bin/bwrap" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$BWRAP_ARGS"
exit 42
EOF
cat > "$TD/bin/epm" <<'EOF'
#!/bin/sh
case "$1" in
    assure) exit 0 ;;
    tool) [ "$2" = which ] && command -v "$3" ;;
    *) exit 1 ;;
esac
EOF
chmod +x "$TD/bin/bwrap"
mkdir -p "$TD/run/1c83-client-root/opt/1cv8/x86_64/8.3.27.1508"
touch "$TD/run/setup-full-8.3.27.1508-x86_64.run"
export BWRAP_ARGS="$TD/bwrap-args"
if ( cd "$TD/run" && bash "$REPO/pack.d/1c83-client.sh" setup-full-8.3.27.1508-x86_64.run "$TD/run-result" ) ; then
    echo 'FAIL: installer failure ignored' >&2
    exit 1
fi
[ ! -e "$TD/run-result" ]
[ ! -x "$TD/run/setup-full-8.3.27.1508-x86_64.run" ]
grep -qx -- --ro-bind "$BWRAP_ARGS"
grep -qx /usr/local "$BWRAP_ARGS"
! grep -q -- --prefix "$BWRAP_ARGS"
echo 'PASS: sandbox failure aborts packing and leaves the source mode unchanged'

mkdir -m 0700 "$TD/vendor" "$TD/run-external"
installer=setup-full-8.3.27.1508-x86_64.run
touch "$TD/vendor/$installer"
chmod 755 "$TD/vendor/$installer"
ln -s "$TD/vendor/$installer" "$TD/run-external/$installer"
if ( cd "$TD/run-external" && bash "$REPO/pack.d/1c83-client.sh" "$installer" "$TD/run-external-result" ) ; then
    echo 'FAIL: installer failure ignored' >&2
    exit 1
fi
grep -Fq "$TD/run-external/1c83-installer." "$BWRAP_ARGS"
[ ! -e "$TD/run-external-result" ]
echo 'PASS: executable installer outside the pack directory is staged before sandboxing'

. "$REPO/repack.d/common-1c-enterprise.sh"
BUILDROOT="$TD/root"
mkdir -p "$BUILDROOT/opt/1cv8/x86_64/8.3.27.1508"
for lib in libstdc++.so.6 libgcc_s.so.1 libhwy.so.1 ; do
    touch "$BUILDROOT/opt/1cv8/x86_64/8.3.27.1508/$lib"
done
fix_1c_enterprise_package 1c-enterprise-8.3.27.1508-common
[ "$(find "$BUILDROOT" -type f | wc -l)" = 3 ]
echo 'PASS: repack preserves bundled runtime without architecture/ABI proof'

cat > "$TD/bin/epm" <<'EOF'
#!/bin/sh
case "$1 $2" in
    'tool which') command -v "$3" ;;
    'print info') echo debian ;;
    'assure patchelf') exit 0 ;;
    *) exit 1 ;;
esac
EOF

training="$TD/training"
versiondir=/opt/1cv8t/x86_64/8.5.1.1150
mkdir -p "$training$versiondir" "$training/opt/1cv8t/common" "$training/usr/share/applications"
touch "$training/usr/share/applications/mimeinfo.cache"
printf '#!/bin/sh\nexit 0\n' > "$training$versiondir/1cv8ct"
cp "$training$versiondir/1cv8ct" "$training/opt/1cv8t/common/1cestartt"
chmod +x "$training$versiondir/1cv8ct" "$training/opt/1cv8t/common/1cestartt"
printf 'Summary: Test\n%%files\n/usr/share/applications/mimeinfo.cache\n' > "$TD/training.spec"
bash "$REPO/repack.d/1c83-client.sh" "$training" "$TD/training.spec" > "$TD/repack.log" 2>&1 || {
    cat "$TD/repack.log" >&2
    exit 1
}
desktop="$training/usr/share/applications/1cestartt.desktop"
grep -Fxq 'Exec=/usr/bin/1cestartt' "$desktop"
[ -x "$training/usr/bin/1cestartt" ]
grep -Fxq '/usr/share/applications/1cestartt.desktop' "$TD/training.spec"
[ ! -e "$training/usr/share/applications/mimeinfo.cache" ]
! grep -Fxq '/usr/share/applications/mimeinfo.cache' "$TD/training.spec"
[ "$(find "$training/usr/share/applications" -name '*.desktop' | wc -l)" = 1 ]
if command -v desktop-file-validate >/dev/null ; then
    desktop-file-validate "$desktop"
fi
echo 'PASS: training payload without desktop integration gets one packaged launcher'
