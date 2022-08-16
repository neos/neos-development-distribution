#!/bin/bash

#
# Create a new branch for the distribution and the development collection
#
# Expects the following environment variables:
#
# BRANCH           the branch that will be created
# FLOW_BRANCH      the corresponding Flow branch for the branch that will be created
# BUILD_URL        used in commit message
#

set -e

if [ -z "$BRANCH" ]; then
  echo "\$BRANCH not set"
  exit 1
fi
if [ -z "$FLOW_BRANCH" ]; then
  echo "\$FLOW_BRANCH not set"
  exit 1
fi
if [ -z "$BUILD_URL" ]; then
  echo "\$BUILD_URL not set"
  exit 1
fi

if [ ! -e "composer.phar" ]; then
  ln -s /usr/local/bin/composer.phar composer.phar
fi

php ./composer.phar -vn clear-cache
php ./composer.phar -vn update

source "$(dirname "${BASH_SOURCE[0]}")/BuildEssentials/ReleaseHelpers.sh"

rm -rf Distribution
git clone --no-checkout git@github.com:neos/neos-base-distribution.git Distribution

# branch distribution
cd Distribution && git checkout -b "${BRANCH}" origin/master
cd -
push_branch "${BRANCH}" "Distribution"

# branch development collection
cd Packages/Neos && git checkout -b "${BRANCH}" origin/master
cd -
push_branch "${BRANCH}" "Packages/Neos"

"$(dirname "${BASH_SOURCE[0]}")/set-dependencies.sh" "${BRANCH}.x-dev" "${BRANCH}" "${FLOW_BRANCH}" "${BUILD_URL}" || exit 1

push_branch "${BRANCH}" "Distribution"
push_branch "${BRANCH}" "Packages/Neos"

# same procedure again with the Development Distribution

rm -rf Distribution
git clone --no-checkout git@github.com:neos/neos-development-distribution.git Distribution

# branch distribution
cd Distribution && git checkout -b "${BRANCH}" origin/master
cd -
push_branch "${BRANCH}" "Distribution"

# special case for the Development Distribution
php ./composer.phar --working-dir=Distribution require --no-update "neos/neos-development-collection:${BRANCH}.x-dev"
php ./composer.phar --working-dir=Distribution require --no-update "neos/flow-development-collection:${FLOW_BRANCH}.x-dev"
"$(dirname "${BASH_SOURCE[0]}")/set-dependencies.sh" "${BRANCH}.x-dev" "${BRANCH}" "${FLOW_BRANCH}" "${BUILD_URL}" || exit 1

push_branch "${BRANCH}" "Distribution"
