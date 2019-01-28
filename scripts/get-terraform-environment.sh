#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
ROOT_DIR="${CURRENT_DIR}/.."

# shellcheck source=/dev/null
. "${ROOT_DIR}/PACKAGE"

TARGET_DIR=$(mktemp -d "${ROOT_DIR}/${DIST_DIR}/terraform-XXXXXX")

echo "Creating environment in ${TARGET_DIR}"

# Copy modules to target directory.
rsync -rv --exclude=.git "${ROOT_DIR}/modules" "${TARGET_DIR}"

# Localize the module sources.
"${DIST_DIR}/module-source-converter" -modules-dir "${TARGET_DIR}/modules"

# Copy examples.
rsync -rv "${ROOT_DIR}/examples" "${TARGET_DIR}"

cd "${TARGET_DIR}/examples/aws"
terraform init

echo "-----------------------------------------------"
echo "AWS: ${TARGET_DIR}/examples/aws"
