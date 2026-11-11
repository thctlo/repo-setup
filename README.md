# repo-setup

Shared tooling for building and publishing this project's own Debian
packages (a [reprepro](https://wiki.debian.org/DebianRepository/SetupWithReprepro)
repository for Debian 13 / trixie), plus `packages.md` - an index of
every package we maintain, what tier it is (pure rebuild / patches on
a community package / fully original), and where its own source lives.

This repo is the **orchestration** layer only - it does not contain
any package's actual source or patches. Each patched or original
package gets its own repository; see `packages.md` for the current
list.

**Looking to set up a server that *uses* these packages, rather than
build them?** This repo is the build-host side only. See
[`grommunio-hardened-setup`](https://github.com/thctlo/grommunio-hardened-setup)'s
[`docs/INSTALL.md`](https://github.com/thctlo/grommunio-hardened-setup/blob/main/docs/INSTALL.md)
for the full server setup walkthrough, and that project's
[`docs/custom-repo/README.md`](https://github.com/thctlo/grommunio-hardened-setup/blob/main/docs/custom-repo/README.md)
for how a server consumes the packages built here.

## Layout

- `reprepro/conf/` — the reprepro `distributions`/`options` files for
  this repository (`trixie|main`, signed with the GPG key listed
  there by fingerprint only - never the private key itself).
- `scripts/` — `build-dsc.sh` (sbuild wrapper), `repo-add.sh` (publish
  a build's `.changes` into the repo), `repo-check.sh` (verify the
  repo and its signature are intact and being served correctly).
- `packages.md` — the package index described above.

## Setting this up on a new build host

1. Install `reprepro`, `sbuild`, `mmdebstrap`, and `gnupg` if you
   intend to sign (see step 4).
2. `build-dsc.sh` uses `sbuild --chroot-mode=unshare` - no schroot or
   sudo setup needed, just:
   - Your build user must be in the `sbuild` group
     (`sudo usermod -aG sbuild $USER`, then log out/in again).
   - A chroot tarball must exist at `~/.cache/sbuild/<dist>-<arch>.tar`
     (sbuild does not create this itself). Build one with `mmdebstrap`:
     ```
     mmdebstrap --arch=amd64 --variant=buildd trixie \
         ~/.cache/sbuild/trixie-amd64.tar http://deb.debian.org/debian
     ```
     (substitute your own distribution/arch to match what you pass to
     `build-dsc.sh`/`sbuild --dist=`). No other sbuild config is
     needed - `/etc/sbuild/sbuild.conf` and `~/.sbuildrc` can stay at
     their defaults.
3. `mkdir -p /srv/apt-repo && cp -r reprepro/conf /srv/apt-repo/conf`
   (or point `APT_BASEDIR` at wherever you keep it - see below).
4. Signing is optional - `reprepro/conf/distributions` ships without
   a `SignWith:` line, so the repo builds unsigned by default and
   works as-is. To sign it, generate or import a GPG key and add
   `SignWith: <fingerprint>` to that file yourself (see the comment
   in the file for what that changes for apt clients).
5. Serve `/srv/apt-repo` over HTTP (any web server) so clients can
   `apt` from it.

## Scripts

All three scripts are configurable via environment variables instead
of hardcoded paths, so they work unchanged on a different build host:

| Script | Variables (defaults shown) |
|---|---|
| `build-dsc.sh` | `RESULTS_DIR=/srv/build/results`, `REPO_ADD_SH=/srv/build/scripts/repo-add.sh` |
| `repo-add.sh` | `APT_BASEDIR=/srv/apt-repo`, `GNUPGHOME=/root/debian-build-server-setup/gnupg`, `REPO_HOST=localhost` |
| `repo-check.sh` | `APT_BASEDIR=/srv/apt-repo`, `GNUPGHOME=/root/debian-build-server-setup/gnupg`, `REPO_HOST=localhost` |

Typical flow:

```
build-dsc.sh path/to/package.dsc
# ... review the build output ...
sudo repo-add.sh /srv/build/results/package_amd64.changes
sudo repo-check.sh
```

## Adding a package

1. Decide its tier (see `packages.md`'s own header for the
   definitions).
2. Tier 1 (pure rebuild): just add a row to `packages.md` - no repo
   needed.
3. Tier 2/3: create a new repo containing either just `debian/`
   (tier 2 - verify every patch still applies cleanly against a fresh
   extraction of the matching upstream orig tarball before
   committing) or the full source (tier 3), then add a row to
   `packages.md` linking to it.
