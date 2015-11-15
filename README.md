# DockerTYPO3 helps you developing TYPO3 CMS projects

DockerTYPO3 creates the necessary Docker containers (webserver, database, php, mail, redis, elasticsearch) to run
your TYPO3 CMS project. The package provides a wrapper script in `bin/dockertypo3`
which simplifies the handling of docker and does all the configuration necessary.

We created this package to make development on TYPO3 CMS projects easier and
to create a simple reusable package which can easily be maintained and serves well for the standard project.

Development will continue further as the package is already reused in several projects.
Contributions and feedback are very welcome.

## Install docker

    https://docs.docker.com/installation/ (tested with docker v1.9)

## Install docker-compose

We use docker-compose to do all the automatic configuration:

    http://docs.docker.com/compose/install/ (tested with docker-compose v1.5)

The repository contains a Dockerfile which will automatically be built in the
[docker hub](https://registry.hub.docker.com/u/visay/visay.dockertypo3/) after each change
and used by docker-compose to build the necessary containers.

## Install dockertypo3 into your distribution

Add `visay/dockertypo3` as dev dependency in your composer, using the latest stable release is highly recommended.

*Example*:

```
composer require --dev shel/dockertypo3 dev-master
```

## Run dockertypo3

    bin/dockertypo3 up -d
    
The command will echo the url with which you can access your project.
Add the hostname then to your `/etc/hosts` and set the ip to your docker host (default for linux is 0.0.0.0).
The parameter `-d` will keep it running in the background until you run:

    bin/dockertypo3 stop

The default database configuration for your `AdditionalConfiguration.php` is:

    <?php

    if (!defined ('TYPO3_MODE')) {
        die ('Access denied.');
    }

    ## Database connection
    $GLOBALS['TYPO3_CONF_VARS']['DB']['host'] = 'db';
    $GLOBALS['TYPO3_CONF_VARS']['DB']['password'] = 'root';
    $GLOBALS['TYPO3_CONF_VARS']['DB']['username'] = 'root';
    $GLOBALS['TYPO3_CONF_VARS']['DB']['database'] = 'dockertypo3';

Also note that there is a second database `dockertypo3_test` available for your testing context. The testing context url
would be `test.hostname` and this hostname should be added to your `/etc/hosts` too.

## Check the status

    bin/dockertypo3 ps

This will show the running containers. The `data` container can be inactive to do it's work.

# Tips & Tricks

## Using different TYPO3_CONTEXT

    TYPO3_CONTEXT=Production bin/dockertypo3 up -d

Dockertypo3 also setup a sub-context for testing depends on the current context you are running. In the above example,
it would be `Production/Testing`. Anyway, you can only use the parent context with the `bin/dockertypo3` command. So when
there is a need to execute command for the testing context, you need to first get into `app` container and then call the
command prefixed by the context variable.

    TYPO3_CONTEXT=Production bin/dockertypo3 up -d
    bin/dockertypo3 run app /bin/bash
    TYPO3_CONTEXT=Production/Testing <YOUR COMMAND>

## Configure remote debugging from your host to container

Dockertypo3 installs by the default xdebug with the following config on the server:

    xdebug.remote_enable = On
    xdebug.remote_host = 'dockerhost'
    xdebug.remote_port = '9001'
    xdebug.max_nesting_level = 500

So you can do remote debugging from your host to the container through port 9001. From your IDE, you need to configure
the port accordingly. If you are using PHPStorm, this link may be useful for you to configure your IDE properly.

- http://whyunowork.com/2015/09/03/xdebug-flow-and-neos-with-phpstorm/

## Running a shell in one of the service containers

    bin/dockertypo3 run SERVICE /bin/bash

SERVICE can currently be `app`, `web`, `data`, `db`, `redis` or `elasticsearch`.

## Access project url when inside `app` container

As of current docker doesn't support bi-directional link, you cannot access web container from app container.
But in some case you will need this connection. For example in behat tests without selenium, you need the url of
your site in `Testing` context while running the tests has to be done inside the `app` container.

Dockertypo3 adds additional script after starting all containers to fetch the IP address of web container and
append it to `/etc/hosts` inside app container as below:

```
WEB_CONTAINER_IP    project-url
WEB_CONTAINER_IP    test.project-url
```

You need to define the default test suite url in your `behat.yml` to use `http://test.project-url:8080` and then you can
run the behat tests without having to connect external selenium server

```
bin/dockertypo3 run app bin/behat -c Path/To/Your/Package/Tests/Behaviour/behat.yml
```

## Access database inside container from docker host

While you can easily login to shell of the `db` container with `bin/dockertypo3 run db /bin/bash`
and execute your mysql commands, there are some cases that you want to run mysql commands directly
from your host without having to login to the `db` container first. One of the best use cases,
for example, is to access the databases inside the container from MySQL Workbench tool.
To be able to do that, we have mapped database port inside the container (which is `3306`) to your
host machine through `3307` port.

![Screenshot of MySQL Workbench interface](/docs/MySQL-Workbench.png "MySQL Workbench interface")

## Attach to a running service

Run `bin/dockertypo3 ps` and copy the container's name that you want to attach to.

Run `docker exec -it <containername> /bin/bash` with the name you just copied.
With this you can work in a running container instead of creating a new one.

## Check open ports in a container

    bin/dockertypo3 run SERVICE netstat --listen

# Further reading

* [blog post on php-fpm](http://mattiasgeniar.be/2014/04/09/a-better-way-to-run-php-fpm/)
* [nginx+php-fpm+mysql tutorial](http://www.lonelycoder.be/nginx-php-fpm-mysql-phpmyadmin-on-ubuntu-12-04/)
* [Docker documentation](http://docs.docker.com/reference/builder/)
* [docker-compose documentation](http://docs.docker.com/compose)
