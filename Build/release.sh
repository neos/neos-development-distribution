#!/bin/bash

#
# Releases a new version of Neos
#
# Expects the following environment variables:
#
# VERSION          the version that is "to be released"
# PREVIOUS_VERSION the version which will be the previous one to VERSION
# BRANCH           the branch that is worked on
# BUILD_URL        used in commit message
#

if [ -z "$VERSION" ]; then echo "\$VERSION not set"; exit 1; fi
if [ -z "$PREVIOUS_VERSION" ]; then echo "\$PREVIOUS_VERSION not set"; exit 1; fi
if [ -z "$BRANCH" ]; then echo "\$BRANCH not set"; exit 1; fi
if [ -z "$BUILD_URL" ]; then echo "\$BUILD_URL not set"; exit 1; fi

rm -rf Distribution
git clone -b ${BRANCH} git@github.com:neos/neos-base-distribution.git Distribution

if [ ! -e "composer.phar" ]; then
    ln -s /usr/local/bin/composer.phar composer.phar
fi

composer.phar -v update
Build/create-changelog.sh
Build/tag-release.sh ${VERSION} ${BRANCH} ${BUILD_URL}

#
# Create a new "Release" on Github:
#

EXTENDED_RELEASE_NOTES="${RELEASE_NOTES}\n\nSee [changelog](http://neos.readthedocs.io/en/${BRANCH}/Appendixes/ChangeLogs/${VERSION//.}.html) for details."
API_JSON=$(printf '{"tag_name": "%s","name": "Neos %s","body": "%s","draft": false,"prerelease": false}' "${VERSION}" "${VERSION}" "${EXTENDED_RELEASE_NOTES}")
curl --data "${API_JSON}" https://api.github.com/repos/neos/neos-development-collection/releases?access_token=${GITHUB_TOKEN}
