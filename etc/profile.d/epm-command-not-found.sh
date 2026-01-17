# epm command-not-found hook for bash
# Suggests package installation when unknown command is entered

command_not_found_handle() {
    [ $# -eq 1 ] || return 127
    epm tool epm-command-not-found "$1"
    return 127
}
