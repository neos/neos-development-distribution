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

if [ -z "$1" ] ; then
	echo >&2 "No branch specified (e.g. 2.1) as first parameter"
	exit 1
fi
BRANCH=$1

if [ -z "$2" ] ; then
	echo >&2 "No build URL given as second parameter"
	exit 1
fi
BUILD_URL="$2"

if [ ! -d "Distribution" ]; then echo '"Distribution" folder not found. Clone the base distribution into "Distribution"'; exit 1; fi

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
