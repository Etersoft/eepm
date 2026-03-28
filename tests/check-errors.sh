#!/bin/sh
# Analyze epm-errors/ logs for system-level problems
# that indicate the build cycle should be stopped.
#
# Usage: check-errors.sh [epm-errors-dir]
# Exit codes: 0 = only app-level errors, 1 = system problems found

EDIR="${1:-$HOME/epm-errors}"

[ -d "$EDIR" ] || { echo "No errors directory: $EDIR" ; exit 0 ; }

found=0

# Patterns indicating system-level problems (not app-specific bugs)
check_pattern()
{
    local pattern="$1"
    local desc="$2"
    local matches
    matches=$(grep -rl "$pattern" "$EDIR"/ 2>/dev/null | while read f; do
        basename "$f"
    done | sort -u)
    if [ -n "$matches" ] ; then
        found=1
        local count=$(echo "$matches" | wc -l)
        echo "  $desc ($count apps):"
        echo "$matches" | head -5 | sed 's/^/    /'
        [ "$count" -gt 5 ] && echo "    ... and $((count - 5)) more"
    fi
}

echo "=== System-level errors in $EDIR ==="

# Package duplicates prevent any installation
check_pattern 'несколько версий пакета' 'Package duplicates (need epm dedup)'

# Disk space
check_pattern 'needs.*on the.*filesystem' 'Disk space insufficient'
check_pattern 'нет свободного места' 'Disk space insufficient'

# Transaction errors (broken rpm db, etc.)
check_pattern 'Ошибка во время исполнения транзакции' 'Transaction execution error'

# RPM database lock
check_pattern "can.t create transaction lock" 'RPM database locked'
check_pattern 'cannot open Packages' 'RPM database corrupted'

echo ""
echo "=== Error summary ==="
total=$(ls "$EDIR"/ 2>/dev/null | grep -vc errors.txt)
echo "Total failed apps: $total"

if [ "$found" = 1 ] ; then
    echo "SYSTEM PROBLEMS DETECTED - fix before continuing rebuild cycle"
    exit 1
else
    echo "No system-level problems (all errors are app-specific)"
    exit 0
fi
