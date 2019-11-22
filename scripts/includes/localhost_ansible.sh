#!/usr/bin/env bash

localhost_ansible_playbook () {
    local localhost_inventory_path="${ROOT_PATH}/ansible/inventories/localhost"

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible-playbook -i "${localhost_inventory_path}" -D -c local "$@"
    set +x
}

localhost_ansible () {
    local localhost_inventory_path="${ROOT_PATH}/ansible/inventories/localhost"

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible -i "${localhost_inventory_path}" -D -c local "$@"
    set +x
}
