# Packages

Every package currently published in this project's own apt repository
(`trixie|main`), what tier it is, and where its source lives. Scope:
only packages actually published and in live use (on testvps) so far -
see "Not yet covered" at the bottom for everything else we have built
at some point but haven't organized into its own repo yet.

## Tier 1 — pure rebuilds, no patches of our own

Nothing to version here beyond this table: the source is identical to
the community/upstream one, just rebuilt for Debian 13 (trixie).

| Package | Version | Upstream source |
|---|---|---|
| `imapsync` | 2.314+ds-1 | Debian's own `imapsync` source package |
| `mapitags` | 20240617-2 | grommunio community source |

## Tier 2 — patched community packages

Own repo per package, containing only `debian/` (patches + changelog +
packaging) - the orig tarball comes from the community source at build
time.

| Package | Version | Repo | Visibility |
|---|---|---|---|
| `grommunio-archive` | 1.4.9-5 | `grommunio-archive` | public |

## Tier 3 — fully original packages

Own repo per package, full source + packaging - this is software we
wrote, not a patch on someone else's.

| Package | Version | Repo | Visibility |
|---|---|---|---|
| `certbot-dns-transip` | 0.2.3 | `certbot-dns-transip` | public |
| `transip-rest` (CLI: `transip-dns`) | 0.3 | `transip-rest` | public |

## Not yet covered

Built and rebuilt at various points, real patches exist for some of
these, but none are currently published in the live apt repo and none
have their own repo yet: `grommunio-cui`/`cui`, `libconfuse`, `libhx`,
`libnginx-mod-http-zstd`, `libpff`, `mapi-header-php`, `wmime`. Add a
row above (and set up its own repo, same pattern as `grommunio-archive`)
if/when one of these gets published for real use.
