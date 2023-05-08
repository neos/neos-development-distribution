FROM php:8.1-fpm

RUN apt-get update -y \
    # install GraphicsMagick
	&& apt-get install --no-install-recommends -y \
		libgraphicsmagick1-dev graphicsmagick zlib1g-dev libicu-dev gcc g++ \
	&& pecl -vvv install gmagick-beta && docker-php-ext-enable gmagick \
    # pdo_mysql
    && docker-php-ext-install pdo_mysql \
    # redis
    && pecl install redis && docker-php-ext-enable redis \
	# intl
	&& docker-php-ext-configure intl && docker-php-ext-install intl \
    # tools
    && apt-get install -y unzip git vim less default-mysql-client nginx-light \
    # cleanup
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ADD /docker/entrypoint.sh /

# remove existing fpm and nginx configs
RUN rm -Rf /usr/local/etc/php-fpm.* && rm -Rf /etc/nginx/conf.d/*

# add config files
ADD /docker/config-files/memory-limit-php.ini /usr/local/etc/php/conf.d/memory-limit-php.ini
ADD /docker/config-files/upload-limit-php.ini /usr/local/etc/php/conf.d/upload-limit-php.ini
ADD /docker/config-files/php-fpm.conf /usr/local/etc/php-fpm.conf
ADD /docker/config-files/nginx.conf /etc/nginx/

# make sure some directories exist
RUN mkdir -p /app/DistributionPackages
RUN mkdir -p /app/Configuration/Development
RUN mkdir -p /.composer
RUN mkdir -p /var/lib/nginx /usr/local/var/log/

RUN chown -R 1000:1000 /entrypoint.sh /app /.composer /var/lib/nginx /usr/local/var/log/ /var/log/ /etc/nginx/ /var/www
RUN chmod +x /entrypoint.sh

USER 1000:1000

WORKDIR /app

ENTRYPOINT [ "/entrypoint.sh" ]
