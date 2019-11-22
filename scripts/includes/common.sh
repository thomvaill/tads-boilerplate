#!/usr/bin/env bash

echo_red () {
    local red
    local reset
    red=$(tput setaf 1)
    reset=$(tput sgr0)
    echo -e "${red}" "$@" "${reset}"
}

is_version_gte () {
    local current_version="$1"
    local required_version="$2"

    [[ ! ${current_version} =~ ^[0-9\.]*$ ]] && exit 1
    [[ ! ${required_version} =~ ^[0-9\.]*$ ]] && exit 1

    [[ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -n1)" == "$required_version" ]]
}
