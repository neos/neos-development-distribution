#!/bin/bash
set -e
#
# Generates a changelog in reStructuredText from the commit history of
# the packages in Packages/Neos:
#
# - Neos.Media
# - Neos.Neos
# - Neos.Neos.Kickstarter
# - Neos.Neos.NodeTypes
# - Neos.ContentRepository
# - Neos.Fusion
#
# Needs the following environment variables
#
# VERSION          the version that is "to be released", e.g "4.1.0"
# PREVIOUS_VERSION the last released version, e.g. "4.0.0"
# BUILD_URL        used in commit message (optional)
# GITHUB_TOKEN     to authenticate github calls and avoid API limits
#

if [ -z "$VERSION" ]; then
  echo "\$VERSION not set"
  exit 1
fi
if [ -z "$PREVIOUS_VERSION" ]; then
  echo "\$PREVIOUS_VERSION not set"
  exit 1
fi

TARGET="Neos.Neos/Documentation/Appendixes/ChangeLogs/$(echo "${VERSION}" | tr -d .).rst"
export TARGET

php Build/BuildEssentials/build-tools.php neos:create-changelog neos "$PREVIOUS_VERSION" "$VERSION" "$TARGET" --githubToken="$GITHUB_TOKEN" --buildUrl="$BUILD_URL"
