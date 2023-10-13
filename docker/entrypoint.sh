#!/bin/bash

composer install

./flow database:setcharset
./flow doctrine:migrate

# only run site import when nothing was imported before
importedSites=`./flow site:list`
if [ "$importedSites" = "No sites available" ]; then
    echo "Importing content from Demo"
    ./flow site:import --package-key="Neos.Demo"
fi

./flow user:create --roles Administrator $ADMIN_USERNAME $ADMIN_PASSWORD LocalDev Admin || true

./flow resource:publish
./flow flow:cache:flush
./flow cache:warmup

./flow server:run --host 0.0.0.0
# e2e test
#./flow behat:setup
#rm bin/selenium-server.jar # we do not need this
