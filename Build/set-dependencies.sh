#!/bin/bash -xe

#
# Updates the dependencies in composer.json files of the dist and its
# packages.
#
# Needs the following parameters (in order)
#
# VERSION          the version that is "to be released"
# BRANCH           the branch that is worked on
# FLOW_BRANCH      the corresponding Flow branch for the branch that is worked on
# BUILD_URL        used in commit message
#

source "$(dirname "${BASH_SOURCE[0]}")/BuildEssentials/ReleaseHelpers.sh"

COMPOSER_PHAR="$(dirname "${BASH_SOURCE[0]}")/../composer.phar"
if [ ! -f "${COMPOSER_PHAR}" ]; then
  echo >&2 "No composer.phar, expected it at ${COMPOSER_PHAR}"
  exit 1
fi

if [ -z "$1" ]; then
  echo >&2 "No version specified (e.g. 2.1.*) as first parameter."
  exit 1
else
  if [[ $1 =~ (dev)-.+ || $1 =~ .+(@dev|.x-dev) || $1 =~ (alpha|beta|RC|rc)[0-9]+ ]]; then
    VERSION="$1"
    STABILITY_FLAG=${BASH_REMATCH[1]}
  else
    if [[ $1 =~ ([0-9]+\.[0-9]+)\.[0-9] ]]; then
      VERSION=~${BASH_REMATCH[1]}.0
    else
      echo >&2 "Version $1 could not be parsed."
      exit 1
    fi
  fi
fi

if [ -z "$2" ]; then
  echo >&2 "No branch specified (e.g. 2.1) as second parameter."
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

echo "Setting distribution dependencies"

# Require exact versions of the main packages
php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/neos:${VERSION}"
php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/demo:${VERSION}"
php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/site-kickstarter:${VERSION}"
php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/cli-setup:${VERSION}"
php "${COMPOSER_PHAR}" --working-dir=Distribution require --dev --no-update "neos/behat:${VERSION}"
php "${COMPOSER_PHAR}" --working-dir=Distribution require --dev --no-update "neos/buildessentials:${VERSION}"

# Require exact versions of sub dependency packages, allowing unstable
if [[ ${STABILITY_FLAG} ]]; then
  php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/content-repository:${VERSION}"
  php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/fusion:${VERSION}"
  php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/media:${VERSION}"
  php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/media-browser:${VERSION}"
  php "${COMPOSER_PHAR}" --working-dir=Distribution require --no-update "neos/diff:${VERSION}"
# Remove dependencies not needed if releasing a stable version
else
  # Remove requirements for development version of sub dependency packages
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/content-repository"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/fusion"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/media"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/media-browser"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/diff"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/redirecthandler"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/party"

  # Remove requirements for development version of framework sub dependency packages
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/cache"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/eel"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/error-messages"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/flow"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/fluid-adaptor"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/kickstarter"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-arrays"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-files"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-mediatypes"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-objecthandling"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-opcodecache"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-pdo"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-schema"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/utility-unicode"
  php "${COMPOSER_PHAR}" --working-dir=Distribution remove --no-update "neos/http-factories"
fi

commit_manifest_update "${BRANCH}" "${BUILD_URL}" "${VERSION}" "Distribution"

echo "Setting packages dependencies"

php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/content-repository:~${BRANCH}.0"
php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/fusion:~${BRANCH}.0"
php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/media:~${BRANCH}.0"
php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/media-browser:~${BRANCH}.0"
php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/diff:~${BRANCH}.0"

php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/flow:~${FLOW_BRANCH}.0"
php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.Neos require --no-update "neos/fluid-adaptor:~${FLOW_BRANCH}.0"
php "${COMPOSER_PHAR}" --working-dir=Packages/Neos/Neos.SiteKickstarter require --no-update "neos/kickstarter:~${FLOW_BRANCH}.0"

cd Packages/Neos || exit 1
# replace flow-development-collection dependency with new dev-branch in .composer.json
sed -i -e "s/flow-development-collection\": \"[0-9\.]*\.x-dev\"/flow-development-collection\": \"${FLOW_BRANCH}\.x-dev\"/" .composer.json
git add .composer.json
php ../../Build/BuildEssentials/ComposerManifestMerger.php
cd - || exit 1

commit_manifest_update "${BRANCH}" "${BUILD_URL}" "${VERSION}" "Packages/Neos"
