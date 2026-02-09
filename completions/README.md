# Shell Completions for EPM

This directory contains shell completion scripts for epm and related commands.

## Structure

```
completions/
├── bash/
│   ├── eepm          # bash completion for epm
│   └── serv          # bash completion for serv
├── zsh/
│   ├── _eepm         # zsh completion for epm
│   └── _serv         # zsh completion for serv
└── fish/
    ├── eepm.fish     # fish completion for epm
    └── *.fish        # symlinks for command aliases (epmi, epme, etc.)
```

## Testing

### Automated tests

Run the completion tests:

```bash
./tests/test_completions.sh
```

This checks:
- Syntax validity for all completion scripts
- Fish symlinks are valid
- Scripts can be sourced and provide completions

### Manual testing (without system installation)

**Bash:**

```bash
# Load completions
source ./completions/bash/eepm

# Test completion manually
COMP_WORDS=(epm ins); COMP_CWORD=1; __eepm; echo "${COMPREPLY[@]}"

# Or start a new bash with completions loaded
bash --rcfile <(echo "source ./completions/bash/eepm")
# Then type: epm <Tab>
```

**Zsh:**

```zsh
# Add to fpath and reinitialize
fpath=(./completions/zsh $fpath)
autoload -Uz compinit && compinit

# Then type: epm <Tab>
```

**Fish:**

```fish
# Source and test
source ./completions/fish/eepm.fish

# Check what completions are available
complete -C "epm "
complete -C "epm play "
complete -C "epm repo "
```

## Data source

Completion data is generated dynamically using `epm tool epm-completion`:

```bash
# List all commands with descriptions and argument types
epm tool epm-completion commands

# List all options
epm tool epm-completion options

# List subcommand options (repo, mark, play, etc.)
epm tool epm-completion repo
epm tool epm-completion play
```

Output format is TSV: `command<TAB>description[<TAB>argtype]`

Argument types for completion:
- `package` - available packages
- `package_installed` - installed packages
- `playapp` - epm play applications
- `prescription` - epm prescription scripts
- `repo` - repository names
- `file` - file paths
