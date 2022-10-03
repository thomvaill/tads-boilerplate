#!/usr/bin/env bash

readonly TADS_MIN_ANSIBLE_VERSION="2.8"

# Global Ansible config
export ANSIBLE_DEPRECATION_WARNINGS="False"

get_ansible_remote_environments () {
    # Test for Mac GNU ls command (installed in `ansible/install-dependencies.yml`)
    if [ -f /usr/local/opt/coreutils/libexec/gnubin/ls ] ; then
        /usr/local/opt/coreutils/libexec/gnubin/ls -1 -I "localhost" -I "*.sample*" "${ROOT_PATH}/ansible/inventories"
    else
        ls -1 -I "localhost" -I "*.sample*" "${ROOT_PATH}/ansible/inventories"
    fi
}

check_ansible () {
    if ! command -v ansible > /dev/null; then
        echo_red "Ansible must be installed on your local machine. Please referer to README.md to see how."
        exit 1
    fi

    local current_ansible_version
    current_ansible_version="$(ansible --version | head -n1 | cut -d " " -f3 | cut -c1-4)"

    if ! is_version_gte "${current_ansible_version}" "${TADS_MIN_ANSIBLE_VERSION}"; then
        echo_red "Your Ansible version (${current_ansible_version}) is not supported by T.A.D.S."
        echo_red "Please upgrade it to at least version ${TADS_MIN_ANSIBLE_VERSION}"
        exit 1
    fi
}
