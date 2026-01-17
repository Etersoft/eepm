# epm command-not-found hook for zsh
# Suggests package installation when unknown command is entered

command_not_found_handler() {
    epm tool epm-command-not-found "$1"
    return 127
}
