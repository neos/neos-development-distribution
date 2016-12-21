#!/bin/bash

#
# Create a new branch for the distribution, the development collection and the demo site
#
# Needs the following arguments
#
# $1 BRANCH    the branch to create
# $2 BUILD_URL used in commit message
#

source $(dirname ${BASH_SOURCE[0]})/BuildEssentials/ReleaseHelpers.sh

if [ -z "$BRANCH" ]; then echo "\$BRANCH not set"; exit 1; fi
if [ -z "$BUILD_URL" ]; then echo "\$BUILD_URL not set"; exit 1; fi

rm -rf Distribution
git clone -b ${BRANCH} git@github.com:neos/neos-base-distribution.git Distribution

# branch distribution
cd Distribution && git checkout -b ${BRANCH} origin/master ; cd -

# branch development collection
cd Packages/Neos && git checkout -b ${BRANCH} origin/master ; cd -

# branch demo site
cd Packages/Sites/Neos.Demo && git checkout -b ${BRANCH} origin/master ; cd -

$(dirname ${BASH_SOURCE[0]})/set-dependencies.sh "${BRANCH}.x-dev" ${BRANCH} "${BUILD_URL}" || exit 1

push_branch ${BRANCH} "Distribution"
push_branch ${BRANCH} "Packages/Neos"
push_branch ${BRANCH} "Packages/Sites/Neos.Demo"
