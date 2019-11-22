#!/usr/bin/env bash

remote_ansible_checks () {
    local environment="$1"

    local inventory_path="${ROOT_PATH}/ansible/inventories/${environment}"
    if [[ ! -f "${inventory_path}" ]]; then
        echo_red "Unknown ENVIRONMENT: ${environment}"
        echo_red "If it's a Terraform environment, please run: ./tads terraform ${environment} apply"
        echo_red "Otherwise, please create ${inventory_path}"
        exit 1
    fi
}

remote_ansible_playbook () {
    local environment="$1"
    shift

    remote_ansible_checks "${environment}"

    local vault_key_path="${ROOT_PATH}/ansible/vault_keys/${environment}"
    if [[ ! -f "${vault_key_path}" ]]; then
        echo_red "Vault key not found for ENVIRONMENT: ${environment}"
        echo_red "If it's a new project, run this command to create it: ./tads ansible-vault ${environment} init-key"
        echo_red "Otherwise, please create ${vault_key_path} and paste the key in it"
        exit 1
    fi

    local inventory_path="${ROOT_PATH}/ansible/inventories/${environment}"
    local vault_key_path="${ROOT_PATH}/ansible/vault_keys/${environment}"

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible-playbook -i "${inventory_path}" -D --vault-id "${environment}@${vault_key_path}" "$@"
    set +x
}

remote_ansible () {
    local environment="$1"
    shift

    remote_ansible_checks "${environment}"

    local inventory_path="${ROOT_PATH}/ansible/inventories/${environment}"

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible -i "${inventory_path}" -D "$@"
    set +x
}
