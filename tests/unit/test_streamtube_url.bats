#!/usr/bin/env bats

@test "Stream Tube resolves both play and package versions to the upstream alpha release" {
    local playdir="$BATS_TEST_DIRNAME/../../play.d"
    local url=https://github.com/Avaneesh-Inamdar/Stream-Tube-Desktop/releases/download/v0.7.3-alpha/streamtube_0.7.3-alpha_amd64.deb
    export PATH="$playdir/../bin:$PATH" EPM_OPTIONS=--print-url

    run "$playdir/streamtube.sh" --run 0.7.3 alpha
    [ "$status" -eq 0 ]
    [ "${lines[-1]}" = "$url" ]

    run "$playdir/streamtube.sh" --run '0.7.3~alpha' 1
    [ "$status" -eq 0 ]
    [ "${lines[-1]}" = "$url" ]
}
