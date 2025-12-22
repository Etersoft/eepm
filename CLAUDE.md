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

**Execution order:**
1. `generic.sh` - always runs first
2. `generic-$SUBGENERIC.sh` (appimage/snap/tar) - based on package type
3. Specific script (e.g., `firefox.sh`) - if exists
4. `generic-default.sh` - only if no specific script exists
5. `generic-post.sh` - always runs last

**Key functions in `common.sh`:**
- `add_electron_deps` - for Electron apps (includes `fix_chrome_sandbox`, removes `app-update.yml`)
- `add_chromium_deps` - for Chromium browsers (includes `fix_chrome_sandbox`)
- `add_libs_requires` - scans binaries and adds library dependencies
- `ignore_lib_requires` - excludes libraries from dependencies (call before `add_libs_requires`)
- `fix_chrome_sandbox` - sets SUID bit on chrome-sandbox

**Detecting app type:**
- Electron apps: have `resources/` dir and `v8_context_snapshot.bin`
- Chromium browsers: have `v8_context_snapshot.bin` without `resources/`

**Common includes:**
- `common.sh` - main repack functions
- `common-chromium-browser.sh` - for Chromium-based browsers (sources `common.sh`)

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

## Working with Claude Code

- Temporary files should be downloaded to `/tmp`, not to the project directory
- We always repack packages to get rid of maintainer scripts. Check what useful things are in the original package scripts
- Test server: `ssh epm@epm-sisyphus` - has installed packages for testing, check `/opt/` for package structure
- Sync code to test server: `./tests/sync-to-epm-sisyphus.sh` - copies to `~/eepm-bot/` (not touching system `~/eepm/`)
- Run tests on server: `ssh epm@epm-sisyphus '~/bin/run-test-update.sh [package...]'`
  - Without arguments: tests all packages
  - With arguments: tests specific packages (e.g., `bitwarden obsidian`)
  - Error logs saved to `~/epm-errors/` on epm-sisyphus

## IPFS Database

eget (download utility) can use IPFS for caching downloaded files. The database maps URLs to IPFS CIDs and filenames.

**Database locations:**
- Source: `epm@epm-update:/var/lib/eepm/eget-ipfs-db.txt`
- Published: `/var/ftp/pub/download/eepm/releases/3.64/app-versions/eget-ipfs-db.txt` (local FTP)
- Test server: `epm@epm-sisyphus:/var/lib/eepm/eget-ipfs-db.txt`

**Database format:**
```
URL CID FILENAME
https://example.com/file.rpm QmXxx... file.rpm
```

**Known issue:** When downloading fails or Content-Disposition is missing, eget may save UUID (from GitHub CDN redirect URL) instead of filename. This causes patool to fail with "unknown archive format". Pattern to find corrupted entries:
```bash
grep -E " [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$" eget-ipfs-db.txt
```

**Cleanup procedure:**
```bash
# Remove entries with UUID as filename
grep -vE " [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$" db.txt > db-clean.txt

# Update source DB
scp epm@epm-update:/var/lib/eepm/eget-ipfs-db.txt /tmp/
# ... clean ...
scp /tmp/eget-ipfs-db.txt epm@epm-update:/var/lib/eepm/

# Publish to FTP
cp /tmp/eget-ipfs-db.txt /var/ftp/pub/download/eepm/releases/3.64/app-versions/
```

**Protection in eget:** `is_strange_url()` function detects URLs with `?` query strings (like GitHub CDN) and preserves the original URL instead of the redirect target.

## User Support

When analyzing user issues:
- **Always ask for epm version** (`epm --version` or `epm -V`) - many issues are caused by outdated epm versions
- User error messages often don't include version info, making it hard to diagnose
- epm play adds apps that can't be built from sources in repos (complex projects or proprietary binaries)