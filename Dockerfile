FROM php:5.6-fpm-alpine
MAINTAINER Damien PIQUET <dpiquet@teicee.com>

# Node JS version
ARG NODEJS_VERSION=8.9.3

# Install PHP dependencies
RUN set -xe \
    && apk add --no-cache git subversion openssh-client coreutils libltdl icu icu-libs unzip libstdc++ libpng libjpeg-turbo postgresql-client libpng freetype libmcrypt \
    && apk add --no-cache --virtual tic-bdeps gcc g++ postgresql-dev binutils-gold libgcc linux-headers make python libmcrypt-dev libpng-dev libjpeg-turbo-dev freetype-dev icu-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) iconv mbstring mcrypt intl pdo_pgsql gd zip bcmath \
    && docker-php-source delete \
    && echo "Installing composer" \
    # Install composer
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && echo "Installing Nodejs" \
    # Install Nodejs (less and uglifyjs)
    && curl -L -o node.tar.xz https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}.tar.xz \
    && tar -xvf node.tar.xz \
    && cd node-v${NODEJS_VERSION}/ \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "Installs node" \
    && npm install -g less \
    && npm install -g uglify-js \
    && npm install -g uglifycss \
    && cd ../ \
    && rm node.tar.xz \
    && rm -Rf node-v${NODEJS_VERSION} \
    # Suppression des dépendances de build
    && apk del tic-bdeps
