#!/usr/bin/env bats

@test "Git Writer repack installs the launcher and menu entry" {
    local root="$BATS_TEST_TMPDIR/root"
    local product=/opt/gitwriter
    local desktop=gitwriter-GitWriter.desktop
    mkdir -p "$root$product/bin" "$root$product/lib"
    touch "$root$product/bin/GitWriter"
    printf '%s\n' '[Desktop Entry]' 'Exec=/opt/gitwriter/bin/GitWriter' 'Categories=Unknown' > "$root$product/lib/$desktop"
    printf '%%files\n' > "$BATS_TEST_TMPDIR/package.spec"

    run bash "$BATS_TEST_DIRNAME/../../repack.d/gitwriter.sh" "$root" "$BATS_TEST_TMPDIR/package.spec"
    [ "$status" -eq 0 ]
    [ "$(readlink "$root/usr/bin/git-writer")" = "$product/bin/GitWriter" ]
    [ -x "$root$product/bin/GitWriter" ]
    grep -Fx 'Categories=Office;' "$root/usr/share/applications/$desktop"
    grep -Fx "/usr/share/applications/$desktop" "$BATS_TEST_TMPDIR/package.spec"
}
