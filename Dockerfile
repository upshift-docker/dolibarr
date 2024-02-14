FROM alpine:3.18

LABEL maintainer="docker@upshift.fr"

RUN set -eux; \
	# install needed packages
	# see https://wiki.dolibarr.org/index.php/Dependencies_and_external_libraries
	apk add --no-cache \
		bash \
		openssl \
		rsync \
		apache2 \
		php82-apache2 \
		php82-session \
		php82-mysqli \
		php82-pgsql \
		php82-ldap \
		php82-openssl \
		php82-mbstring \
		php82-intl \
		php82-gd \
		php82-imap \
		php82-pecl-imagick \
		php82-soap \
		php82-curl \
		php82-calendar \
		php82-json \
		php82-xml \
		php82-xmlreader \
		php82-xmlwriter \
		php82-zip \
		php82-tokenizer \
		php82-simplexml \
		php82-opcache \
		php82-pdo \
		php82-pdo_mysql \
		php82-pdo_pgsql \
		php82-pdo_sqlite \
		php82-ctype \
		php82-fileinfo \
		php82 \
		mariadb-client \
		postgresql-client \
		unzip \
		tzdata \
	; \
	sed -i \
		-e 's%^;*allow_url_fopen\s*=.*%allow_url_fopen = Off%' \
		-e 's%^;*disable_functions\s*=.*%disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,passthru,shell_exec,system,proc_open,popen%' \
		-e 's%^;*max_execution_time\s*=.*%max_execution_time = 60%' \
		-e 's%^;*memory_limit\s*=.*%memory_limit = 256M%' \
		-e 's%^;*open_basedir\s*=.*%open_basedir = /var/www/localhost/htdocs:/var/www/documents:/var/www/run:/tmp%' \
		-e 's%^;*post_max_size\s*=.*%post_max_size = 50M%' \
		-e 's%^;*session\.cookie_samesite\s*=.*%session.cookie_samesite = Lax%' \
		-e 's%^;*session\.save_path\s*=.*%session.save_path = /var/www/run%' \
		-e 's%^;*session\.use_strict_mode\s*=.*%session.use_strict_mode = 1%' \
		-e 's%^;*upload_max_filesize\s*=.*%upload_max_filesize = 50M%' \
		/etc/php82/php.ini \
	; \
	sed -i \
		-e 's%^#*LoadModule deflate_module %LoadModule deflate_module %' \
		-e 's%^LoadModule autoindex_module %#LoadModule autoindex_module %' \
		/etc/apache2/httpd.conf \
	; \
	echo \
		'AddOutputFilterByType DEFLATE text/html text/plain text/json text/xml text/css text/javascript application/javascript' \
		> /etc/apache2/conf.d/deflate.conf \
	; \
	install -d -o apache -g root -m 0750 /var/www/html; \
	rm -rf /var/www/localhost/htdocs; \
	ln -s /var/www/html /var/www/localhost/htdocs

ENV DOLI_VERSION 19.0.0

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
ENV DOLI_ADMIN_PASSWORD dolibarr
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

ENV LANG fr_FR

VOLUME /var/www/html
VOLUME /var/www/documents

RUN set -eux; \
	wget https://github.com/Dolibarr/dolibarr/archive/${DOLI_VERSION}.zip -O /tmp/dolibarr.zip; \
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
