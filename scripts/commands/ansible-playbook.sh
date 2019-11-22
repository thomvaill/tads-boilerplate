#!/usr/bin/env bash
# T.A.D.S. ansible-playbook command
#
# Usage: ./tads ansible-playbook ENVIRONMENT PLAYBOOK [ANSIBLE OPTIONS]
#

set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly ROOT_PATH="$(cd "${SELF_PATH}/../.." && pwd)"

# shellcheck source=scripts/includes/common.sh
source "${SELF_PATH}/../includes/common.sh"

# shellcheck source=scripts/includes/ansible.sh
source "${SELF_PATH}/../includes/ansible.sh"

usage() {
    local cmd="./tads"

    local environments
    environments="$(get_ansible_remote_environments | awk '{ print "    " $1 }')"

    cat <<- EOF

Usage: ${cmd} ansible-playbook ENVIRONMENT PLAYBOOK [ANSIBLE OPTIONS]

Use Ansible to execute a playbook on your VMs.

ANSIBLE OPTIONS:
    -C, --check      Don't make any changes; instead,
                     try to predict some of the changes that may occur
    -l SUBSET, --limit=SUBSET
                     Further limit selected hosts to an additional pattern
    --list-hosts     Outputs a list of matching hosts; does not execute
    --list-tags      List all available tags
    --list-tasks     List all tasks that would be executed
    --skip-tags=SKIP_TAGS
                     Only run plays and tasks whose tags do not match these values
    --step           One-step-at-a-time: confirm each task before running
    --syntax-check   Perform a syntax check on the playbook, but do not execute it
    -t TAGS, --tags=TAGS
                     Only run plays and tasks tagged with these values

To list other Ansible options, run: ansible-playbook --help

PLAYBOOKS:
    provision        Provision your VMs: configure hosts, install Docker, set up Docker Swarm
    deploy           Deploy your applicative stacks on the Swarm
    all              Provision and deploy in a single command

ENVIRONMENTS:
    localhost        Your local machine, for development
    vagrant          A local Docker Swarm cluster, made of Vagrant VMs, for testing
${environments}

EOF
    exit 1
}

install_ansible_roles () {
    ansible-galaxy role install -r "${ROOT_PATH}/ansible/requirements.yml"
}

main () {
    local environment="${1:-}"
    local playbook="${2:-}"

    if [[ -z "${playbook}" ]]; then
        usage
    fi

    case "${environment}" in
        localhost)
            shift 2
            check_ansible
            install_ansible_roles
            # shellcheck source=scripts/includes/localhost_ansible.sh
            source "${SELF_PATH}/../includes/localhost_ansible.sh"
            if [[ "${playbook}" == "provision" || "${playbook}" == "all" ]]; then
                echo "You will be asked by Ansible to enter your account password to perform SUDO operations..."
                localhost_ansible_playbook "${ROOT_PATH}/ansible/${playbook}.yml" --ask-become-pass "$@"
            else
                localhost_ansible_playbook "${ROOT_PATH}/ansible/${playbook}.yml" "$@"
            fi
            ;;
        vagrant)
            shift 2
            check_ansible
            install_ansible_roles
            # shellcheck source=scripts/includes/vagrant_ansible.sh
            source "${SELF_PATH}/../includes/vagrant_ansible.sh"
            if [[ "${playbook}" == "provision" || "${playbook}" == "all" ]]; then
                echo "You will be asked by Ansible to enter your account password to perform SUDO operations..."
                vagrant_ansible_playbook "${ROOT_PATH}/ansible/${playbook}.yml" --ask-become-pass "$@"
            else
                vagrant_ansible_playbook "${ROOT_PATH}/ansible/${playbook}.yml" "$@"
            fi
            ;;
        "")
            usage
            ;;
        *)
            shift 2
            check_ansible
            install_ansible_roles
            # shellcheck source=scripts/includes/remote_ansible.sh
            source "${SELF_PATH}/../includes/remote_ansible.sh"
            remote_ansible_playbook "${environment}" "${ROOT_PATH}/ansible/${playbook}.yml" "$@"
            ;;
    esac
}

main "$@"
