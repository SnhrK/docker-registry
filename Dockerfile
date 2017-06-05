FROM ubuntu:16.04

LABEL maintainer="mobingi,Inc."

RUN apt-get update && apt-get install -y --no-install-recommends \
		apache2 \
		software-properties-common \
		supervisor \
	&& apt-get clean \
	&& rm -fr /var/lib/apt/lists/*

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && apt-get install -y --no-install-recommends \
		libapache2-mod-php7.0 \
		php7.0 \
		php7.0-cli \
		php7.0-curl \
		php7.0-dev \
		php7.0-gd \
		php7.0-imap \
		php7.0-mbstring \
		php7.0-mcrypt \
		php7.0-mysql \
		php7.0-pgsql \
		php7.0-pspell \
		php7.0-xml \
		php7.0-xmlrpc \
		php-apcu \
		php-memcached \
		php-pear \
		php-redis \
	&& apt-get clean \
	&& rm -fr /var/lib/apt/lists/*

RUN a2enmod rewrite
COPY conf/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY script/run.sh /run.sh
RUN chmod 755 /run.sh

COPY conf/config /config


EXPOSE 80
CMD ["/run.sh"]

# Run some Debian packages installation.
ENV PACKAGES="php-pear curl"
RUN apt-get update && \
    apt-get install -yq --no-install-recommends $PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Run xdebug installation.
RUN curl -L http://pecl.php.net/get/xdebug-2.4.0.tgz >> /usr/src/php/ext/xdebug.tgz && \
    tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ && \
    rm /usr/src/php/ext/xdebug.tgz && \
    docker-php-ext-install xdebug-2.4.0 && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install exif && \
    php -m

# Goto temporary directory.
WORKDIR /tmp

# Run composer and phpunit installation.
RUN composer selfupdate && \
    composer require "phpunit/phpunit:~5.3.4" --prefer-source --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit

# Set up the application directory.
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments.
ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]