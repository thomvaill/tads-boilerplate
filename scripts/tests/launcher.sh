#!/usr/bin/env bash
set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly ROOT_PATH="$(cd "${SELF_PATH}/../.." && pwd)"

# We run the tests with Docker so we have a fresh environment with nothing installed

docker build -t tads-scripts-tests "${SELF_PATH}"

docker run \
    --rm \
    -ti \
    -e TESTS_DOCKER=true \
    -e "DEBUG=${DEBUG:-}" \
    -v "${ROOT_PATH}":/tmp/tads-host:ro \
    tads-scripts-tests \
    /tmp/tads/scripts/tests/tests.sh
