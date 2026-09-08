#!/usr/bin/env bats

setup() {
    export ROOTDIR="$BATS_TEST_TMPDIR/root"
    DISTR_INFO="$BATS_TEST_DIRNAME/../bin/distr_info"
    CPUFREQ="$ROOTDIR/sys/devices/system/cpu/cpufreq"
    mkdir -p "$ROOTDIR/proc" "$CPUFREQ"
    printf 'processor\t: 0\n' > "$ROOTDIR/proc/cpuinfo"
}

policy() {
    mkdir -p "$CPUFREQ/policy$1"
    printf '%s\n' "$2" > "$CPUFREQ/policy$1/related_cpus"
    printf '%s\n' "$3" > "$CPUFREQ/policy$1/scaling_cur_freq"
    printf '%s\n' "$4" > "$CPUFREQ/policy$1/cpuinfo_max_freq"
}

@test "SC7180 reports both CPUFreq domains with fractional MHz" {
    # Actual TCL B220G readings from bug #19452, comment 1.
    policy 0 '0 1 2 3 4 5' 1516800 1804800
    policy 6 '6 7' 825600 2400000
    expected='policy0 (CPUs 0 1 2 3 4 5): current 1516.8 MHz, max 1804.8 MHz; policy6 (CPUs 6 7): current 825.6 MHz, max 2400 MHz'
    run sh "$DISTR_INFO" -z
    [ "$status" -eq 0 ]
    [ "$output" = "$expected" ]
    run sh "$DISTR_INFO"
    [ "$status" -eq 0 ]
    [[ "$output" == *"CPU Cores/MHz (-c/-z): "*" / $expected"* ]]
    run "$BATS_TEST_DIRNAME/../bin/epm" print info
    [ "$status" -eq 0 ]
    [[ "$output" == *"CPU Cores/MHz (-c/-z): "*" / $expected"* ]]
}

@test "current frequency is read again without changing the maximum" {
    policy 0 '0 1' 600000 1804800
    run sh "$DISTR_INFO" -z
    [[ "$output" == *'current 600 MHz, max 1804.8 MHz' ]]
    printf '1000123\n' > "$CPUFREQ/policy0/scaling_cur_freq"
    run sh "$DISTR_INFO" -z
    [ "$output" = 'policy0 (CPUs 0 1): current 1000.123 MHz, max 1804.8 MHz' ]
}

@test "missing current frequency does not turn maximum into current" {
    policy 0 '0-5' '' 1804800
    rm "$CPUFREQ/policy0/scaling_cur_freq"
    run sh "$DISTR_INFO" -z
    [ "$status" -eq 0 ]
    [ "$output" = 'policy0 (CPUs 0-5): current unknown, max 1804.8 MHz' ]
}

@test "missing maximum and related CPUs retain policy identity" {
    policy 6 '' 1200000 ''
    rm "$CPUFREQ/policy6/related_cpus" "$CPUFREQ/policy6/cpuinfo_max_freq"
    run sh "$DISTR_INFO" -z
    [ "$output" = 'policy6: current 1200 MHz, max unknown' ]
}

@test "missing CPUFreq and cpuinfo are quiet and unknown" {
    rm "$ROOTDIR/proc/cpuinfo"
    rmdir "$CPUFREQ"
    run sh "$DISTR_INFO" -z
    [ "$status" -eq 0 ]
    [ "$output" = unknown ]
}

@test "invalid zero and unreadable frequencies do not produce false MHz" {
    policy 0 '0' 0 invalid
    policy 6 '6' '' ''
    # A directory causes a read error even when tests run as root.
    rm "$CPUFREQ/policy6/scaling_cur_freq"
    mkdir "$CPUFREQ/policy6/scaling_cur_freq"
    run sh "$DISTR_INFO" -z
    [ "$status" -eq 0 ]
    [ "$output" = unknown ]
}

@test "x86 retains numeric -z output and the original info format" {
    printf 'processor : 0\ncpu MHz\t\t: 2345.678\nprocessor : 1\ncpu MHz : 1800.000\n' > "$ROOTDIR/proc/cpuinfo"
    run sh "$DISTR_INFO" -z
    [ "$status" -eq 0 ]
    [ "$output" = 2345 ]
    run sh "$DISTR_INFO"
    [[ "$output" == *'CPU Cores/MHz (-c/-z): '*' / 2345 MHz'* ]]
    policy 0 '0' 2200000 3600000
    run sh "$DISTR_INFO" -z
    [ "$output" = 2345 ]
    run sh "$DISTR_INFO"
    [[ "$output" == *'CPU Cores/MHz (-c/-z): '*' / 2345 MHz'* ]]
}
