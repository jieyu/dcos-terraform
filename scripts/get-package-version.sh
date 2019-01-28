#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

PACKAGE_SHA=${PACKAGE_SHA:-$(git rev-parse --short HEAD)}
PACKAGE_VERSION=$(git describe --tags --match 'v*' --exact-match "${PACKAGE_SHA}" 2>/dev/null || echo "${PACKAGE_SHA}")

if [ "${PACKAGE_SHA}" != "${PACKAGE_VERSION}" ]; then
  echo "${PACKAGE_VERSION}"
  exit 0
fi

# Get all release branches in the format of `vX.Y.Z` and sort them.
UNSORTED_RELEASE_BRANCHES=$(git branch -a | grep -E 'origin/releases/v.*x' | grep -E -o 'v.*x' || true)
SORTED_RELEASE_BRANCHES=$(echo "${UNSORTED_RELEASE_BRANCHES}" | sort -t '.' -k 2 -n)

# Get the latest release branch in the format of `vX.Y.Z`.
if [ -z "${SORTED_RELEASE_BRANCHES}" ]; then
  LATEST_RELEASE_BRANCH="v0.0.x"
else
  LATEST_RELEASE_BRANCH=$(echo "${SORTED_RELEASE_BRANCHES}" | tail -n 1)
fi

LATEST_RELEASE_BRANCH_MAJOR=$(echo "${LATEST_RELEASE_BRANCH}" | grep -E -o '[0-9]+\.[0-9]+' | cut -d '.' -f 1)
LATEST_RELEASE_BRANCH_MINOR=$(echo "${LATEST_RELEASE_BRANCH}" | grep -E -o '[0-9]+\.[0-9]+' | cut -d '.' -f 2)

# Get the release branch in the format of `vX.Y.Z` that the current
# HEAD is on.
CURRENT_RELEASE_BRANCH=$(git branch --points-at HEAD -r | grep -E 'origin/releases/v.*x' | grep -E -o 'v.*x' || true)

if [ -z "${CURRENT_RELEASE_BRANCH}" ]; then
  # HEAD is not on a release branch.
  MAJOR_VERSION="${LATEST_RELEASE_BRANCH_MAJOR}"
  MINOR_VERSION=$(( LATEST_RELEASE_BRANCH_MINOR + 1 ))
  RELEASE="-SNAPSHOT-${PACKAGE_SHA}"

  echo "v${MAJOR_VERSION}.${MINOR_VERSION}.0${RELEASE}"
else
  # HEAD is on a release branch.
  CURRENT_RELEASE_BRANCH_MAJOR=$(echo "${CURRENT_RELEASE_BRANCH}" | grep -E -o '[0-9]+\.[0-9]+' | cut -d '.' -f 1)
  CURRENT_RELEASE_BRANCH_MINOR=$(echo "${CURRENT_RELEASE_BRANCH}" | grep -E -o '[0-9]+\.[0-9]+' | cut -d '.' -f 2)

  MAJOR_VERSION="${CURRENT_RELEASE_BRANCH_MAJOR}"
  MINOR_VERSION="${CURRENT_RELEASE_BRANCH_MINOR}"
  PATCH_VERSION="0"
  RELEASE=""

  RELEASE_TAG_RAW=$(git describe --tags --exclude 'v*-rc*' 2>/dev/null || true)
  RELEASE_TAG=$(echo "${RELEASE_TAG_RAW}" | grep -E -o 'v[0-9]+\.[0-9]+\.[0-9]+' || true)

  # It's possible that the release branch is cut, but there is no
  # release yet. In that case, we use the default patch version "0".
  if [[ -z "${RELEASE_TAG}" ]]; then
    RELEASE="-SNAPSHOT-${PACKAGE_SHA}"
  else
    RELEASE_TAG_MAJOR=$(echo "${RELEASE_TAG}" | grep -E -o '[0-9]+\.[0-9]+\.[0-9]+' | cut -d '.' -f 1)
    RELEASE_TAG_MINOR=$(echo "${RELEASE_TAG}" | grep -E -o '[0-9]+\.[0-9]+\.[0-9]+' | cut -d '.' -f 2)
    RELEASE_TAG_PATCH=$(echo "${RELEASE_TAG}" | grep -E -o '[0-9]+\.[0-9]+\.[0-9]+' | cut -d '.' -f 3)

    if [[ "${CURRENT_RELEASE_BRANCH_MAJOR}" == "${RELEASE_TAG_MAJOR}" && \
          "${CURRENT_RELEASE_BRANCH_MINOR}" == "${RELEASE_TAG_MINOR}" ]]; then
      PATCH_VERSION=$(( RELEASE_TAG_PATCH + 1 ))
      RELEASE="-SNAPSHOT-${PACKAGE_SHA}"
    fi
  fi

  echo "v${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}${RELEASE}"
fi
