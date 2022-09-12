#!/bin/bash

# This is intended to be run on Jenkins, triggered by GitHub and will
# update the references rendered from PHP sources.

BRANCH=$(echo ${payload} | jq --raw-output '.ref | match("refs/heads/(.+)") | .captures | .[0].string')

# reset distribution
git reset --hard
git checkout -B ${BRANCH} origin/${BRANCH}

# install dependencies
php $(dirname ${BASH_SOURCE[0]})/../composer.phar update --no-interaction --no-progress --no-suggest
php $(dirname ${BASH_SOURCE[0]})/../composer.phar require --no-interaction --no-progress neos/doctools

# render references
./flow cache:warmup
./flow reference:rendercollection Neos

cd Packages/Neos

# reset changes only updating the generation date
for unchanged in `git diff  --numstat | grep '1\t1\t' | cut -f3`; do
 git checkout -- $unchanged;
done

# commit and push results to Neos dev collection
echo 'Commit and push to Neos'
git add Neos.Neos/Documentation
git add Neos.Media/Documentation
git commit -m 'TASK: Update references [skip ci]'
git config push.default simple
git push origin ${BRANCH}
cd -
