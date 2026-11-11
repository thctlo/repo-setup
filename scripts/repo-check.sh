#!/bin/bash

set -Eeuo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Run this script as root."
    exit 1
fi

APT_BASEDIR="${APT_BASEDIR:-/srv/apt-repo}"
export GNUPGHOME="${GNUPGHOME:-/root/debian-build-server-setup/gnupg}"
REPO_HOST="${REPO_HOST:-localhost}"

reprepro     --basedir="${APT_BASEDIR}"     check     "trixie"

curl     --fail     --silent     --show-error     "http://${REPO_HOST}:8090/debian/dists/trixie/Release"     >/dev/null

curl     --fail     --silent     --show-error     "http://${REPO_HOST}/debian/dists/trixie/Release"     >/dev/null

echo
echo "Repository check: OK"
echo
