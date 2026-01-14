#!/usr/bin/env bats
# Tests for epm sf (search_file) pattern matching

load helpers

# ============ Basic search ============

@test "sf: basic pattern" {
    run run_epm sf bash
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
}

@test "sf: finds file path" {
    run run_epm sf /usr/bin/bash
    [ "$status" -eq 0 ]
    [[ "$output" == *"/usr/bin/bash"* ]]
}

# ============ Glob patterns ============

@test "sf: glob * pattern" {
    run run_epm sf '/usr/bin/git*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"git"* ]]
}

# Note: glob ? may be expanded by shell to existing local files
# Test patterns that won't match local filesystem
@test "sf: glob * with partial match" {
    run run_epm sf '/usr/bin/bash*bug'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bashbug"* ]] || [[ "$output" == *"bash3bug"* ]]
}

# ============ AND logic ============

@test "sf: AND logic with space-separated patterns" {
    run run_epm sf bash /usr/bin
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
    [[ "$output" == *"/usr/bin"* ]]
}

@test "sf: AND logic filters results" {
    run run_epm sf python /usr/bin
    [ "$status" -eq 0 ]
    # all results contain python and /usr/bin
    while IFS= read -r line; do
        [[ "$line" == *python* ]] && [[ "$line" == *"/usr/bin"* ]]
    done <<< "$output"
}

# ============ Exclusion patterns ============

@test "sf: ~pattern exclusion" {
    run run_epm sf /usr/bin/bash '~bash3' '~bash4' '~bash5'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
    [[ "$output" != *"bash3"* ]]
    [[ "$output" != *"bash4"* ]]
    [[ "$output" != *"bash5"* ]]
}

@test "sf: exclusion with other patterns" {
    run run_epm sf bashbug '~bash3' '~bash4' '~bash5'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bashbug"* ]]
    [[ "$output" != *"bash3bug"* ]]
}

# ============ OR patterns ============

@test "sf: (a|b) OR pattern" {
    run run_epm sf '(bashbug|python-barcode)'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bashbug"* ]] || [[ "$output" == *"python-barcode"* ]]
}

# ============ Output format ============

@test "sf: output format package: /path" {
    run run_epm sf /usr/bin/bash
    [ "$status" -eq 0 ]
    # output should be in "package: /path" format
    [[ "$output" == *": /usr/bin"* ]]
}

# ============ Character class ============

@test "sf: [abc] character class" {
    run run_epm sf '/usr/bin/bash[345]bug'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash3bug"* ]] || [[ "$output" == *"bash4bug"* ]] || [[ "$output" == *"bash5bug"* ]]
}

# ============ --regexp mode ============

@test "sf --regexp: regex pattern" {
    run run_epm --regexp sf 'bash.*bug'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bashbug"* ]]
}

@test "sf --regexp: dot matches any character" {
    run run_epm --regexp sf '/usr/bin/bash.bug'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash3bug"* ]] || [[ "$output" == *"bash4bug"* ]] || [[ "$output" == *"bash5bug"* ]]
}

# ============ --tsv mode ============

@test "sf --tsv: output format" {
    run run_epm --tsv sf /usr/bin/bash
    [ "$status" -eq 0 ]
    # TSV format: package\tfile
    [[ "$output" == *$'\t'* ]]
}

@test "sf --tsv: no colors" {
    run run_epm --tsv sf /usr/bin/bash
    [ "$status" -eq 0 ]
    # should not contain ANSI escape codes
    [[ "$output" != *$'\033'* ]]
}

@test "sf --tsv: AND logic" {
    run run_epm --tsv sf bash /usr/bin
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
    [[ "$output" == *"/usr/bin"* ]]
}

