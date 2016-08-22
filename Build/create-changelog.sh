#!/bin/bash
set -e
#
# Generates a changelog in reStructuredText from the commit history of
# the packages in Packages/Neos:
#
# - TYPO3.Media
# - TYPO3.Neos
# - TYPO3.Neos.Kickstarter
# - TYPO3.Neos.NodeTypes
# - TYPO3.TYPO3CR
# - TYPO3.TypoScript
#
# Needs the following environment variables
#
# VERSION          the version that is "to be released"
# PREVIOUS_VERSION the last released version, is guessed if not given
# BUILD_URL        used in commit message (optional)
#

if [ -z "$VERSION" ]; then echo "\$VERSION not set"; exit 1; fi
if [ -z "$PREVIOUS_VERSION" ]; then echo "\$PREVIOUS_VERSION not set"; exit 1; fi

cd Packages/Neos

# Check for jq library
hash jq 2>/dev/null || { echo >&2 "jq library is not installed. Aborting. Download at https://stedolan.github.io/jq/download/"; exit 1; }

export TARGET="TYPO3.Neos/Documentation/Appendixes/ChangeLogs/$(echo ${VERSION} | tr -d .).rst"

# Add version and date header
export DATE="$(date +%Y-%m-%d)"
echo "\`${VERSION} (${DATE}) <https://github.com/neos/neos-development-collection/releases/tag/${VERSION}>\`_" > ${TARGET}
perl -E 'say "=" x '$(echo $(($(tail -1 $TARGET | wc -c) - 1))) >> ${TARGET}
echo -e "\nOverview of merged pull requests\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" >> ${TARGET}

# Loop over merge commits since previous version
for mergeCommit in $(git log $PREVIOUS_VERSION.. --grep="^Merge pull request" --oneline | cut -d ' ' -f1); do
    echo
    echo $mergeCommit
	pullRequest=$(git show $mergeCommit --no-patch --oneline | cut -d ' ' -f5 | cut -c2-)
	if [ -z "$GITHUB_TOKEN" ];
	then
		echo "fetching info from https://api.github.com/repos/neos/neos-development-collection/pulls/$pullRequest"
		curl -sS "https://api.github.com/repos/neos/neos-development-collection/pulls/$pullRequest" > pr
	else
		echo "fetching info from https://api.github.com/repos/neos/neos-development-collection/pulls/$pullRequest?access_token=<...>"
		curl -sS "https://api.github.com/repos/neos/neos-development-collection/pulls/$pullRequest?access_token=$GITHUB_TOKEN" > pr
	fi
	if [[ $(cat pr | jq '.message') != "null" ]]; then cat pr | jq -r '.message'; exit 1; fi
	echo "\`"$(cat pr | jq -r '.title' | sed 's/`/\\`/g')" <"https://github.com/neos/neos-development-collection/pull/$pullRequest">\`_" >> $TARGET
	perl -E 'say "-" x '$(echo $(($(tail -1 $TARGET | wc -c) - 1))) >> ${TARGET}
	echo >> $TARGET
	cat pr | jq -r '.body' >> $TARGET
	echo >> $TARGET
	packages=()
	# Loop over changed files in merge commit
	for changedFile in $(git show $mergeCommit^ $mergeCommit^2 --name-only --oneline | tail -n +2); do
		# Get first part of changed filename
		package=$(echo "$changedFile" | cut -d '/' -f1)
		# Check if first part of filename is a directory
		if [ -d "$package" ]; then
			# Add last part of package key to packages array
			packages=("${packages[@]}" $(echo $package | rev | cut -d '.' -f1 | rev))
		fi
	done
	# Remove duplicates
	packages=$(echo ${packages[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ')
	if [ -n "${packages// }" ]; then
		echo "* Packages: \`\`"$(echo $packages | sed 's/ /`` ``/g')"\`\`" >> $TARGET
	fi
	echo >> $TARGET
done
# Remove pr file
rm -f pr

echo -e "\n\n\`Detailed log <https://github.com/neos/neos-development-collection/compare/$PREVIOUS_VERSION...$VERSION>\`_" >> $TARGET
perl -E 'say "~" x '$(echo $(($(tail -1 $TARGET | wc -c) - 1))) >> ${TARGET}

# Drop some footer lines from commit messages
perl -p -i -e 's|^Change-Id: (I[a-f0-9]+)$||g' ${TARGET}
perl -p -i -e 's|^Releases?:.*$||g' ${TARGET}
perl -p -i -e 's|^Migration?:.*$||g' ${TARGET}
perl -p -i -e 's|^Reviewed-by?:.*$||g' ${TARGET}
perl -p -i -e 's|^Reviewed-on?:.*$||g' ${TARGET}
perl -p -i -e 's|^Tested-by?:.*$||g' ${TARGET}

# Link issues to Jira
perl -p -i -e 's/(Fixes|Resolves|Related|Relates): (NEOS|FLOW)-([0-9]+)/* $1: `$2-$3 <https:\/\/jira.neos.io\/browse\/$2-$3>`_/g' ${TARGET}
# Link to commits
perl -p -i -e 's/([0-9a-f]{40})/`$1 <https:\/\/github.com\/neos\/neos-development-collection\/commit\/$1>`_/g' ${TARGET}

# escape backslashes
perl -p -i -e 's/\\([^`])/\\\\$1/g' ${TARGET}
# remove escaped backslashes inside backticks
perl -p -i -e 's/(``.*)\\\\(.*``)/$1\\$2/g' ${TARGET}
# clean up empty lines
perl -p -i -0 -e 's/\n\n+/\n\n/g' ${TARGET}
# join bullet list items
perl -p -i -0 -e 's/(\* [^\n]+)\n+(\* [^\n]+)/$1\n$2/g' ${TARGET}

# commit generated changelog
git add ${TARGET}
if [ -z "$BUILD_URL" ]
then
	git commit -m "TASK: Add changelog for ${VERSION}" || echo " nothing to commit "
else
	git commit -m "TASK: Add changelog for ${VERSION}" -m "See $BUILD_URL" || echo " nothing to commit "
fi
cd -
