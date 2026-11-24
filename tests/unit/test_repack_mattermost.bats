#!/usr/bin/env bats

check_launcher() {
    local binary="$1"
    local root="$BATS_TEST_TMPDIR/root"
    local desktop="$root/usr/share/applications/mattermost.desktop"
    local target="/opt/Mattermost/$binary"
    mkdir -p "$root/opt/Mattermost" "$(dirname "$desktop")"
    touch "$root$target"
    printf 'Exec=%s %%U\n' "$target" > "$desktop"
    printf '%%files\n' > "$BATS_TEST_TMPDIR/package.spec"

    run bash "$BATS_TEST_DIRNAME/../../repack.d/mattermost-desktop.sh" "$root" "$BATS_TEST_TMPDIR/package.spec"
    [ "$status" -eq 0 ]
    [ "$(readlink "$root/usr/bin/mattermost-desktop")" = "$target" ]
    [ -x "$root$target" ]
    [ "$(cat "$desktop")" = 'Exec=mattermost-desktop %U' ]
}

@test "Mattermost 6.4.0 repacks the renamed executable" {
    check_launcher com.Mattermost.Desktop
}

@test "older Mattermost packages keep their launcher" {
    check_launcher mattermost-desktop
}
