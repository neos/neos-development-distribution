---------------------------------------------
Neos development distribution (event-sourced)
---------------------------------------------

Event-Sourced version of the Neos development distribution (still in heavy development!).

Quick Start
===========
.. code:: bash

  cd /your/local/path
  git clone --single-branch --branch event-sourced https://github.com/neos/neos-development-distribution.git .
  composer install
  # Configure Database connection, then:
  ./flow doctrine:migrate
  ./flow site:import --package-key=Neos.Demo
  ./flow user:create --roles Administrator admin password My Admin
  ./flow contentrepositorymigrate:run