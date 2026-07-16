#!/bin/bash

#
# Releases a new version of Neos
#
# Expects the following environment variables:
#
# VERSION          the version that is "to be released"
# PREVIOUS_VERSION the version which will be the previous one to VERSION
# BRANCH           the branch that is worked on
# FLOW_BRANCH      the corresponding Flow branch for the branch that will be created
# BUILD_URL        used in commit message
#

if [ -z "$VERSION" ]; then
  echo "\$VERSION not set"
  exit 1
fi
if [ -z "$PREVIOUS_VERSION" ]; then
  echo "\$PREVIOUS_VERSION not set"
  exit 1
fi
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

rm -rf Distribution
git clone -b "${BRANCH}" git@github.com:neos/neos-base-distribution.git Distribution

if [ ! -e "composer.phar" ]; then
  EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
  then
      echo 'ERROR: Invalid installer checksum'
      rm composer-setup.php
      exit 1
  fi

  php composer-setup.php
  rm composer-setup.php
fi

php composer.phar -v update
Build/create-changelog.sh
if [[ "$VERSION" == *.0 ]]; then
  Build/create-releasenotes.sh
fi
Build/tag-release.sh "${VERSION}" "${BRANCH}" "${FLOW_BRANCH}" "${BUILD_URL}"

#
# Create a new "Release" on Github:
#

EXTENDED_RELEASE_NOTES="${RELEASE_NOTES}\n\nSee [changelog](http://neos.readthedocs.io/en/${BRANCH}/Appendixes/ChangeLogs/${VERSION//.}.html) for details."
API_JSON=$(jq -n --arg tag_name "${VERSION}" --arg name "Neos ${VERSION}" --arg body "${EXTENDED_RELEASE_NOTES}" --argjson draft "false" --argjson prerelease "false" '$ARGS.named')
curl -H "Authorization: token ${GITHUB_TOKEN}" --data "${API_JSON}" "https://api.github.com/repos/neos/neos-development-collection/releases"
