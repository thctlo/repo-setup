#!/bin/bash

set -Eeuo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "This operation must be run as root."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo
    echo "Usage:"
    echo "  repo-add.sh /srv/build/results/package.changes"
    echo
    exit 1
fi

CHANGES="$1"

if [[ ! -f "${CHANGES}" ]]; then
    echo "ERROR: ${CHANGES} does not exist."
    exit 1
fi

# All overridable so this script works unchanged on a different build host -
# the defaults match this project's own setup.
APT_BASEDIR="${APT_BASEDIR:-/srv/apt-repo}"
export GNUPGHOME="${GNUPGHOME:-/root/debian-build-server-setup/gnupg}"
REPO_HOST="${REPO_HOST:-localhost}"

mkdir -p /run/lock

flock     /run/lock/mycustom-reprepro.lock     reprepro         --basedir="${APT_BASEDIR}"              --ignore=surprisingarch        include         "trixie"         "${CHANGES}"


echo
echo "Repository updated."
echo
echo "Repository:"
echo "  http://${REPO_HOST}:8090/debian/"
echo "  http://${REPO_HOST}/debian/"

#
# Binary: can wrap across indented continuation lines in a .changes
# file when there are many binary packages -- this collects the full
# field, not just its first line.
#
BINARY_PACKAGES="$(
    awk '
        /^Binary:/ { sub(/^Binary: */, ""); inField=1; print; next }
        inField && /^[[:space:]]/ { print; next }
        { inField=0 }
    ' "${CHANGES}" | tr -s '[:space:]' ' '
)"

if [[ -n "${BINARY_PACKAGES}" ]]; then
    echo
    echo "Now listed in trixie:"
    echo

    for pkg in ${BINARY_PACKAGES}; do
        reprepro             --basedir="${APT_BASEDIR}"           --ignore=surprisingarch       list             "trixie"             "${pkg}"

    done
fi

echo
