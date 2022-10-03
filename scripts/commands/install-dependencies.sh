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
    local no_password=false
    local force=false
    local dev_dependencies=false

    local options
    options=$(getopt --longoptions no-password,force,dev, --options "" -- "$@")

    eval set -- "$options"
    while true; do
    echo "$1"
        case "$1" in
        --no-password)
            no_password=true
            ;;
        --force)
            force=true
            ;;
        --dev)
            dev_dependencies=true
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    echo "This script will install the following dependencies on your local machine using apt-get:"
    echo " - Ansible"
    echo " - Vagrant and Virtualbox"
    echo " - Terraform"
    echo ""

    if [[ ! "${force}" == true ]]; then
        local response
        read -r -p "Are you sure? [y/N] " response
        if [[ ! "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Aborted."
            exit
        fi
    fi

    echo "Installing Ansible..."
    if ! command -v ansible > /dev/null; then
        if command -v apt-get > /dev/null; then
            echo "Your SUDO password may be asked"

            [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
            sudo apt-get update \
            && sudo apt-get --yes install software-properties-common \
            && sudo apt-add-repository --yes --update ppa:ansible/ansible \
            && sudo apt-get --yes install ansible
            set +x
        else
            echo "Unable to work out how to install Ansible.  Either install it first, manually,"
            echo "or update the ${SELF_PATH}/${SELF_NAME} script"
            echo "to support installing automatically on your OS."
        fi
    else
        echo "Ansible is already installed. Skipping"
    fi

    echo "Installing Vagrant, Virtualbox and Terraform..."

    local playbook_skip_tags="dev_dependencies"
    [[ "${dev_dependencies}" == true ]] && playbook_skip_tags=""

    if [[ "${no_password}" == true ]]; then
        localhost_ansible_playbook "${ROOT_PATH}/ansible/install-dependencies.yml" --skip-tags "${playbook_skip_tags}"
    else
        echo "Your SUDO password will be asked"
        localhost_ansible_playbook "${ROOT_PATH}/ansible/install-dependencies.yml" --skip-tags "${playbook_skip_tags}" --ask-become-pass
    fi

    echo "Finished!"
}

main "$@"
