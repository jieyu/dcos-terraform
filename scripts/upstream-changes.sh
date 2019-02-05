#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
ROOT_DIR="${CURRENT_DIR}/.."

# shellcheck source=/dev/null
. "${ROOT_DIR}/PACKAGE"

BRANCH=${BRANCH:-"default-branch"}

git checkout "${BRANCH}" || git checkout -b "${BRANCH}"

if [ -n "$(git status --porcelain --untracked-files=all)" ]; then
  git add -A

  if [ -n "${AMMEND:-""}" ]; then
    git commit --amend
  else
    git commit
  fi
fi

if [ -n "$(git diff master)" ]; then
  if [ -n "${FORCE_PUSH:-""}" ]; then
    git push origin "${BRANCH}" --force
  else
    git push origin "${BRANCH}"
  fi

  if [ -n "${SUBMIT_PR:-""}" ]; then
    hub pull-request
  fi
fi
