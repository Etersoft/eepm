# epm command-not-found hook for fish
# Suggests package installation when unknown command is entered

function fish_command_not_found
    epm tool epm-command-not-found $argv[1]
    return 127
end
