---------------------------------------------
Neos development distribution (event-sourced)
---------------------------------------------

Event-Sourced version of the Neos development distribution (still in heavy development!).

Quick Start
===========

1. Clone Repository, install packages

.. code:: bash

  cd /your/local/path
  git clone --single-branch --branch event-sourced https://github.com/neos/neos-development-distribution.git .
  composer install

2. Configure Database connection in ``Configuration/Settings.yaml``:

.. code:: yaml

  Neos:
    Flow:
      persistence:
        backendOptions:
          driver: pdo_mysql
          dbname: '<db_name>'
          user: '<db_user>'
          password: '<db_password>'
          host: '<db_host>

3. Migrate database, import & migrate site
  
.. code:: bash

  ./flow doctrine:migrate
  ./flow site:import --package-key=Neos.Demo
  ./flow contentrepositorymigrate:run

4. Create Neos backend account (optionally)

.. code:: bash

  ./flow user:create --roles Administrator admin password My Admin


Run Behat tests
---------------

1. Configure Testing Database connection in ``Configuration/Testing/Behat/Settings.yaml``:

.. code:: yaml

  Neos:
    Flow:
      persistence:
        backendOptions:
          driver: pdo_mysql
          dbname: '<db_name>'
          user: '<db_user>'
          password: '<db_password>'
          host: '<db_host>

2. Setup behat test runner

.. code:: bash

  ./flow behat:setup

3. Run behat tests

.. code:: bash

  cd Packages/CR/Neos.EventSourcedContentRepository/Tests/Behavior
  ../../../../../bin/behat -c behat.yml.dist

to run all tests and

.. code:: bash

  cd Packages/CR/Neos.EventSourcedContentRepository/Tests/Behavior
  ../../../../../bin/behat -c behat.yml.dist <feature-path>:<line-number>

to run specific features, for example ``../../../../../bin/behat -c behat.yml.dist Features/EventSourced/ContentStreamForking/ForkContentStreamWithDisabledNodesWithoutDimensions.feature:7``
