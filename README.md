# Dolibarr application server

Docker image for [Dolibarr ERP](https://www.dolibarr.org).

Provides full database configuration, production mode, HTTPS enforcer (SSL must be provided by reverse proxy), handles upgrades, and so on...

## Usage

This image does not contain the database for Dolibarr. You need to use either an existing database or a database container.

To start the container type:

```console
# docker run -d -p 8080:80 --link my-db:db upshift/dolibarr
```

Now you can access Dolibarr at http://localhost:8080/ from your host system. Default password for the 'admin' user is 'dolibarr'.

## Persistent data

The Dolibarr installation and all data beyond what lives in the database (file uploads, etc) are stored in the [unnamed docker volume](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume) volume `/var/www/html` and `/var/www/documents`. The docker daemon will store that data within the docker directory `/var/lib/docker/volumes/...`. That means your data is saved even if the container crashes, is stopped or deleted.

To make your data persistent to upgrading and get access for backups is using named docker volume or mount a host folder. To achieve this you need one volume for your database container and two volumes for Dolibarr.

Dolibarr:
- `/var/www/html/` folder where all Dolibarr data lives
- `/var/www/documents/` folder where all Dolibarr documents lives

```console
# docker run -d \
    -v dolibarr_html:/var/www/html \
    -v dolibarr_docs:/var/www/documents \
    upshift/dolibarr
```

Database:
- `/var/lib/mysql` MySQL / MariaDB Data
- `/var/lib/postgresql/data` PostgreSQL Data

```console
# docker run -d \
    -v db:/var/lib/mysql \
    mariadb
```

If you want to get fine grained access to your individual files, you can mount additional volumes for config, your theme and custom modules. 
The `conf` is stored in subfolder inside `/var/www/html/`. The modules are split into core `apps` (which are shipped with Dolibarr and you don't need to take care of) and a `custom` folder. If you use a custom theme it would go into the `theme` subfolder.

Overview of the folders that can be mounted as volumes:

- `/var/www/html` Main folder, needed for updating
- `/var/www/html/custom` installed / modified modules
- `/var/www/html/conf` local configuration
- `/var/www/html/theme/<YOUR_CUSTOM_THEME>` theming/branding

## Auto configuration via environment variables

The Dolibarr image supports auto configuration via environment variables. You can preconfigure nearly everything that is asked on the install page on first run. To enable auto configuration, set your database connection via the following environment variables. ONLY use one database type!

See [conf.php.example](https://github.com/Dolibarr/dolibarr/blob/develop/htdocs/conf/conf.php.example) and [install.forced.sample.php](https://github.com/Dolibarr/dolibarr/blob/develop/htdocs/install/install.forced.sample.php) for more details on install configuration.

### DOLI_DB_TYPE

*Default value*: `mysqli`

*Possible values*: `mysqli`, `pgsql`

This parameter contains the name of the driver used to access your Dolibarr database.

Examples:
```
DOLI_DB_TYPE=mysqli
DOLI_DB_TYPE=pgsql
```

### DOLI_DB_HOST

*Default value*: `localhost`

This parameter contains host name or ip address of Dolibarr database server.

Examples:
```
DOLI_DB_HOST=localhost
DOLI_DB_HOST=127.0.2.1
DOLI_DB_HOST=192.168.0.10
DOLI_DB_HOST=mysql.myserver.com
```

### DOLI_DB_PORT

*Default value*: `3306`

This parameter contains the port of the Dolibarr database.

Examples:
```
DOLI_DB_PORT=3306
DOLI_DB_PORT=5432
```

### DOLI_DB_NAME

*Default value*: 

This parameter contains name of Dolibarr database.

Examples:
```
DOLI_DB_NAME=dolibarr
DOLI_DB_NAME=mydatabase
```

### DOLI_DB_USER

*Default value*: 

This parameter contains user name used to read and write into Dolibarr database.

Examples:
```
DOLI_DB_USER=admin
DOLI_DB_USER=dolibarruser
```

### DOLI_DB_PASSWORD

*Default value*: 

This parameter contains password used to read and write into Dolibarr database.

Examples:
```
DOLI_DB_PASSWORD=myadminpass
DOLI_DB_PASSWORD=myuserpassword
```

### DOLI_DB_PREFIX

*Default value*: `llx_`

This parameter contains prefix of Dolibarr database.

Examples:
```
DOLI_DB_PREFIX=llx_
```

### DOLI_DB_CHARACTER_SET

*Default value*: `utf8`

Database character set used to store data (forced during database creation. value of database is then used).
Depends on database driver used. See `DOLI_DB_TYPE`.

Examples:
```
DOLI_DB_CHARACTER_SET=utf8
```

### DOLI_DB_COLLATION

*Default value*: `utf8_unicode_ci`

Database collation used to sort data (forced during database creation. value of database is then used).
Depends on database driver used. See `DOLI_DB_TYPE`.

Examples:
```
DOLI_DB_COLLATION=utf8_unicode_ci
```

### DOLI_DB_ROOT_LOGIN

*Default value*: 

This parameter contains the database server root username used to create the Dolibarr database.

If this parameter is set, the container will automatically tell Dolibarr to create the database and database user on first install with the root account.

Examples:
```
DOLI_DB_ROOT_LOGIN=root
DOLI_DB_ROOT_LOGIN=dolibarruser
```

### DOLI_DB_ROOT_PASSWORD

*Default value*: 

This parameter contains the database server root password used to create the Dolibarr database.

Examples:
```
DOLI_DB_ROOT_PASSWORD=myrootpass
```

### DOLI_ADMIN_LOGIN

*Default value*: `admin`

This parameter contains the admin's login used in the first install.

Examples:
```
DOLI_ADMIN_LOGIN=admin
```

### DOLI_ADMIN_PASSWORD

*Default value*: `dolibarr`

This parameter contains the admin's password used in the first install.

Examples:
```
DOLI_ADMIN_PASSWORD=dolibarr
```

### DOLI_MODULES

*Default value*: 

This parameter contains the list (comma separated) of modules to enable in the first install.

Examples:
```
DOLI_MODULES=modSociete
DOLI_MODULES=modSociete,modPropale,modFournisseur,modContrat,modLdap
```

### DOLI_URL_ROOT

*Default value*: `http://localhost`

This parameter defines the root URL of your Dolibarr index.php page without ending "/".
It must link to the directory htdocs.
In most cases, this is autodetected but it's still required 
* to show full url bookmarks for some services (ie: agenda rss export url, ...)
* or when using Apache dir aliases (autodetect fails)
* or when using nginx (autodetect fails)

Examples:
```
DOLI_URL_ROOT=http://localhost
DOLI_URL_ROOT=http://mydolibarrvirtualhost
DOLI_URL_ROOT=http://myserver/dolibarr/htdocs
DOLI_URL_ROOT=http://myserver/dolibarralias
```

### DOLI_AUTH

*Default value*: `dolibarr`

*Possible values*: Any values found in files in htdocs/core/login directory after the `function_` string and before the `.php` string, **except forceuser**. You can also separate several values using a `,`. In this case, Dolibarr will check login/pass for each value in order defined into value. However, note that this can't work with all values.

This parameter contains the way authentication is done.
**Will not be used if you use first install wizard.** See *First use* for more details.

If value `ldap` is used, you must also set parameters `DOLI_LDAP_*` and `DOLI_MODULES` must contain `modLdap`.

Examples:
```
DOLI_AUTH=http
DOLI_AUTH=dolibarr
DOLI_AUTH=ldap
DOLI_AUTH=openid,dolibarr
```

### DOLI_LDAP_HOST

*Default value*: `127.0.2.1`

You can define several servers here separated with a comma.

Examples:
```
DOLI_LDAP_HOST=localhost
DOLI_LDAP_HOST=ldap.company.com
DOLI_LDAP_HOST=ldaps://ldap.company.com:636,ldap://ldap.company.com:389
```

### DOLI_LDAP_PORT

*Default value*: `389`

### DOLI_LDAP_VERSION

*Default value*: `3`

### DOLI_LDAP_SERVERTYPE

*Default value*: `openldap`
*Possible values*: `openldap`, `activedirectory` or `egroupware`

### DOLI_LDAP_DN

*Default value*: 

Examples:
```
DOLI_LDAP_DN=ou=People,dc=company,dc=com
```

### DOLI_LDAP_LOGIN_ATTRIBUTE

*Default value*: `uid`

Ex: uid or samaccountname for active directory

### DOLI_LDAP_FILTER

*Default value*: 

If defined, the two previous parameters are not used to find a user into LDAP.

Examples:
```
DOLI_LDAP_FILTER=(uid=%1%)
DOLI_LDAP_FILTER=(&(uid=%1%)(isMemberOf=cn=Sales,ou=Groups,dc=company,dc=com))
```

### DOLI_LDAP_ADMIN_LOGIN

*Default value*: 

Required only if anonymous bind disabled.

Examples:
```
DOLI_LDAP_ADMIN_LOGIN=cn=admin,dc=company,dc=com
```

### DOLI_LDAP_ADMIN_PASS

*Default value*: 

Required only if anonymous bind disabled. Ex: 

Examples:
```
DOLI_LDAP_ADMIN_PASS=secret
```

### DOLI_LDAP_DEBUG

*Default value*: `false`


### DOLI_PROD

*Default value*: `0`

*Possible values*: `0` or `1`

When this parameter is defined, all errors messages are not reported.
This feature exists for production usage to avoid to give any information to hackers.

Examples:
```
DOLI_PROD=0
DOLI_PROD=1
```

### DOLI_HTTPS

*Default value*: `0`

*Possible values*: `0`, `1`, `2` or `'https://my.domain.com'`

This parameter allows to force the HTTPS mode.
* 0 = No forced redirect
* 1 = Force redirect to https, until SCRIPT_URI start with https into response
* 2 = Force redirect to https, until SERVER["HTTPS"] is 'on' into response
* 'https://my.domain.com' = Force redirect to https using this domain name.

*Warning*: If you enable this parameter, your web server must be configured to
respond URL with https protocol. 
According to your web server setup, some values may work and other not. Try 
different values (1,2 or 'https://my.domain.com') if you experience problems.

Examples:
```
DOLI_HTTPS=0
DOLI_HTTPS=1
DOLI_HTTPS=2
DOLI_HTTPS=https://my.domain.com
```

### DOLI_NO_CSRF_CHECK

*Default value*: `0`

*Possible values*: `0`, `1`

This parameter can be used to disable CSRF protection.

This might be required if you access Dolibarr behind a proxy that make URL rewriting, to avoid false alarms.

Examples:
```
DOLI_NO_CSRF_CHECK=0
DOLI_NO_CSRF_CHECK=1
```

### PHP_INI_DATE_TIMEZONE

*Default value*: `UTC`

Default timezone on PHP.

### PHP_MEMORY_LIMIT

*Default value*: `256M`

Default memory limit on PHP.

### PHP_MAX_UPLOAD

*Default value*: `20M`

Default max upload size on PHP.

### PHP_MAX_EXECUTION_TIME

*Default value*: `300`

Default max execution time (in seconds) on PHP.

# Running this image with docker-compose

This example will use the a [MariaDB](https://hub.docker.com/_/mariadb/) container (you can also use [MySQL](https://hub.docker.com/_/mysql/) or [PostgreSQL](https://hub.docker.com/_/postgres/) if you prefer). The volumes are set to keep your data persistent. This setup provides **no ssl encryption** and is intended to run behind a proxy. 

Create `docker-compose.yml` file as following:

```yml
version: '3'

volumes:
  dolibarr_html:
  dolibarr_docs:
  dolibarr_db:

services:

  mariadb:
    image: mariadb:latest
    restart: always
    command: --character_set_client=utf8 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    volumes:
      - dolibarr_db:/var/lib/mysql
    environment:
        - "MYSQL_DATABASE=dolibarr"
        - "MYSQL_USER=dolibarr"
        - "MYSQL_PASSWORD=dolibarr"
        - "MYSQL_RANDOM_ROOT_PASSWORD=yes"

  dolibarr:
    image: upshift/dolibarr:latest
    restart: always
    depends_on:
        - mariadb
    ports:
        - "8080:80"
    environment:
        - "DOLI_DB_HOST=mariadb"
        - "DOLI_DB_NAME=dolibarr"
        - "DOLI_DB_USER=dolibarr"
        - "DOLI_DB_PASSWORD=dolibarr"
    volumes:
        - dolibarr_html:/var/www/html
        - dolibarr_docs:/var/www/documents
```

Then run all services `docker-compose up -d`. Now, go to http://localhost:8080/install to access the new Dolibarr installation wizard.

# Make your Dolibarr available from the internet

Until here your Dolibarr is just available from you docker host. If you want you Dolibarr available from the internet adding SSL encryption is mandatory. There are many different possibilities to introduce encryption depending on your setup.

We recommend using a reverse proxy in front of our Dolibarr installation. Your Dolibarr will only be reachable through the proxy, which encrypts all traffic to the clients. You can mount your manually generated certificates to the proxy or use a fully automated solution, which generates and renews the certificates for you.

# First use

When you first access your Dolibarr, you need to access the install wizard at `http://localhost:8080/install/`. The setup wizard will appear and ask you to choose an administrator account, password and the database connection. For the database use the name of your database container as host and `dolibarr` as table and user name. Also enter the database password you chose in your `docker-compose.yml` file.

Most of the fields of the wizard can be initialized with the environment variables.

You should note though that some environment variables will be ignored during install wizard (`DOLI_AUTH` and `DOLI_LDAP_*` for instance). An initial `conf.php` was generated by the container on the first start with the Dolibarr environment variables you set through Docker. To use the container generated configuration, you can skip the first step of install and go directly to http://localhost:8080/install/step2.php.

# Update to a newer version

Updating the Dolibarr container is done by pulling the new image, throwing away the old container and starting the new one. Since all data is stored in volumes, nothing gets lost. The startup script will check for the version in your volume and the installed docker version. If it finds a mismatch, it automatically starts the upgrade process. Don't forget to add all the volumes to your new container, so it works as expected. Also, we advised you do not skip major versions during your upgrade. For instance, upgrade from 5.0 to 6.0, then 6.0 to 7.0, not directly from 5.0 to 7.0.

```console
$ docker pull upshift/dolibarr
$ docker stop <your_dolibarr_container>
$ docker rm <your_dolibarr_container>
$ docker run <OPTIONS> -d upshift/dolibarr
```

Beware that you have to run the same command with the options that you used to initially start your Dolibarr. That includes volumes, port mapping.

When using docker-compose your compose file takes care of your configuration, so you just have to run:

```console
$ docker-compose pull
$ docker-compose up -d
```
