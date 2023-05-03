-----------------------------
Neos development distribution
-----------------------------

This repository provides a basis for *developing Neos*. The dependencies defined in ``composer.json`` will install
the development collections of Neos and Flow, which allows you to create bugfixes and new features and push them to
the respective repositories for review and inclusion into the core.

Learn more about the Neos content application platform on http://www.neos.io/.

Quick Start
===========

Docker Setup
------------

First time will take some time because we load all "neos/*" dependencies as Git repositories.

.. code:: bash

  docker compose up -d && docker compose logs -f

local checkout
--------------

.. code:: bash

  cd /your/local/path
  git clone https://github.com/neos/neos-development-distribution.git
  cd neos-development-distribution
  curl -s https://getcomposer.org/installer | php
  php composer.phar install

For details see https://discuss.neos.io/t/development-setup

web server configuration
------------------------

See https://docs.neos.io/cms/contributing-to-neos

how to push changes
-------------------

1. Fork on github.com
2. git remote add fork git@github.com:your-account/neos-development-distribution.git
3. git checkout -b dev-your-branch
4. git commit ...
5. git push fork
6. Create Pull Request on github.com

For details see https://discuss.neos.io/t/development-workflow-for-github
