FROM php:5.6-fpm-alpine
MAINTAINER Damien PIQUET <dpiquet@teicee.com>

# UID 
ENV PHP_UID=1000

# GID
ENV PHP_GID=65534

# Node JS version
ARG NODEJS_VERSION=8.9.3

# Install PHP dependencies
RUN set -xe \
    && apk add --no-cache git openssh-client coreutils freetype-dev libjpeg-turbo-dev libltdl libmcrypt-dev libpng-dev icu icu-libs icu-dev unzip libstdc++ \
    && apk add --no-cache --virtual tic-bdeps gcc g++ postgresql-dev binutils-gold libgcc linux-headers make python \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) iconv mbstring mcrypt intl pdo_pgsql gd zip bcmath \
    && docker-php-source delete


# Installation de composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer

# Install Nodejs (less and uglifyjs)
RUN curl -L -o node.tar.xz https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}.tar.xz \
    && tar -xvf node.tar.xz \
    && cd node-v${NODEJS_VERSION}/ \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install

RUN echo "Installs node" \
    && npm install -g less \
    && npm install -g uglify-js \
    && npm install -g uglifycss \
    && rm node.tar.xz \
    && rm -Rf node-v${NODEJS_VERSION}

# Delete build dependencies
RUN apk del tic-bdeps

# Creation utilisateur PHP
RUN adduser php-fpm -H -u ${PHP_UID} -G nobody -h /home/docker -g none -D
