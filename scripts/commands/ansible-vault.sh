#!/usr/bin/env bash
# T.A.D.S. ansible-vault command
#
# Usage: ./tads ansible-vault ENVIRONMENT COMMAND
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

Usage: ${cmd} ansible-vault ENVIRONMENT COMMAND <file>

Use ansible-vault to encrypt your sensitive files, e.g. ansible/group_vars/production_encrypted.yml

COMMANDS:
    init-key                Generate a random key into ansible/vault_keys/ENVIRONMENT;
                             should be executed only at the beginning of the project
    create   <file>         Create a new encrypted file
    encrypt  <file>         Encrypt the given file
    decrypt  <file>         Decrypt the given file
    edit     <file>         Edit the given file in place
    view     <file>         View the given file
    ...                     ...

To list other ansible-vault commands and options, run: ansible-vault --help

ENVIRONMENTS:
${environments}

EOF
    exit 1
}

init_ansible_vault_key () {
    local environment="$1"
    local key_path="${ROOT_PATH}/ansible/vault_keys/${environment}"

    if [[ -f "${key_path}" ]]; then
        echo_red "${key_path} already exists. Abort."
        exit 1
    fi

    local key
    key="$(LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 256 || true)"
    echo "${key}" > "${key_path}"

    echo "A new key has been generated in ${key_path}"
    echo " - keep this key secret"
    echo " - do not commit it"
    echo " - share it securely to your other authorized team members"
    echo " - do not lost it, you would not be able to decrypt your files!"
}

ansible_vault_cmd() {
    local environment="$1"
    shift
    local key_path="${ROOT_PATH}/ansible/vault_keys/${environment}"

    if [[ ! -f "${key_path}" ]]; then
        echo_red "Vault key not found for ENVIRONMENT: ${environment}"
        echo_red "If it's a new project, run this command to create it: ./tads ansible-vault ${environment} init-key"
        echo_red "Otherwise, please create ${key_path} and paste the key in it"
        exit 1
    fi

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible-vault "$@" --vault-id "${environment}@${key_path}"
    set +x
}

main () {
    if [[ "$#" -lt 2 ]]; then
        usage
    fi

    check_ansible

    local environment="$1"
    local command="$2"

    case "${command}" in
        "init-key")
            init_ansible_vault_key "${environment}"
            ;;
        *)
            ansible_vault_cmd "$@"
            ;;
    esac
}

main "$@"
