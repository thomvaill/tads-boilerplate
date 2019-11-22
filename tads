#!/usr/bin/env bash
# T.A.D.S. main script
#
# Usage: ./tads COMMAND
#

set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"

# shellcheck source=scripts/includes/common.sh
source "${SELF_PATH}/scripts/includes/common.sh"

if [[ "${TADS_ENV:-}" == "test" ]]; then
    export TADS_VERBOSE=false
else
    export TADS_VERBOSE=true
fi

usage() {
    local error_msg=${1:-}
    local cmd="./${SELF_NAME}"

    if [[ -n $error_msg ]]; then
        echo ""
        echo_red "${error_msg}"
    fi

    cat <<- EOF

Usage: ${cmd} COMMAND

A companion CLI to perform Terraform, Ansible and Docker Swarm (T.A.D.S.) tasks easily

COMMANDS:
    install-dependencies    Install T.A.D.S. dependencies
    vagrant                 Manage your local VMs (for test purpose)
    terraform               Manage your cloud VMs
    ansible                 Execute a custom Ansible module on your VMs
    ansible-vault           Manage your sensitive files
    ansible-playbook        Execute an Ansible playbook on your VMs (provision or deploy)

Run ${cmd} COMMAND to get some help regarding a specific command

EOF
    exit 1
}

main () {
    local command="${1:-}"
    local commands_path="${SELF_PATH}/scripts/commands"

    case "${command}" in
        install-dependencies)
            shift
            "${commands_path}/install-dependencies.sh" "$@"
            ;;
        vagrant)
            shift
            "${commands_path}/vagrant.sh" "$@"
            ;;
        terraform)
            shift
            "${commands_path}/terraform.sh" "$@"
            ;;
        ansible)
            shift
            "${commands_path}/ansible.sh" "$@"
            ;;
        ansible-vault)
            shift
            "${commands_path}/ansible-vault.sh" "$@"
            ;;
        ansible-playbook)
            shift
            "${commands_path}/ansible-playbook.sh" "$@"
            ;;
        "")
            usage
            ;;
        *)
            usage "Unknown COMMAND: ${command}"
            ;;
    esac
}

main "$@"
