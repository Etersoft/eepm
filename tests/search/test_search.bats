#!/usr/bin/env bats
# Tests for epm search pattern matching

load helpers

# ============ Basic search ============

@test "search: basic pattern" {
    run run_epm search --short zsh
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
}

@test "search --short: returns only package names" {
    run run_epm search --short zsh
    [ "$status" -eq 0 ]
    # should not contain description separator
    [[ "$output" != *" - "* ]]
}

@test "search --tsv: returns tab-separated output" {
    run run_epm search --tsv zsh
    [ "$status" -eq 0 ]
    # TSV format has tabs
    [[ "$output" == *$'\t'* ]]
}

# ============ Glob patterns ============

@test "search: glob * pattern" {
    run run_epm search --short 'zsh-comp*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-completion"* ]]
}

@test "search: glob ? pattern" {
    run run_epm search --short 'zs?'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
}

@test "search: [abc] character class" {
    run run_epm search --short '^[rn]x'
    [ "$status" -eq 0 ]
    # should match packages starting with rx or nx
    [[ "$output" == *"nx"* ]] || [[ "$output" == *"rx"* ]]
}

@test "search --short: [abc] character class" {
    run run_epm search --short '^li[bc]'
    [ "$status" -eq 0 ]
    # ^li[bc] matches lib* or lic*
    [[ "$output" == *"lib"* ]]
}

# Escaped brackets search for literal [ and ]
@test "search: escaped \\[ \\] works" {
    run run_epm search --short '\['
    [ "$status" -eq 0 ]
    # should not error, even if no results
}

@test "qp: escaped \\[ \\] for literal brackets" {
    run run_epm qp '\[hopefully\]'
    [ "$status" -eq 0 ]
    [[ "$output" == *"[hopefully]"* ]]
}

@test "search --short: glob ? pattern" {
    run run_epm search --short 'bas?'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
    [[ "$output" != *" - "* ]]
}

@test "search --tsv: glob ? pattern" {
    run run_epm search --tsv 'zs?'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
    [[ "$output" == *$'\t'* ]]
}

@test "search --short: glob * pattern" {
    run run_epm search --short 'zsh-auto*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-autosuggestions"* ]]
    [[ "$output" != *" - "* ]]
}

@test "search --tsv: glob * pattern" {
    run run_epm search --tsv 'zsh-auto*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-autosuggestions"* ]]
    [[ "$output" == *$'\t'* ]]
}

# ============ Anchor patterns ============

@test "search: ^ anchor (starts with)" {
    run run_epm search --short '^zsh'
    [ "$status" -eq 0 ]
    # all results should start with zsh
    while IFS= read -r line; do
        [[ "$line" == zsh* ]]
    done <<< "$output"
}

# Note: $ anchor matches end of line (description), not package name
# Use --short for matching package names with $
@test "search: $ anchor (matches description)" {
    run run_epm search 'zsh$'
    [ "$status" -eq 0 ]
    # matches lines where description ends with "zsh"
    [[ "$output" == *"for zsh"* ]]
}

@test "search: ^...$ does not match exact package" {
    run run_epm search '^zsh$'
    [ "$status" -eq 0 ]
    # returns empty because line is "zsh=5.9 - ..." not just "zsh"
    [ -z "$output" ]
}

@test "search --short: ^ anchor" {
    run run_epm search --short '^zsh-auto'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-autosuggestions"* ]]
    # should not contain packages not starting with zsh-auto
    [[ "$output" != *"i586-"* ]]
}

# --short strips description, so $ matches package name
@test "search --short: $ anchor (matches package name)" {
    run run_epm search --short 'zsh$'
    [ "$status" -eq 0 ]
    # all results should end with zsh
    while IFS= read -r line; do
        [[ "$line" == *zsh ]]
    done <<< "$output"
}

@test "search --tsv: ^ anchor" {
    run run_epm search --tsv '^zsh'
    [ "$status" -eq 0 ]
    [[ "$output" == zsh$'\t'* ]]
}

# Note: $ anchor in --tsv matches end of description, not package name
# This is expected grep behavior since TSV format is: pkg\tver\tdesc
@test "search --tsv: $ anchor (matches description)" {
    run run_epm search --tsv 'zsh$'
    [ "$status" -eq 0 ]
    # matches lines where description ends with "zsh"
    [[ "$output" == *"for zsh"* ]] || [[ "$output" == *"like Zsh"* ]]
}

# --short allows exact package name matching with ^...$
@test "search --short: ^...$ exact match (works)" {
    run run_epm search --short '^bash$'
    [ "$status" -eq 0 ]
    [ "$output" = "bash" ]
}

# Note: ^...$ in --tsv won't match by package name alone
# because the line format is pkg\tver\tdesc
@test "search --tsv: ^...$ does not match exact package" {
    run run_epm search --tsv '^zsh$'
    [ "$status" -eq 0 ]
    # returns empty because line is "zsh\t5.9\t..." not just "zsh"
    [ -z "$output" ]
}

# ============ OR patterns ============

@test "search: (a|b) OR pattern" {
    run run_epm search --short '(firefox|chromium)'
    [ "$status" -eq 0 ]
    [[ "$output" == *"firefox"* ]] || [[ "$output" == *"chromium"* ]]
}

@test "search: OR pattern matches both" {
    run run_epm search --short '^(zsh|bash)$'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
    [[ "$output" == *"bash"* ]]
}

@test "search --short: OR pattern" {
    run run_epm search --short '(zsh|bash)'
    [ "$status" -eq 0 ]
    [[ "$output" != *" - "* ]]
}

@test "search --tsv: OR pattern" {
    run run_epm search --tsv '(zsh|bash)'
    [ "$status" -eq 0 ]
    [[ "$output" == *$'\t'* ]]
}

# ============ AND logic (multiple patterns) ============

@test "search: AND logic with space-separated patterns" {
    run run_epm search --short zsh completion
    [ "$status" -eq 0 ]
    # all results should contain both zsh and completion
    while IFS= read -r line; do
        [[ "$line" == *zsh* ]] && [[ "$line" == *completion* ]]
    done <<< "$output"
}

@test "search --short: AND logic" {
    run run_epm search --short zsh syntax
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-syntax-highlighting"* ]]
    [[ "$output" != *" - "* ]]
}

@test "search --tsv: AND logic" {
    run run_epm search --tsv zsh syntax
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-syntax-highlighting"* ]]
}

# ============ Exclusion patterns ============

@test "search: ~pattern exclusion" {
    run run_epm search --short '^zsh' '~completion'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
    [[ "$output" != *"completion"* ]]
}

@test "search: exclusion with other patterns" {
    run run_epm search --short '^zsh' '~auto' '~syntax'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
    [[ "$output" != *"autosuggestions"* ]]
    [[ "$output" != *"syntax"* ]]
}

@test "search --short: exclusion" {
    run run_epm search --short '^zsh' '~comp'
    [ "$status" -eq 0 ]
    [[ "$output" != *"completion"* ]]
    [[ "$output" != *" - "* ]]
}

@test "search --tsv: exclusion" {
    run run_epm search --tsv '^zsh' '~comp'
    [ "$status" -eq 0 ]
    [[ "$output" != *"completion"* ]]
}

# ============ Combined patterns ============

@test "search: combined ^ and *" {
    run run_epm search --short '^zsh-comp*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-completion"* ]]
}

@test "search: combined ^ $ and OR" {
    run run_epm search --short '^(vim|nano)$'
    [ "$status" -eq 0 ]
    [[ "$output" == *"vim"* ]] || [[ "$output" == *"nano"* ]]
}

@test "search --short: combined patterns" {
    run run_epm search --short '^zsh' '~i586'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh"* ]]
    [[ "$output" != *"i586"* ]]
}

@test "search --tsv: combined patterns" {
    run run_epm search --tsv '^zsh-auto*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"zsh-autosuggestions"* ]]
}

# ============ epm play --search ============

@test "play --search: basic pattern" {
    run run_epm play --search --short telegram
    [ "$status" -eq 0 ]
    [[ "$output" == *"telegram"* ]]
}

@test "play --search: ^ anchor" {
    run run_epm play --search --short '^code'
    [ "$status" -eq 0 ]
    [[ "$output" == code* ]]
}

@test "play --search: OR pattern" {
    run run_epm play --search --short '(telegram|discord)'
    [ "$status" -eq 0 ]
    [[ "$output" == *"telegram"* ]] || [[ "$output" == *"discord"* ]]
}

@test "play --search: glob pattern" {
    run run_epm play --search --short 'tele*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"telegram"* ]]
}

@test "play --search: exclusion" {
    run run_epm play --search --short code '~codium'
    [ "$status" -eq 0 ]
    [[ "$output" == *"code"* ]]
    [[ "$output" != *"codium"* ]]
}

@test "play --search: [abc] character class" {
    run run_epm play --search --short '^[rf]'
    [ "$status" -eq 0 ]
    # should match apps starting with r or f
    [ -n "$output" ]
}

@test "play --search: escaped \\[ \\] works" {
    run run_epm play --search --short '\['
    [ "$status" -eq 0 ]
    # should not error, even if no results
}

# ============ epm qp (query installed packages) ============

@test "qp: basic pattern" {
    run run_epm qp --short bash
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
}

@test "qp: ^ anchor" {
    run run_epm qp --short '^bash'
    [ "$status" -eq 0 ]
    # all results start with bash
    while IFS= read -r line; do
        [[ "$line" == bash* ]]
    done <<< "$output"
}

@test "qp --short: $ anchor (matches package name)" {
    run run_epm qp --short 'bash$'
    [ "$status" -eq 0 ]
    # all results end with bash
    while IFS= read -r line; do
        [[ "$line" == *bash ]]
    done <<< "$output"
}

@test "qp: OR pattern" {
    run run_epm qp --short '(bash|zsh)'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]] || [[ "$output" == *"zsh"* ]]
}

@test "qp: glob pattern" {
    run run_epm qp --short 'bash*'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
}

@test "qp: AND logic" {
    run run_epm qp --short lib ssl
    [ "$status" -eq 0 ]
    # all results contain both lib and ssl
    while IFS= read -r line; do
        [[ "$line" == *lib* ]] && [[ "$line" == *ssl* ]]
    done <<< "$output"
}

@test "qp: exclusion" {
    run run_epm qp --short '^bash' '~completion'
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash"* ]]
    [[ "$output" != *"completion"* ]]
}

@test "qp: [abc] character class" {
    run run_epm qp --short '^[rn]x'
    [ "$status" -eq 0 ]
    # should match packages starting with rx or nx
    [[ "$output" == *"nx"* ]] || [[ "$output" == *"rx"* ]]
}
