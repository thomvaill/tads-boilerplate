#!/usr/bin/env bash
set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly ROOT_PATH="$(cd "${SELF_PATH}/../.." && pwd)"

"${ROOT_PATH}"/scripts/tests/launcher.sh
while inotifywait -e close_write "${ROOT_PATH}"/scripts/**/*.sh "${ROOT_PATH}/tads"; do
    "${ROOT_PATH}"/scripts/tests/launcher.sh
done
