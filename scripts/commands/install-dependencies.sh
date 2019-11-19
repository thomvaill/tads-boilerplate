#!/usr/bin/env bash
# T.A.D.S. install-dependencies command
#
# Usage: ./tads install-dependencies
#

set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly ROOT_PATH="$(cd "${SELF_PATH}/../.." && pwd)"

# shellcheck source=scripts/includes/common.sh
source "${SELF_PATH}/../includes/common.sh"

# shellcheck source=scripts/includes/localhost_ansible.sh
source "${SELF_PATH}/../includes/localhost_ansible.sh"

main () {
    echo "This script will install the following dependencies on your local machine using apt-get:"
    echo " - Ansible"
    echo " - Vagrant and Virtualbox"
    echo " - Terraform"
    echo ""

    local response
    read -r -p "Are you sure? [y/N] " response
    if [[ ! "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Aborted."
        exit
    fi

    echo "Installing Ansible..."
    if ! dpkg -s ansible > /dev/null; then
        echo "Your SUDO password may be asked"

        set -x
        sudo apt-get update \
        && sudo apt-get --yes install software-properties-common \
        && sudo apt-add-repository --yes --update ppa:ansible/ansible \
        && sudo apt-get --yes install ansible
        set +x
    else
        echo "Ansible is already installed. Skipping"
    fi

    echo "Installing Vagrant, Virtualbox and Terraform..."
    echo "Your SUDO password will be asked"
    localhost_ansible_playbook "${ROOT_PATH}/ansible/install-dependencies.yml" --ask-become-pass

    echo "Finished!"
}

main
