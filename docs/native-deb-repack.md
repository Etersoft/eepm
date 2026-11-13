# Native DEB repacking

The native backend repacks DEB packages directly using Debian packaging tools.
Enable it by adding the following line to a reviewed repack recipe:

```sh
# EPM_REPACK_BACKEND: native-deb
```

It is selected only for DEB input on a DEB target. RPM inputs, other targets
and recipes without the marker retain the existing repack path. Recipe
selection, including `EPM_REPACK_SCRIPT`, uses the normal resolver.

Use the normal installation commands; no additional backend option is needed:

```sh
epm install --repack ./package.deb
epm install --repack ./component.deb ./client.deb
```

`epm play` also selects the backend when its installation path requests
repacking and the resolved recipe has the marker. Before enabling an existing
recipe, adapt its dependency declarations and metadata helpers to the Recipe
API below.

All eligible artifacts are extracted before recipes run. All recipes finish
before dependency scanning and building. The caller installs the resulting
set in one transaction. The native worker does not run vendor maintainer
scripts during repacking. They remain in the package for dpkg to execute at
installation/removal time. Recipes are trusted code, not sandboxed code.

## Version and metadata

The default version is `[epoch:]upstream-epm1.repacked.revision`. A source
without a Debian revision uses `1`. `EPM_REPACK_VERSION` overrides the
upstream part, including its optional epoch; `EPM_REPACK_RELEASE` overrides
the revision. For example, `2:1.2~rc1-4` becomes
`2:1.2~rc1-epm1.repacked.4`. Already repacked input is rejected.

Debian exact dependencies compare the whole version, including the revision.
For a dependency on another repacked component in the same set, use
`set_deb_requires_version component` to update the equality to its output
version.

Control metadata is read and written with `Dpkg::Control` and relationships
with `Dpkg::Deps`. Original fields and maintainer scripts are preserved unless
the recipe changes them. Version and Installed-Size are updated, md5sums are
regenerated, and `X-Epm-Repacked: 1` identifies the native output. RPM/Alien
and RPM-to-DEB dependency-name conversion are not used by this backend.

## Recipe API

`BUILDROOT` is an extracted Debian tree with `DEBIAN/` metadata; `SPEC` is
empty. The package name and original source remain arguments 3 and 4.

* Existing file helpers operate on the tree. `pack_file` and `pack_dir` are
  no-ops because dpkg includes the complete tree. Conffile paths must remain
  valid; a recipe changing them must update `DEBIAN/conffiles` explicitly.
* `add_requires` accepts Debian relationships, for example
  `add_requires 'libc6 (>= 2.34)' 'bash | dash'`.
* `set_deb_requires_version component` changes exactly one `Depends` equality
  from that sibling's original version to its prepared version. A missing
  sibling or unmatched relation is an error, not an implicit downgrade.
* `scan_deb_requires /opt/app` enables scanning and declares private library
  directories inside this package. Call it after moving files.
* `add_deb_library_provider component` explicitly adds a sibling's declared
  private library paths. That sibling must also request scanning.

Inactive bundled files that introduce unwanted dependencies should be removed
by the recipe, not hidden from the scanner.

Dependency relations are preserved unless explicitly changed by the recipe.
Recipes must not pass RPM capabilities to
`add_requires`, use RPM-only metadata helpers, or create `.eepm*` markers.
An unported recipe must not opt in. Existing recipes are not enabled globally.

Scanning uses `dh_makeshlibs` and `dh_shlibdeps` after every sibling has been
prepared. Temporary private-provider shlibs are removed before packaging;
original vendor shlibs, if present, are restored. Missing library information
is not ignored. The build environment must have the Debian packages needed
to resolve system library dependencies.

## Current limits

Only native-architecture builds are validated. Dependency names must match
the target Debian system. Artifact paths must not contain whitespace.
Upstream control symlinks and payload
links escaping the tree, pointing to directories, or dangling are rejected
before recipes execute. This conservative policy requires explicit review
before enabling additional recipes. Native helpers do not emulate every
RPM-spec helper or migrate arbitrary conffiles automatically.
