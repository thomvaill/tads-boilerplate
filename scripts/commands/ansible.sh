#!/usr/bin/env bash
# T.A.D.S. ansible command
#
# Usage: ./tads ansible ENVIRONMENT COMMAND
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

Usage: ${cmd} ansible ENVIRONMENT <TARGET> <ANSIBLE OPTIONS>

Execute a custom Ansible module on your VMs

Examples:
    ${cmd} ansible vagrant docker --become -m apt -a "update_cache=yes upgrade=safe"
    ${cmd} ansible vagrant docker -m shell -a "echo 'test' > /tmp/test"

To get some help, run: ansible --help

ENVIRONMENTS:
    localhost        Your local machine, for development
    vagrant          A local Docker Swarm cluster, made of Vagrant VMs, for testing
${environments}

EOF
    exit 1
}

main () {
    local environment="${1:-}"

    case "${environment}" in
        localhost)
            shift
            check_ansible
            # shellcheck source=scripts/includes/localhost_ansible.sh
            source "${SELF_PATH}/../includes/localhost_ansible.sh"
            localhost_ansible "$@"
            ;;
        vagrant)
            shift
            check_ansible
            # shellcheck source=scripts/includes/vagrant_ansible.sh
            source "${SELF_PATH}/../includes/vagrant_ansible.sh"
            vagrant_ansible "$@"
            ;;
        "")
            usage
            ;;
        *)
            shift
            check_ansible
            # shellcheck source=scripts/includes/remote_ansible.sh
            source "${SELF_PATH}/../includes/remote_ansible.sh"
            remote_ansible "${environment}" "$@"
            ;;
    esac
}

main "$@"
