FROM alpine:3.8

LABEL maintainer="docker@upshift.fr"

ENV DOLI_VERSION 8.0.2

ENV DOLI_DB_TYPE mysqli
ENV DOLI_DB_HOST db
ENV DOLI_DB_PORT 3306
ENV DOLI_DB_USER dolibarr
ENV DOLI_DB_PASSWORD dolibarr
ENV DOLI_DB_NAME dolibarr
ENV DOLI_DB_PREFIX llx_
ENV DOLI_DB_CHARACTER_SET utf8
ENV DOLI_DB_COLLATION utf8_unicode_ci

ENV DOLI_DB_ROOT_LOGIN ''
ENV DOLI_DB_ROOT_PASSWORD ''

ENV DOLI_ADMIN_LOGIN admin
ENV DOLI_MODULES ''

ENV DOLI_URL_ROOT 'http://localhost'

ENV DOLI_AUTH dolibarr

ENV DOLI_LDAP_HOST 127.0.0.1
ENV DOLI_LDAP_PORT 389
ENV DOLI_LDAP_VERSION 3
ENV DOLI_LDAP_SERVERTYPE openldap
ENV DOLI_LDAP_LOGIN_ATTRIBUTE uid
ENV DOLI_LDAP_DN ''
ENV DOLI_LDAP_FILTER ''
ENV DOLI_LDAP_ADMIN_LOGIN ''
ENV DOLI_LDAP_ADMIN_PASS ''
ENV DOLI_LDAP_DEBUG false

ENV DOLI_HTTPS 0
ENV DOLI_PROD 0
ENV DOLI_NO_CSRF_CHECK 0

ENV PHP_INI_DATE_TIMEZONE 'Europe/Paris'
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_MAX_UPLOAD 20M
ENV PHP_MAX_EXECUTION_TIME 300

RUN set -eux; \
	# install needed packages
	# see https://wiki.dolibarr.org/index.php/Dependencies_and_external_libraries
	apk add --no-cache \
		bash \
		openssl \
		rsync \
		apache2 \
		php7-apache2 \
		php7-session \
		php7-mysqli \
		php7-pgsql \
		php7-ldap \
		php7-mcrypt \
		php7-openssl \
		php7-mbstring \
		php7-gd \
		php7-imagick \
		php7-soap \
		php7-curl \
		php7-calendar \
		php7-xml \
		php7-zip \
		php7 \
		unzip \
	; \
	install -d -o apache -g root -m 0750 /var/www/html; \
	rm -rf /var/www/localhost/htdocs; \
	ln -s /var/www/html /var/www/localhost/htdocs

VOLUME /var/www/html
VOLUME /var/www/documents

# Get Dolibarr
ADD https://github.com/Dolibarr/dolibarr/archive/${DOLI_VERSION}.zip /tmp/dolibarr.zip
#COPY /dolibarr-${DOLI_VERSION}.zip /tmp/dolibarr.zip
RUN set -eux; \
	unzip -q /tmp/dolibarr.zip -d /tmp/dolibarr; \
	rm -f /tmp/dolibarr.zip; \
	mkdir -p /usr/src/dolibarr; \
	cp -r /tmp/dolibarr/dolibarr-${DOLI_VERSION}/* /usr/src/dolibarr; \
	rm -rf /tmp/dolibarr; \
	chmod +x /usr/src/dolibarr/scripts/*

WORKDIR /var/www/html

EXPOSE 80/tcp

COPY /src/docker-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-entrypoint"]

COPY /src/apache2-foreground /usr/local/bin/
CMD ["apache2-foreground"]
