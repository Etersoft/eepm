# Using Local Repository for Package Installation

## Overview

EPM supports installing packages via a local repository instead of direct installation. This is particularly useful for:

- **ALT Atomic systems** - Use immutable system image management via APM
- **Systems with complex dependencies** - Staging packages in a repository before installation
- **Offline installations** - Preparing packages locally and syncing to another system

## How It Works

When local repository mode is enabled, packages are:

1. Added to `/var/lib/eepm/local-repo`
2. Repository index is created/updated using `genbasedir`
3. Repository is registered with the package manager
4. Packages are installed from the repository with explicit version specifications

This avoids direct RPM installation issues and allows proper dependency resolution through the package manager.

## Enabling Local Repository Mode

### Method 1: Configuration File

Edit `/etc/eepm.conf` and uncomment:

```bash
use_local_repo=1
```

### Method 2: Environment Variable

Set the environment variable for a single command:

```bash
export EPM_USE_LOCAL_REPO=1
epm play application_name
```

Or inline:

```bash
EPM_USE_LOCAL_REPO=1 epm install /path/to/package.rpm
```

### Method 3: Automatic for ALT Atomic

ALT Atomic systems automatically enable local repository mode:

```bash
epm play application_name  # Automatically uses local repo on Atomic
```

## Limitations

- Option `--nodeps` is not supported with local repository installation

## Examples

### Install a custom RPM using local repository

```bash
# Enable local repo mode
export EPM_USE_LOCAL_REPO=1

# Install from file
epm install ./my-package.rpm

# Or install from epm play
epm play my-app
```

### Configure permanently for all installations

Edit `/etc/eepm.conf`:

```bash
# Use local repository for package installation
# Packages will be added to local repo and installed from there
use_local_repo=1
```

Then use epm normally - it will always use local repository mode.

### ALT Atomic workflow

```bash
# Packages are automatically staged in local repo
epm play firefox

# View what's in the local repo
epm repo list | grep local-repo

# Apply changes to the system image
epm commit
```

## Repository Location

Local repository is stored at: `/var/lib/eepm/local-repo`

You can manually manage it using:

```bash
# List packages in local repo
epm repo list local-repo

# Add packages to local repo
epm repo pkgadd /var/lib/eepm/local-repo package1.rpm package2.rpm

# Update repository index
epm repo index /var/lib/eepm/local-repo

# Remove a package from local repo
epm repo pkgdel /var/lib/eepm/local-repo package_name
```

## Configuration Reference

### `/etc/eepm.conf`

```bash
# Use local repository for package installation
# Packages will be added to local repo and installed from there
# Can be set with env var EPM_USE_LOCAL_REPO
#use_local_repo=1
```

### Environment Variables

- `EPM_USE_LOCAL_REPO=1` - Enable local repository installation mode

## See Also

- `epm repo` - Repository management commands
- `epm repo create` - Create a new repository
- `epm repo index` - Update repository index
- `epm play` - Install applications from official sources
