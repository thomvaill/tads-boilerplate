#!/usr/bin/env bash

vagrant_ansible_checks () {
    local vagrant_inventory_path="${ROOT_PATH}/vagrant/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
    if [[ ! -f "${vagrant_inventory_path}" ]]; then
        echo_red "Impossible to find vagrant auto-generated inventory file"
        echo_red "Please run: ./tads vagrant up"
        echo_red "If you still get this error, you can try: ./tads vagrant provision"
        exit 1
    fi
}

vagrant_ansible_playbook () {
    local vagrant_inventory_path="${ROOT_PATH}/vagrant/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"

    vagrant_ansible_checks

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible-playbook -i "${vagrant_inventory_path}" -D "$@"
    set +x
}

vagrant_ansible () {
    local vagrant_inventory_path="${ROOT_PATH}/vagrant/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"

    vagrant_ansible_checks

    [[ "${TADS_VERBOSE:-}" == true ]] &&  set -x
    ansible -i "${vagrant_inventory_path}" -D "$@"
    set +x
}
