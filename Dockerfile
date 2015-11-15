# Pull base image
FROM ubuntu:14.04

MAINTAINER Visay Keo <visay.keo@typo3.org>

# Install packages as per recommendation (https://docs.docker.com/articles/dockerfile_best-practices/)
# And clean up APT
RUN apt-get update && apt-get install -y --no-install-recommends \
    php5-fpm \
    php5-cli \
    php5-mysql \
    php5-gd \
    php5-imagick \
    sqlite \
    php5-sqlite \
    php5-curl \
    php5-redis \
    php5-ldap \
    php5-xdebug \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set workdir to project root
WORKDIR /var/www

# Copy configuration files for php
COPY Configuration/App/php.ini      /etc/php5/fpm/
COPY Configuration/App/php-cli.ini  /etc/php5/cli/
COPY Configuration/App/php-fpm.conf /etc/php5/fpm/
COPY Configuration/App/www.conf     /etc/php5/fpm/pool.d/

# Entry point script which wraps all commands for app container
COPY Scripts/EntryPoint/app.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# By default start php-fpm
CMD ["php5-fpm"]
