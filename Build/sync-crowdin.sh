#!/bin/sh
#
# This uploads XLIFF sources (english) to and downloads translations from Crowdin
#

set -e

if [ -z "${CROWDIN_API_KEY}" ]
then
  echo "No CROWDIN_API_KEY set.";
  exit 1;
fi

if [ ! -e "composer.phar" ]; then
    Build/install-composer.sh
fi

# we have this on crowdin as well, install it
php composer.phar require --prefer-source --no-interaction --no-progress --no-suggest neos/googleanalytics '@dev'

# update packages
php composer.phar update --no-interaction --no-progress --no-suggest

# run Crowdin scripts
php Build/BuildEssentials/Crowdin/Setup.php `pwd`/crowdin.json
php Build/BuildEssentials/Crowdin/Upload.php `pwd`/crowdin.json
php Build/BuildEssentials/Crowdin/Download.php `pwd`/crowdin.json
php Build/BuildEssentials/Crowdin/Teardown.php `pwd`/crowdin.json

# commit and push results to Framework dev collection
cd Packages/Framework
echo 'Commit and push to Framework'
git ls-files -o | grep 'Translations' | xargs git add
git commit -am 'TASK: Update translations from translation tool [skip travis]' || true
git pull --rebase
git config push.default simple
git push origin
cd -

# commit and push results to Neos dev collection
cd Packages/Neos
echo 'Commit and push to Neos'
git ls-files -o | grep 'Translations' | xargs git add
git commit -am 'TASK: Update translations from translation tool [skip travis]' || true
git pull --rebase
git config push.default simple
git push origin
cd -

# commit and push results to individual packages
for PACKAGE in Neos.Form Neos.GoogleAnalytics Neos.Party Neos.Seo ; do
    echo "Commit and push to ${PACKAGE}"
    cd Packages/Application/${PACKAGE}
    git ls-files -o | grep 'Translations' | xargs git add
    git commit -am 'TASK: Update translations from translation tool [skip travis]' || true
    git pull --rebase
    git config push.default simple
    git push origin
    cd -
done
