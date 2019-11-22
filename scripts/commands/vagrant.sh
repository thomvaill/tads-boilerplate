#!/usr/bin/env bash
# T.A.D.S. vagrant command
#
# Usage: ./tads vagrant COMMAND
#

set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly ROOT_PATH="$(cd "${SELF_PATH}/../.." && pwd)"

readonly TADS_MIN_VAGRANT_VERSION="2.0"

# shellcheck source=scripts/includes/common.sh
source "${SELF_PATH}/../includes/common.sh"

usage() {
    local cmd="./tads"

    cat <<- EOF

Usage: ${cmd} vagrant COMMAND

Use Vagrant to create VMs locally for test purpose

COMMANDS:
    up               Create the VMs
    destroy          Destroy the VMs
    ssh              SSH into a VM
    ...              ...

To list other Vagrant commands and options, run: vagrant --help


EOF
    exit 1
}

vagrant_cmd() {
    if ! command -v vagrant > /dev/null; then
        echo_red "Vagrant must be installed on your local machine. Please referer to README.md to see how."
        exit 1
    fi

    local current_vagrant_version
    current_vagrant_version="$(vagrant --version | head -n1 | cut -d " " -f2 || true)"

    if ! is_version_gte "${current_vagrant_version}" "${TADS_MIN_VAGRANT_VERSION}"; then
        echo_red "Your Vagrant version (${current_vagrant_version}) is not supported by T.A.D.S."
        echo_red "Please upgrade it to at least version ${TADS_MIN_VAGRANT_VERSION}"
        exit 1
    fi

    if ! command -v vboxmanage > /dev/null; then
        echo_red "VirtualBox must be installed on your local machine. Please referer to README.md to see how."
        exit 1
    fi

    if [[ ! -f "${ROOT_PATH}/vagrant/vagrant.yml" ]]; then
        echo_red "Please copy vagrant/vagrant.sample.yml to vagrant/vagrant.yml and edit it first!"
        exit 1
    fi

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    (cd "${ROOT_PATH}/vagrant"; vagrant "$@")
    set +x
}

main () {
    if [[ "$#" -lt 1 ]]; then
        usage
    fi

    vagrant_cmd "$@"
}

main "$@"
