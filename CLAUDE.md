# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EEPM (Etersoft EPM) is a universal package manager wrapper that provides a unified interface across all Linux distributions. It wraps native package managers (apt, yum, dnf, zypper, pacman, etc.) with consistent commands.

Main commands:
- `epm` - package management (install, remove, search, etc.)
- `serv` - service management wrapper (systemd, sysvinit)
- `distr_info` - distribution detection utility

## Development Setup

No build step required - this is a shell script project. Run directly from checkout:
```bash
./bin/epm --help
./bin/epm play --list
```

## Testing

Run individual test scripts from the `tests/` directory:
```bash
./tests/test_distr_info.sh
./tests/test_versions.sh
./tests/test_json.sh
```

Code quality checks:
```bash
./check_code.sh              # Run shellcheck and checkbashisms on all scripts
./check_code.sh bin/epm-install  # Check specific file
```

## Architecture

### Core Scripts (`bin/`)

- `epm` - main entry point, loads helpers via `load_helper` function
- `epm-sh-functions` - shared shell functions (output, colors, tty detection)
- `epm-*` - command implementations (epm-install, epm-remove, epm-search, etc.)
- `serv` - service management entry point
- `serv-*` - service command implementations
- `distr_info` - standalone distribution detection script
- `tools_*` - internal utility scripts

The `epm` script uses dynamic helper loading:
```bash
load_helper epm-sh-functions  # Load shared functions
load_helper epm-install       # Load specific command
```

### Play Scripts (`play.d/`)

Scripts for installing applications from official sources (not repositories). Each script:
- Sources `common.sh` for shared functionality
- Defines: `PKGNAME`, `DESCRIPTION`, `VERSION`, `URL`, `SUPPORTEDARCHES`
- Handles `--description`, `--package-name`, `--installed`, `--remove`, `--info`, `--update`, `--run`
- Downloads and installs packages using `epm` commands

Example structure:
```bash
BASEPKGNAME=AppName
SUPPORTEDARCHES="x86_64"
DESCRIPTION="App description"
. $(dirname $0)/common.sh
# Download and install logic
```

### Repack Scripts (`repack.d/`)

Scripts for converting packages between formats (rpm↔deb) with distro-specific fixes.

### Pack Scripts (`pack.d/`)

Scripts for creating packages from tarballs/binaries. Work in temp directory, return tarball via `return_tar`.

### Prescription Scripts (`prescription.d/`)

Meta-package recipes that install groups of related packages.

## Key Functions in common.sh

- `epm` - wrapper that shows commands being run
- `eget` - wget-like download utility (`epm tool eget`)
- `get_github_url` / `get_github_tag` - GitHub release helpers
- `install_pkgurl` / `install_pack_pkgurl` - package installation
- `is_glibc_enough` / `is_stdcpp_enough` - version requirement checks
- `fatal` / `info` - output helpers

## Adding New Play Scripts

1. Create `play.d/appname.sh`
2. Define required variables (PKGNAME, DESCRIPTION, SUPPORTEDARCHES)
3. Source `common.sh`
4. Implement download/version detection logic
5. Call `install_pkgurl` or `install_pack_pkgurl`

## Shell Compatibility

All scripts must be POSIX-compatible (avoid bashisms). Use `#!/bin/sh` for most scripts. The `check_code.sh` script verifies this with `checkbashisms`.
