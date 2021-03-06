FROM lsiobase/nginx:3.12

ARG BUILD_DATE
ARG VERSION
ARG FIREFLYIII_RELEASE
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fabiodcorreia"

ENV FIREFLY_VERSION=5.2.8
ENV FIREFLY_PATH=/var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV DB_CONNECTION=mysql
ENV DB_PORT=3306

# Create and Change to installation path
WORKDIR ${FIREFLY_PATH}

# Install Dependencies
RUN \
  apk add --no-cache \
  curl \
  memcached \
	php7-opcache \
	php7-curl \
	php7-gd \
	php7-ldap \
	php7-bcmath \
	php7-zip \
	php7-intl \
	php7-phar \
	php7-pdo \
	php7-tokenizer \
	php7-iconv \
	php7-dom \
	php7-pdo_mysql \
  php7-memcached

# Install Composer, Firefly and custom configureation
RUN \
  echo "**** install composer ****" && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  echo "**** install composer parallel execution plugin ****" && \
    composer global require hirak/prestissimo --no-plugins --no-scripts && \
  echo "**** install firefly-iii application ****" && \
	composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist ${FIREFLY_PATH} ${FIREFLY_VERSION} && \
  echo "**** configure php-fpm and php ****" && \
    sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \
	sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php7/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php7/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php7/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php7/php.ini && \
	sed -i 's/pm = dynamic/pm = static/' /etc/php7/php-fpm.d/www.conf && \
	sed -i 's/pm.max_children = 5/pm.max_children = 1/' /etc/php7/php-fpm.d/www.conf && \
  	echo "error_log /dev/stdout" >> /etc/php7/php.ini && \
  echo "**** installation and setup completed ****" && \
  echo "**** clean-up ****" && \
  	rm -rf \
	  /root/.composer \
  	  rm -rf /var/cache/apk/* &&\
  echo "**** clean-up completed ****"

# Copy local files
COPY root/ /

# Make file executable
RUN chmod +x /usr/bin/wait-for-it.sh

# Ports and Volumes
VOLUME /config
