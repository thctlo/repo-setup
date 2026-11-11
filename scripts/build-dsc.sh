#!/bin/bash

set -Eeuo pipefail

if [[ "$(id -un)" != "builder" ]]; then
    echo "Run this script as builder."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo
    echo "Usage:"
    echo "  build-dsc.sh /path/to/package.dsc"
    echo
    exit 1
fi

DSC="$1"

if [[ ! -f "${DSC}" ]]; then
    echo "ERROR: ${DSC} does not exist."
    exit 1
fi

#
# --debbuildopt=-sa forces the .changes to always include the
# .orig.tar.gz. Without it, dpkg-genchanges omits the orig tarball
# whenever only the Debian revision changed (not the upstream
# version) -- a correct assumption for the real Debian archive,
# where a prior revision's tarball is already there, but wrong here:
# this repository has no such history, so the very first upload of
# any given upstream version must include it or reprepro can't
# resolve the .dsc's reference to it.
#
RESULTS_DIR="${RESULTS_DIR:-/srv/build/results}"
REPO_ADD_SH="${REPO_ADD_SH:-/srv/build/scripts/repo-add.sh}"

sbuild     --chroot-mode=unshare     --dist=trixie     --arch=amd64     --debbuildopt=-sa     "${DSC}"

NEW_CHANGES="$(ls -t "${RESULTS_DIR}"/*.changes 2>/dev/null | head -1)"

echo
echo "Build succeeded:"

if [[ -n "${NEW_CHANGES}" ]]; then
    echo "  ${NEW_CHANGES}"
    echo
    echo "Publish it with:"
    echo
    echo "  sudo ${REPO_ADD_SH} ${NEW_CHANGES}"
else
    echo "  (no .changes file found in ${RESULTS_DIR} -- check the output above)"
fi

echo
