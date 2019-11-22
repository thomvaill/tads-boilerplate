#!/usr/bin/env bash

readonly CMD_MOCKS_PATH=/tmp/cmd_mocks
readonly CMD_MOCKS_LOGS_PATH=/tmp/cmd_mocks_logs

setup_mocking () {
    # Add mocks directory to $PATH
    mkdir "${CMD_MOCKS_LOGS_PATH}"
    mkdir "${CMD_MOCKS_PATH}"
    PATH="$PATH:${CMD_MOCKS_PATH}"

    # Init file mocks array
    FILE_MOCKS=()
}

teardown_mocking () {
    # Debug
    if [[ "${TADS_DEBUG:-}" == true ]]; then
        local file
        for file in "${CMD_MOCKS_LOGS_PATH}"/*; do
            [[ "${file}" == "${CMD_MOCKS_LOGS_PATH}/*" ]] && break
            echo "** DEBUG | calls for $(basename "${file}"):"
            cat "${file}"
        done
    fi

    # Remove command mocks
    rm -rf "${CMD_MOCKS_LOGS_PATH}"
    rm -rf "${CMD_MOCKS_PATH}"

    # Remove file mocks
    for file_path in "${FILE_MOCKS[@]}"; do
        rm -rf "${file_path}"
    done
}

mock_command () {
    local command_name
    local command_path
    command_name="$1"
    command_path="${CMD_MOCKS_PATH}/${command_name}"

    local version_string
    version_string="${2:-}"

    local additional_code
    additional_code="${3:-}"

    cat <<EOT >> "${command_path}"
#!/usr/bin/env bash
set -euo pipefail

if [[ "\${1:-}" == "--version" ]]; then
    echo "${version_string}"
fi

echo "\$(basename "\$0") \$@" >> ${CMD_MOCKS_LOGS_PATH}/${command_name}

${additional_code}
EOT

    chmod u+x "${command_path}"
}

assertMockedCmdCalled () {
    local command_name
    local expected_result
    command_name="$1"
    expected_result="$2"

    local result
    [[ -f "${CMD_MOCKS_LOGS_PATH}/${command_name}" ]] \
        && result="$(cat "${CMD_MOCKS_LOGS_PATH}/${command_name}")" || result=""

    assertContains "Mocked '${command_name}' should have been called" "${result}" "${expected_result}"
}

mock_file () {
    local file_path
    local file_dir
    local content
    file_path="$1"
    file_dir="$(dirname "${file_path}")"
    content="${2:-}"

    [[ ! -d "${file_dir}" ]] && mkdir -p "${file_dir}"

    echo "${content}" > "${file_path}"

    FILE_MOCKS+=("${file_path}")
}

assertFileExists () {
    local file_path
    file_path="$1"

    [[ ! -f "${file_path}" ]] && fail "File should exist: ${file_path}"
}

assertFileContentEquals () {
    local file_path
    local expected_content
    file_path="$1"
    expected_content="$2"

    assertFileExists "${file_path}"

    local content
    content="$(cat "${file_path}")"

    assertEquals "File content is not as expected" "${expected_content}" "${content}"
}
