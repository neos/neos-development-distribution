#!/bin/bash

#
# Tags a release in the base distribution, BuildEssentials and all
# framework packages. Requirements in composer manifests are adjusted
# as needed.
#
# Needs the following parameters
#
# VERSION          the version that is "to be released"
# BRANCH           the branch that is worked on
# FLOW_BRANCH      the corresponding Flow branch for the branch that will be created
# BUILD_URL        used in commit message
#

source "$(dirname "${BASH_SOURCE[0]}")/BuildEssentials/ReleaseHelpers.sh"

if [ -z "$1" ]; then
  echo >&2 "No version specified (e.g. 2.1.*) as first parameter"
  exit 1
fi
VERSION="$1"

if [ -z "$2" ]; then
  echo >&2 "No branch specified (e.g. 2.1) as second parameter"
  exit 1
fi
BRANCH="$2"

if [ -z "$3" ]; then
  echo >&2 "No Flow branch specified (e.g. 3.1) as third parameter."
  exit 1
fi
FLOW_BRANCH="$3"

if [ -z "$4" ]; then
  echo >&2 "No build URL specified as fourth parameter."
  exit 1
fi
BUILD_URL="$4"

if [ ! -d "Distribution" ]; then
  echo '"Distribution" folder not found. Clone the base distribution into "Distribution"'
  exit 1
fi

"$(dirname "${BASH_SOURCE[0]}")/set-dependencies.sh" "${VERSION}" "${BRANCH}" "${FLOW_BRANCH}" "${BUILD_URL}" || exit 1

echo "Tagging distribution"
tag_version "${VERSION}" "${BRANCH}" "${BUILD_URL}" "Distribution"
push_branch "${BRANCH}" "Distribution"
push_tag "${VERSION}" "Distribution"

echo "Tagging development collection"
tag_version "${VERSION}" "${BRANCH}" "${BUILD_URL}" "Packages/Neos"
push_branch "${BRANCH}" "Packages/Neos"
push_tag "${VERSION}" "Packages/Neos"

echo "Tagging demo package"
tag_version "${VERSION}" "${BRANCH}" "${BUILD_URL}" "Packages/Sites/Neos.Demo"
push_branch "${BRANCH}" "Packages/Sites/Neos.Demo"
push_tag "${VERSION}" "Packages/Sites/Neos.Demo"
