#!/bin/bash

composer install

./flow database:setcharset
./flow doctrine:migrate

# only run site import when no site is present
importedSites=$(./flow site:list)
if [ "$importedSites" = "No sites available" ]; then
    echo "Importing content from Demo"
    ./flow site:import --package-key="Neos.Demo"
fi

./flow user:create --roles Administrator "$ADMIN_USERNAME" "$ADMIN_PASSWORD" LocalDev Admin || true

./flow resource:publish
./flow flow:cache:flush
./flow cache:warmup

# start nginx in background
nginx &

# start PHP-FPM
exec /usr/local/sbin/php-fpm
