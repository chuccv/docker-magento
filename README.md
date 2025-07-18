<h1 align="center">chuccv/docker-magento</h1>
## Usage

This configuration is intended to be used as a Docker-based development environment for Magento 2.

Folders:

- `images`: Docker images for nginx and php
- `compose`: sample setups with Docker Compose

> The Magento 1 version of this development environment has been deprecated and is no longer supported. PHP 5 was used as it's base, and that version has reached end-of-life. If you still wish to use this setup, please reference [compose/magento-1 on tag 20.1.1](https://github.com/chuccv/docker-magento/tree/20.1.1/compose/magento-1), but please be aware these images are no longer maintained.

## Prerequisites

This setup assumes you are running Docker on a computer with at least 6GB of RAM allocated to Docker, a dual-core, and an SSD hard drive. [Download & Install Docker Desktop](https://www.docker.com/products/docker-desktop).

This configuration has been tested on Mac & Linux. Windows is supported through the use of Docker on WSL.

## Setup

### Automated Setup (New Project)

```bash
# Create your project directory then go into it:
mkdir -p ~/Sites/magento
cd $_

# Run this automated one-liner from the directory you want to install your project.
curl -s https://raw.githubusercontent.com/chuccv/docker-magento/master/lib/onelinesetup | bash -s -- magento.test community 2.4.8-p1
```

The `magento.test` above defines the hostname to use, `community` is the Magento edition, and the `2.4.7-p3` defines the Magento version to install. Note that since we need a write to `/etc/hosts` for DNS resolution, you will be prompted for your system password during setup.

After the one-liner above completes running, you should be able to access your site at `https://magento.test`.

#### Install sample data

After the above installation is complete, run the following lines to install sample data:

```bash
bin/magento sampledata:deploy
bin/magento setup:upgrade
```

### Manual Setup

Same result as the one-liner above. Just replace `magento.test` references with the hostname that you wish to use.

#### New Projects

```bash
# Create your project directory then go into it:
mkdir -p ~/Sites/magento
cd $_

# Download the Docker Compose template:
curl -s https://raw.githubusercontent.com/chuccv/docker-magento/master/lib/template | bash

# Download the version of Magento you want to use with:
bin/download community 2.4.8
# You can specify the edition (community, enterprise, mageos) and version (2.4.7-p3, 1.0.5, etc.)
# If no arguments are passed in, the edition defaults to "community"
# If no version is specified, it defaults to the most recent version defined in `bin/download`

# or for Magento core development:
# bin/start --no-dev
# bin/setup-composer-auth
# bin/cli git clone git@github.com:magento/magento2.git .
# bin/cli git checkout 2.4-develop
# bin/composer install

# Run the setup installer for Magento:
bin/setup magento.test

open https://magento.test
```

#### Existing Projects

```bash
# Create your project directory then go into it:
mkdir -p ~/Sites/magento
cd $_

# Download the Docker Compose template:
curl -s https://raw.githubusercontent.com/chuccv/docker-magento/master/lib/template | bash

# Take a backup of your existing database:
bin/mysqldump > ~/Sites/existing/magento.sql

# Replace with existing source code of your existing Magento instance:
cp -R ~/Sites/existing src
# or: git clone git@github.com:myrepo.git src

# Start some containers, copy files to them and then restart the containers:
bin/start --no-dev
bin/copytocontainer --all ## Initial copy will take a few minutes...

# If your vendor directory was empty, populate it with:
bin/composer install

# Import existing database:
bin/mysql < ../existing/magento.sql

# Update database connection details to use the above Docker MySQL credentials:
# Also note: creds for the MySQL server are defined at startup from env/db.env
# vi src/app/etc/env.php

# Import app-specific environment settings:
bin/magento app:config:import

# Create a DNS host entry and setup Magento base url
bin/setup-domain yoursite.test

bin/restart

open https://magento.test
```

### Elasticsearch vs OpenSearch
OpenSearch is set as the default search engine when setting up this project. Follow the instructions below if you want to use Elasticsearch instead:
1. Comment out or remove the `opensearch` container in both the [`compose.yaml`](https://github.com/chuccv/docker-magento/blob/master/compose/compose.yaml#L69-L84) and [`compose.healthcheck.yaml`](https://github.com/chuccv/docker-magento/blob/master/compose/compose.healthcheck.yaml#L36-L41) files
2. Uncomment the `elasticsearch` container in both the [`compose.yaml`](https://github.com/chuccv/docker-magento/blob/master/compose/compose.yaml#L86-L106) and [`compose.healthcheck.yaml`](https://github.com/chuccv/docker-magento/blob/master/compose/compose.healthcheck.yaml#L43-L48) files
3. Update the `bin/setup-install` command to use the Elasticsearch rather than OpenSearch. Change:

```
--opensearch-host="$OPENSEARCH_HOST" \
--opensearch-port="$OPENSEARCH_PORT" \
```

to:

```
--elasticsearch-host="$ES_HOST" \
--elasticsearch-port="$ES_PORT" \

```

## Updates

To update your project to the latest version of `docker-magento`, run:

```
bin/update
```

We recommend keeping your docker config files in version control, so you can monitor the changes to files after updates. After reviewing the code updates and ensuring they updated as intended, run `bin/restart` to restart your containers to have the new configuration take effect.

It is recommended to keep your root docker config files in one repository, and your Magento code setup in another. This ensures the Magento base path lives at the top of one specific repository, which makes automated build pipelines and deployments easy to manage, and maintains compatibility with projects such as Magento Cloud.

## Custom CLI Commands

- `bin/analyse`: Run `phpstan analyse` within the container to statically analyse code, passing in directory to analyse. Ex. `bin/analyse app/code`
- `bin/bash`: Drop into the bash prompt of your Docker container. The `phpfpm` container should be mainly used to access the filesystem within Docker.
- `bin/blackfire`: Disable or enable Blackfire. Accepts argument `disable`, `enable`, or `status`. Ex. `bin/blackfire enable`
- `bin/cache-clean`: Access the [cache-clean](https://github.com/mage2tv/magento-cache-clean) CLI. Note the watcher is automatically started at startup in `bin/start`. Ex. `bin/cache-clean config full_page`
- `bin/check-dependencies`: Provides helpful recommendations for dependencies tailored to the chosen Magento version.
- `bin/cli`: Run any CLI command without going into the bash prompt. Ex. `bin/cli ls`
- `bin/clinotty`: Run any CLI command with no TTY. Ex. `bin/clinotty chmod u+x bin/magento`
- `bin/cliq`: The same as `bin/cli`, but pipes all output to `/dev/null`. Useful for a quiet CLI, or implementing long-running processes.
- `bin/composer`: Run the composer binary. Ex. `bin/composer install`
- `bin/configure-linux`: Adds the Docker container's IP address to the system's `/etc/hosts` file if it's not already present. Additionally, it prompts the user to open port 9003 for Xdebug if desired.
- `bin/copyfromcontainer`: Copy folders or files from container to host. Ex. `bin/copyfromcontainer vendor`
- `bin/copytocontainer`: Copy folders or files from host to container. Ex. `bin/copytocontainer --all`
- `bin/create-user`: Create either an admin user or customer account.
- `bin/cron`: Start or stop the cron service. Ex. `bin/cron start`
- `bin/debug-cli`: Enable Xdebug for bin/magento, with an optional argument of the IDE key. Defaults to PHPSTORM Ex. `bin/debug-cli enable PHPSTORM`
- `bin/deploy`: Runs the standard Magento deployment process commands. Pass extra locales besides `en_US` via an optional argument. Ex. `bin/deploy nl_NL`
- `bin/dev-test-run`: Facilitates running PHPUnit tests for a specified test type (e.g., integration). It expects the test type as the first argument and passes any additional arguments to PHPUnit, allowing for customization of test runs. If no test type is provided, it prompts the user to specify one before exiting.
- `bin/dev-urn-catalog-generate`: Generate URN's for PhpStorm and remap paths to local host. Restart PhpStorm after running this command.
- `bin/devconsole`: Alias for `bin/n98-magerun2 dev:console`
- `bin/docker-compose`: Support V1 (`docker-compose`) and V2 (`docker compose`) docker compose command, and use custom configuration files, such as `compose.yml` and `compose.dev.yml`
- `bin/docker-start`: Start the Docker application (either Orbstack or Docker Desktop)
- `bin/docker-stats`: Display container name and container ID, status for CPU, memory usage(in MiB and %), and memory limit of currently-running Docker containers.
- `bin/download`: Download specific Magento version from Composer to the container, with optional arguments of the type ("community" [default], "enterprise", or "mageos") and version ([default] is defined in `bin/download`). Ex. `bin/download mageos` or `bin/download enterprise 2.4.7-p3`
- `bin/ece-patches`: Run the Cloud Patches CLI. Ex: `bin/ece-tools apply`
- `bin/fixowns`: This will fix filesystem ownerships within the container.
- `bin/fixperms`: This will fix filesystem permissions within the container.
- `bin/grunt`: Run the grunt binary. Ex. `bin/grunt exec`
- `bin/install-php-extensions`: Install PHP extension in the container. Ex. `bin/install-php-extensions sourceguardian`
- `bin/log`: Monitor the Magento log files. Pass no params to tail all files. Ex. `bin/log debug.log`
- `bin/magento`: Run the Magento CLI. Ex: `bin/magento cache:flush`
- `bin/magento-version`: Determine the Magento version installed in the current environment.
- `bin/mftf`: Run the Magento MFTF. Ex: `bin/mftf build:project`
- `bin/mysql`: Run the MySQL CLI with database config from `env/db.env`. Ex. `bin/mysql -e "EXPLAIN core_config_data"` or`bin/mysql < magento.sql`
- `bin/mysqldump`: Backup the Magento database. Ex. `bin/mysqldump > magento.sql`
- `bin/n98-magerun2`: Access the [n98-magerun2](https://github.com/netz98/n98-magerun2) CLI. Ex: `bin/n98-magerun2 dev:console`
- `bin/node`: Run the node binary. Ex. `bin/node --version`
- `bin/npm`: Run the npm binary. Ex. `bin/npm install`
- `bin/phpcbf`: Auto-fix PHP_CodeSniffer errors with Magento2 options. Ex. `bin/phpcbf <path-to-extension>`
- `bin/phpcs`: Run PHP_CodeSniffer with Magento2 options. Ex. `bin/phpcs <path-to-extension>`
- `bin/phpcs-json-report`: Run PHP_CodeSniffer with Magento2 options and save to `report.json` file. Ex. `bin/phpcs-json-report <path-to-extension>`
- `bin/pwa-studio`: (BETA) Start the PWA Studio server. Note that Chrome will throw SSL cert errors and not allow you to view the site, but Firefox will.
- `bin/redis`: Run a command from the redis container. Ex. `bin/redis redis-cli monitor`
- `bin/remove`: Remove all containers.
- `bin/removeall`: Remove all containers, networks, volumes, and images, calling `bin/stopall` before doing so.
- `bin/removenetwork`: Remove a network associated with the current directory's name.
- `bin/removevolumes`: Remove all volumes.
- `bin/restart`: Stop and then start all containers.
- `bin/root`: Run any CLI command as root without going into the bash prompt. Ex `bin/root apt-get install nano`
- `bin/rootnotty`: Run any CLI command as root with no TTY. Ex `bin/rootnotty chown -R app:app /var/www/html`
- `bin/setup`: Run the Magento setup process to install Magento from the source code, with optional domain name. Defaults to `magento.test`. Ex. `bin/setup magento.test`
- `bin/setup-composer-auth`: Setup authentication credentials for Composer.
- `bin/setup-domain`: Setup Magento domain name. Ex: `bin/setup-domain magento.test`
- `bin/setup-grunt`: Install and configure Grunt JavaScript task runner to compile .less files
- `bin/setup-install`: Automates the installation process for a Magento instance.
- `bin/setup-integration-tests`: Script to set up integration tests.
- `bin/setup-pwa-studio`: (BETA) Install PWA Studio (requires NodeJS and Yarn to be installed on the host machine). Pass in your base site domain, otherwise the default `master-7rqtwti-mfwmkrjfqvbjk.us-4.magentosite.cloud` will be used. Ex: `bin/setup-pwa-studio magento.test`.
- `bin/setup-pwa-studio-sampledata`: This script makes it easier to install Venia sample data. Pass in your base site domain, otherwise the default `master-7rqtwti-mfwmkrjfqvbjk.us-4.magentosite.cloud` will be used. Ex: `bin/setup-pwa-studio-sampledata magento.test`.
- `bin/setup-ssl`: Generate an SSL certificate for one or more domains. Ex. `bin/setup-ssl magento.test foo.test`
- `bin/setup-ssl-ca`: Generate a certificate authority and copy it to the host.
- `bin/spx`: Disable or enable output compression to enable or disable SPX. Accepts params `disable` (default) or `enable`. Ex. `bin/spx enable`
- `bin/start`: Start all containers, good practice to use this instead of `docker-compose up -d`, as it may contain additional helpers.
- `bin/status`: Check the container status.
- `bin/stop`: Stop all project containers.
- `bin/stopall`: Stop all docker running containers
- `bin/test/unit`: Run unit tests for a specific path. Ex. `bin/test/unit my-dir`
- `bin/test/unit-coverage`: Generate unit tests coverage reports, saved to the folder `dev/tests/unit/report`. Ex. `bin/test/unit-coverage my-dir`
- `bin/test/unit-xdebug`: Run unit tests with Xdebug. Ex. `bin/test/unit-xdebug my-dir`
- `bin/update`: Update your project to the most recent version of `docker-magento`.
- `bin/xdebug`: Set a custom xdebug.mode (Ex. `bin/xdebug debug`) or check the current status and get all available modes (Ex. `bin/xdebug`)

## Misc Info

### Install fails because project directory is not empty

The most common issue with a failed docker-magento install is getting this error:

```
Project directory "/var/www/html/." is not empty error
```

This message occurs when _something_ fails to execute correctly during an install, and a subsequent install is re-attempted. Unfortunately, when attempting a second (or third) install, it's possible the `src` directory is no longer empty. This prevents Composer from creating the new project because it needs to create new projects within an empty directory.

The workaround to this is that once you have fixed the issue that was initially preventing your install from completing, you will need to completely remove the assets from the previously attempted install before attempting a subsequent install.

You can do this by running:

```
bin/removeall
cd ..
rm -rf yourproject
```

Then, create your new project directory again so you can attempt the install process again. The `bin/removeall` command removes all previous Docker containers & volumes related to the specific project directory you are within. You can then attempt the install process again.

### Accessing the Magento Backend

After successfully installing the Magento environment, you can access the backend by following these steps:

1. Open your web browser and go to the following URL: `https://magento.test/admin/`.

2. Use the following default credentials to log in:
- **Username:** `john.smith`
- **Password:** `password123`

3. Upon logging in, you might be prompted to configure Two-Factor Authentication (2FA). This emails you a code to log in with (which you can check with Mailcatcher by visiting `http://{yourdomain}:1080`). By default, the email address used for this purpose is:
- **Email:** `john.smith@gmail.com`

If you are testing in a local development environment and wish to disable 2FA, you can do so by installing [Mark's DisableTwoFactorAuth module](https://github.com/chuccv/magento2-module-disabletwofactorauth).

### Caching

For an improved developer experience, caches are automatically refreshed when related files are updated, courtesy of [cache-clean](https://github.com/mage2tv/magento-cache-clean). This means you can keep all of the standard Magento caches enabled, and this script will only clear the specific caches needed, and only when necessary.

To disable this functionality, uncomment the last line in the `bin/start` file to disable the watcher.

### Database

The hostname of each service is the name of the service within the `compose.yaml` file. So for example, MySQL's hostname is `db` (not `localhost`) when accessing it from within a Docker container. Elasticsearch's hostname is `elasticsearch`.

To connect to the MySQL CLI tool of the Docker instance, run:

```
bin/mysql
```

You can use the `bin/mysql` script to import a database, for example a file stored in your local host directory at `magento.sql`:

```
bin/mysql < magento.sql
```

You also can use `bin/mysqldump` to export the database. The file will appear in your local host directory at `magento.sql`:

```
bin/mysqldump > magento.sql
```

> Getting an "Access denied, you need (at least one of) the SUPER privilege(s) for this operation." message when running one of the above lines? Try running it as root with:
> ```
> bin/clinotty mysql -hdb -uroot -pmagento magento < src/backup.sql
> ```
> You can also remove the DEFINER lines from the MySQL backup file with:
> ```
> sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i src/backup.sql
> ```

### Composer Authentication

First setup Magento Marketplace authentication (details in the [DevDocs](http://devdocs.magento.com/guides/v2.0/install-gde/prereq/connect-auth.html)).

Copy `src/auth.json.sample` to `src/auth.json`. Then, update the username and password values with your Magento public and private keys, respectively. Finally, copy the file to the container by running `bin/copytocontainer auth.json`.

### Email / Mailcatcher

View emails sent locally through Mailcatcher by visiting [http://{yourdomain}:1080](http://{yourdomain}:1080). In order to use mailcatcher, set the mailserver host to `mailcatcher` and set port to `1025`. Note that this port (`1025`) is different from the mailcatcher interface to read the emails (`1080`).

### Redis

Redis is now the default cache and session storage engine, and is automatically configured & enabled when running `bin/setup` on new installs.

Use the following lines to enable Redis on existing installs:

**Enable for Cache:**

`bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=redis --cache-backend-redis-db=0`

**Enable for Full Page Cache:**

`bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=redis --page-cache-redis-db=1`

**Enable for Session:**

`bin/magento setup:config:set --session-save=redis --session-save-redis-host=redis --session-save-redis-log-level=4 --session-save-redis-db=2`

You may also monitor Redis by running: `bin/redis redis-cli monitor`

For more information about Redis usage with Magento, <a href="https://devdocs.magento.com/guides/v2.4/config-guide/redis/redis-session.html" target="_blank">see the DevDocs</a>.

### PhpMyAdmin

PhpMyAdmin is built into the `compose.dev.yaml` file. Simply open `http://localhost:8080` in a web browser.

These credentials can be used to log in to PhpMyAdmin:

- **Username:** `magento`
- **Password:** `magento`

### Xdebug & VS Code

Install and enable the PHP Debug extension from the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug).

Otherwise, this project now automatically sets up Xdebug support with VS Code. If you wish to set this up manually, please see the [`.vscode/launch.json`](https://github.com/chuccv/docker-magento/blame/master/compose/.vscode/launch.json) file.

### Xdebug & VS Code in a WSL2 environment

Install and enable the PHP Debug extension from the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug).

Otherwise, this project now automatically sets up Xdebug support with VS Code. If you wish to set this up manually, please see the [`.vscode/launch.json`](https://github.com/chuccv/docker-magento/blame/master/compose/.vscode/launch.json) file.

1. In VS Code, make sure that it's running in a WSL window, rather than in the default window.
2. Install the [`PHP Debug`](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug) extension on VS Code.
3. Create a new configuration file inside the project. Go to the `Run and Debug` section in VS Code, then click on `create a launch.json file`.
4. Attention to the following configs inside the file:
    * The port must be the same as the port on the xdebug.ini file.
    ```bash
      bin/cli cat /usr/local/etc/php/php.ini
    ```
    ```bash
      memory_limit = 4G
      max_execution_time = 1800
      zlib.output_compression = On
      cgi.fix_pathinfo = 0
      date.timezone = UTC

      xdebug.mode = debug
      xdebug.client_host = host.docker.internal
      xdebug.idekey = PHPSTORM
      xdebug.client_port=9003
      #You can uncomment the following line to force the debug with each request
      #xdebug.start_with_request=yes

      upload_max_filesize = 100M
      post_max_size = 100M
      max_input_vars = 10000
    ```
    * The pathMappings should have the same folder path as the project inside the Docker container.
    ```json
      {
          "version": "0.2.0",
          "configurations": [
              {
                  "name": "Listen for XDebug",
                  "type": "php",
                  "request": "launch",
                  "port": 9003,
                  "pathMappings": {
                      "/var/www/html": "${workspaceFolder}"
                  },
                  "hostname": "localhost"
              }
          ]
      }
    ```
5. Run the following command in the Windows Powershell. It allows WSL through the firewall, otherwise breakpoints might not be hitten.
    ```powershell
    New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow
    ```

### Xdebug & PhpStorm

1.  First, install the [Chrome Xdebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc). After installed, right click on the Chrome icon for it and go to Options. Under IDE Key, select PhpStorm from the list to set the IDE Key to "PHPSTORM", then click Save.

2.  Next, enable Xdebug debugging in the PHP container by running: `bin/xdebug enable`.

3.  Then, open `PhpStorm > Preferences > PHP` and configure:

    * `CLI Interpreter`
        * Create a new interpreter from the `From Docker, Vagrant, VM...` list.
        * Select the Docker Compose option.
        * For Server, select `Docker`. If you don't have Docker set up as a server, create one and name it `Docker`.
        * For Configuration files, add both the `compose.yaml` and `compose.dev.yaml` files from your project directory.
        * For Service, select `phpfpm`, then click OK.
        * Name this CLI Interpreter `phpfpm`, then click OK again.

    * `Path mappings`
        * There is no need to define a path mapping in this area.

4. Open `PhpStorm > Preferences > PHP > Debug` and ensure Debug Port is set to `9000,9003`.

5. Open `PhpStorm > Preferences > PHP > Servers` and create a new server:

    * For the Name, set this to the value of your domain name (ex. `magento.test`).
    * For the Host, set this to the value of your domain name (ex. `magento.test`).
    * Keep port set to `80`.
    * Check the "Use path mappings" box and map `src` to the absolute path of `/var/www/html`.

6. Go to `Run > Edit Configurations` and create a new `PHP Remote Debug` configuration.

    * Set the Name to the name of your domain (ex. `magento.test`).
    * Check the `Filter debug connection by IDE key` checkbox, select the Server you just setup.
    * For IDE key, enter `PHPSTORM`. This value should match the IDE Key value set by the Chrome Xdebug Helper.
    * Click OK to finish setting up the remote debugger in PHPStorm.

7. Open up `pub/index.php` and set a breakpoint near the end of the file.

    * Start the debugger with `Run > Debug 'magento.test'`, then open up a web browser.
    * Ensure the Chrome Xdebug helper is enabled by clicking on it and selecting Debug. The icon should turn bright green.
    * Navigate to your Magento store URL, and Xdebug should now trigger the debugger within PhpStorm at the toggled breakpoint.

### SSH

Since version `40.0.0`, this project supports connecting to Docker with SSH/SFTP. This means that if you solely use either PhpStorm or VSCode, you no longer need to selectively mount host volumes in order to gain bi-directional sync capabilities from host to container. This will enable full speed in the native filesystem, as all files will be stored directly in the `appdata` container volume, rather than being synced from the host. This is especially useful if you'd like to sync larger directories such as `generated`, `pub` & `vendor`.

Copy `compose.dev-ssh.yaml` to `compose.dev.yaml` before installing Magento to take advantage of this setup. Then, create an SFTP connection at  Preferences -> Build, Execution, Deployment -> Deployment. Connect to `localhost` and use `app` for the username & password. You can set additional options for working with Magento in PhpStorm at Preferences -> Build, Execution, Deployment -> Deployment -> Options.

Note that you must use your IDE's SSH/SFTP functionality, otherwise changes will not be synced. To re-sync your host environment at any time, run:

```
bin/copyfromcontainer --all
```

### Linux

Running Docker on Linux should be pretty straight-forward. Note that you need to run some [post install commands](https://docs.docker.com/install/linux/linux-postinstall/) as well as [installing Docker Compose](https://docs.docker.com/compose/install/) before continuing. These steps are taken care of automatically with Docker Desktop, but not on Linux.

Copy `compose.dev-linux.yaml` to `compose.dev.yaml` before installing Magento to take advantage of this setup.

#### Install necessary dependencies

To ensure proper functionality, the docker-magento setup requires a few system dependencies to be installed on Linux. To install these dependencies, please execute the following command from the terminal:

```
sudo apt install curl libnss3-tools unzip rsync
```

#### The host.docker.internal hostname

The `host.docker.internal` hostname is used on Docker for Mac/Windows to reference the Docker daemon. On Linux, this hostname does not exist.

This hostname is [hard-coded in the php.ini file](images/php/8.1/conf/php.ini#L8). To make this hostname resolve, add `"host.docker.internal:172.17.0.1"` to the `app.extra_hosts` parameter of `compose.yaml`, replacing `172.17.0.1` with the result of:

```
docker run --rm alpine ip route | awk 'NR==1 {print $3}'
```

You must also create a new entry in your `/etc/hosts` file using the same IP:

```
172.17.0.1 host.docker.internal
```

#### Extra settings

To enable Xdebug on Linux, you may also need to open port 9003 on the firewall by running:

```
sudo iptables -A INPUT -p tcp --dport 9003 -j ACCEPT
```

You may also have to increase a virtual memory map count on the host system which is required by [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).

Add the following line to the `/etc/sysctl.conf` file on your host:

```
vm.max_map_count=262144
```

### Blackfire.io

These docker images have built-in support for Blackfire.io. To use it, first register your server ID and token with the Blackfire agent:

```
bin/root blackfire-agent --register --server-id={YOUR_SERVER_ID} --server-token={YOUR_SERVER_TOKEN}
```

Next, open up the `bin/start` helper script and uncomment the line:

```
#bin/root /etc/init.d/blackfire-agent start
```

Finally, restart the containers with `bin/restart`. After doing so, everything is now configured and you can use a browser extension to profile your Magento store with Blackfire.

### Cloudflare Tunnel

These docker images have built-in support for Cloudflare Tunnel. It can be useful for testing implementations that require some third-party integrations involving allow-listing domains. Since your local app cannot be allow-listed by other services, you can use Cloudflare Tunnel to get a public hostname that can be allow-listed on the other service.

To use it:

- First, create a tunnel in Cloudflare Zero Trust and add the token to `env/cloudflare.env`.
- Next, uncomment Cloudflare Tunnel section in main `compose.yaml`.
- Finally, restart the containers with `bin/restart`.

In Cloudflare Tunnel configuration, configure the service URL to use type `HTTPS` and a URL of `{name of app container}:{HTTPS port of app container}`. For examplem, `demo-app-1:8443`. Enable the `No TLS Verify` option, since our local certificates are self-signed. You should now be able to access your app via the public hostname defined in Cloudflare Tunnel.

NOTE: Do not leave instances with Cloudflare Tunnel enabled running long-term, as your instance is publicly available to the world. You should ideally turn off tunnel container once testing is finished.

### MFTF

To work with MFTF you will need to first enable the `selenium` image in the `compose.dev.yaml` file. Then, you will need to run the following.

1. Run mftf build process `bin/mftf build:project`. This should build the basic setup for mftf in your project.
2. Update the `extra_host` values to match your Magento URL and IP in `compose.dev.yaml`.
3. Update the values in `src/dev/tests/acceptance/.env`, including adding the new line `SELENIUM_HOST=selenium` to define the host Codeception should connect to.
4. Run a sample test `bin/mftf run:test AdminLoginSuccessfulTest`.
5. Update your `nginx.conf` file to allow access to the dev section with the following, before the final `deny all` section:

```
location ~* ^/dev/tests/acceptance/utils($|/) {
    root $MAGE_ROOT;
    location ~ ^/dev/tests/acceptance/utils/command.php {
        fastcgi_pass   fastcgi_backend;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

For debugging, you can connect to the selenium image using a VCN client.

- Connect with the VCN option and `127.0.0.1:5900`, (default password: `secret`)
- Run `bin/mftf doctor` to validate all sections are setup correctly.

Find more info [here](https://devdocs.magento.com/mftf/docs/getting-started.html) about mftf configuration.

### Grunt + LiveReload for Frontend Development

#### Create a new theme and make it active

Create your new theme at `app/design/frontend/VendorName/theme-name`, with the related `composer.json`, `registration.php` and `theme.xml` files.

Make your new theme active at Admin > Content > Design > Configuration. Click the Edit button next to Global Scope, and set the Applied Theme to your new theme name, and click Save Configuration.

#### Load the LiveReload client file

To create a connection to LiveReload, you'll need to insert the LiveReload script into your theme. You can do this by creating a file in your theme at `Magento_Theme/layout/default_head_blocks.xml` with the contents:

```xml
<?xml version="1.0"?>
<page xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:View/Layout/etc/page_configuration.xsd">
    <head>
        <script defer="true" src="/livereload.js?port=443" src_type="url"/>
    </head>
</page>
```

The "?port=443" parameter is important, otherwise the `livereload.js` script won't work.

While we're at it, let's also create an initial LESS file so we have something to test. Create a new file in your theme at `web/css/source/_extend.less` with the contents:

```css
body {
    background: white;
}
```

You'll need to clear the Magento cache to enable your module, and make sure this layout XML update is properly loaded.

Your new theme should now be active at `https://yourdomain.test`. Since this is a new theme, it should appear the same as the parent theme defined in your theme.xml file, which is usually Blank.

#### Set up Grunt

Run `bin/setup-grunt`. This will set up the Grunt configuration files for your new theme. It's important to run this step after setting up your new theme, not before.

#### Start the Grunt watcher

Grunt can watch for filesystem changes by running `bin/grunt watch`. You can optionally pass in the `--verbose` or `-v` flag to toggle verbose mode on. This will let you know what's going on under the hood, so you can be sure it is compiling & watching the correct files, and updating them as changes are made.

#### LiveReload Browser extension

Running the `grunt watch` process also spawns the LiveReload server. Your browser needs to connect to this server, and this is done by installing the [LiveReload browser extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en).

In your browser, be sure to also open the Google Chrome Dev Tools, go to the Network tab, and click "Disable cache". This will ensure the browser does not long-cache static file assets, such as JavaScript & CSS files, which is important during development.

Ensure the LiveReload browser icon has been toggled on, and refresh the page. We can confirm the LiveReload script is loaded by going to the Network tab and ensuring the `livereload.js` file is loaded, and that it also spawns off a new websocket request to `/livereload`.

#### Test LiveReload

Since this is all set, let's update the CSS file to a different background color:

```css
body {
    background: blue;
}
```

Upon saving this file, we will see the Grunt watcher detect the changes, and your browser should automatically load the new style without you needing to refresh the page, and without a full browser refresh.

### PHP-SPX

The images also have additional profiler-tracers built-in to the <a href="https://github.com/NoiseByNorthwest/php-spx/tree/master#web-ui" target="_blank">Web UI.</a>

To access the control panel, just open the following URL: `https://magento.test/?SPX_UI_URI=/`

**Suggested Configuration**

- Enabled: Checked
- Automatic start: Checked
- Profile internal functions: Unchecked
- Sampling: 5ms
- Max profiling depth: Unlimited
- Additional metrics: Unselected

Changing any options on this page set cookies for the domain for these settings. After then visiting a page on the frontend, you can navigate back to the GUI and scroll to the bottom of the page, and click the related request to view the trace of the request & response.

Profiling is also possible via command line, or curl:

```
SPX_REPORT=full SPX_ENABLED=1 SPX_SAMPLING_PERIOD=5000 bin/magento {command_name}
curl --cookie "SPX_REPORT=full; SPX_ENABLED=1; SPX_SAMPLING_PERIOD=5000" https://magento.test/
```

Additional information of how to work with SPX is available at https://www.youtube.com/watch?v=xk-JiBLsKfA

<div align="center">
  <p>Mark Shust's Docker Configuration for Magento</p>
  <img src="https://img.shields.io/badge/magento-2.X-brightgreen.svg?logo=magento&longCache=true" alt="Supported Magento Versions" />
  <a href="https://hub.docker.com/r/markoshust/magento-php/" target="_blank"><img src="https://img.shields.io/docker/pulls/markoshust/magento-php.svg?label=php%20docker%20pulls" alt="Docker Hub Pulls - PHP" /></a>
  <a href="https://hub.docker.com/r/markoshust/magento-nginx/" target="_blank"><img src="https://img.shields.io/docker/pulls/markoshust/magento-nginx.svg?label=nginx%20docker%20pulls" alt="Docker Hub Pulls - Nginx" /></a>
  <a href="https://github.com/chuccv/docker-magento/graphs/commit-activity" target="_blank"><img src="https://img.shields.io/badge/maintained%3F-yes-brightgreen.svg" alt="Maintained - Yes" /></a>
  <img src="https://img.shields.io/badge/apple%20silicon%20support-yes-brightgreen" alt="Apple Silicon Support" />
  <a href="https://opensource.org/licenses/MIT" target="_blank"><img src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>
</div>

## Table of contents

- [Docker Hub](#docker-hub)
- [Free Course](#free-course)
- [Usage](#usage)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Updates](#updates)
- [Custom CLI Commands](#custom-cli-commands)
- [Misc Info](#misc-info)
- [Known Issues](#known-issues)
- [Credits](#credits)
- [License](#license)

## Docker Hub

View Dockerfiles for the latest tags:

- [markoshust/magento-nginx (Docker Hub)](https://hub.docker.com/r/markoshust/magento-nginx/)
  - [`1.18`, `1.18-8`](images/nginx/1.18)
  - [`1.22`, `1.22-0`](images/nginx/1.22)
  - [`1.24`, `1.24-0`](images/nginx/1.24)
- [markoshust/magento-php (Docker Hub)](https://hub.docker.com/r/markoshust/magento-php/)
  - [`8.1-fpm`, `8.1-fpm-7`](images/php/8.1)
  - [`8.2-fpm`, `8.2-fpm-6`](images/php/8.2)
  - [`8.3-fpm`, `8.3-fpm-4`](images/php/8.3)
  - [`8.4-fpm-dev`](images/php/8.4)
- [markoshust/magento-opensearch (Docker Hub)](https://hub.docker.com/r/markoshust/magento-opensearch/)
  - [`1.2`, `1.2-0`](images/opensearch/1.2)
  - [`2.5`, `2.5-1`](images/opensearch/2.5)
  - [`2.12`, `2.12-0`](images/opensearch/2.12)
- [markoshust/magento-elasticsearch (Docker Hub)](https://hub.docker.com/r/markoshust/magento-elasticsearch/)
  - [`7.16`, `7.16-0`](images/elasticsearch/7.16)
  - [`7.17`, `7.17-1`](images/elasticsearch/7.17)
  - [`8.4`, `8.4-0`](images/elasticsearch/8.4)
  - [`8.5`, `8.5-0`](images/elasticsearch/8.5)
  - [`8.7`, `8.7-0`](images/elasticsearch/8.7)
  - [`8.11`, `8.11-0`](images/elasticsearch/8.11)
  - [`8.13`, `8.13-0`](images/elasticsearch/8.13)
- [markoshust/magento-rabbitmq (Docker Hub)](https://hub.docker.com/r/markoshust/magento-rabbitmq/)
  - [`3.8`, `3.8-0`](images/rabbitmq/3.8)
  - [`3.9`, `3.9-0`](images/rabbitmq/3.9)
  - [`3.11`, `3.11-1`](images/rabbitmq/3.11)
  - [`3.12`, `3.12-0`](images/rabbitmq/3.12)
- [markoshust/ssh (Docker Hub)](https://hub.docker.com/r/markoshust/magento-ssh/)
  - [`latest`](images/ssh)

## Free Course

This course is sponsored by <a href="https://m.academy" target="_blank">M.academy</a>, the simplest way to learn Magento.

<a href="https://m.academy" target="_blank"><img src="docs/macademy-logo.png" alt="M.academy"></a>

A free screencast course is available (which was fully refreshed in December 2021), which details the basic usage of this project:

<a href="https://m.academy/courses/set-up-magento-2-development-environment-docker" target="_blank">
<img src="docs/set-up-magento-2-development-environment-docker-og.png" alt="Set Up a Magento 2 Development Environment with Docker" width="400"><br/>
Set Up a Magento 2 Development Environment with Docker
</a>

### Course Curriculum

#### Intro

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36738848" target="_blank">Quick hi & welcome from Mark!</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36738860" target="_blank">About the course format</a>

#### Initial Project Setup

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9205849" target="_blank">Install Docker Desktop & configure preferences</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/8974570" target="_blank">Set up Magento with the automated onelinesetup script</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064259" target="_blank">Set up Magento manually from a custom Git branch</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9283467" target="_blank">Set up Docker for an existing Magento project</a>

#### The Basics of docker-magento

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064258" target="_blank">Execute docker-magento helper scripts</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9331008" target="_blank">Start, stop, restart and check container status</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064269" target="_blank">Execute bin/magento and composer within Docker containers</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36150902" target="_blank">Install Magento sample data</a>

#### Docker Filesystem & Data Volumes

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064334" target="_blank">Understand Docker volumes & host bind mounts</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064338" target="_blank">Manage files & folders within Docker containers</a>

#### PhpStorm

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9748834" target="_blank">Set up a docker-magento project in PhpStorm</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9763893" target="_blank">Set up the Magento PhpStorm plugin</a>

#### Code Quality Tools

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/52640115" target="_blank">Configure PHPCS (PHP CodeSniffer) for Magento</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/52642491" target="_blank">Configure PHPCSF (PHP CodeSniffer Fixer) for Magento</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/52643314" target="_blank">Configure PHPMD (PHP Mess Detector) for Magento</a>

#### Xdebug

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064478" target="_blank">Install the Xdebug helper browser plugin for Chrome & PhpStorm</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064482" target="_blank">Enable disable check the status of Xdebug</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064615" target="_blank">Configure PhpStorm for Xdebug connections</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064617" target="_blank">Trigger an Xdebug breakpoint in PhpStorm</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36677538" target="_blank">Trigger an Xdebug breakpoint for CLI commands in PhpStorm</a>

#### Customize Server Configurations

- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36702830" target="_blank">Understand the docker-compose application structure</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36702861" target="_blank">Increase the PHP memory limit in php.ini</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064349" target="_blank">Increase the Nginx request timeout in nginx.conf</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/36703258" target="_blank">Increase the MySQL buffer pool size with command or in my.cnf</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/9064350" target="_blank">Install a new PHP extension by building a custom Docker image</a>
- <a href="https://courses.m.academy/courses/set-up-magento-2-development-environment-docker/lectures/14780970" target="_blank">Configure multi-store instances in Docker with Nginx</a>

## Known Issues

There are currently no large known issues or workarounds needed to use docker-magento with your Magento project. If you find any, please [report them](https://github.com/chuccv/docker-magento/issues)!

## Credits

### M.academy

This course is sponsored by <a href="https://m.academy" target="_blank">M.academy</a>, the simplest way to learn Magento.

<a href="https://m.academy" target="_blank"><img src="docs/macademy-logo.png" alt="M.academy"></a>

### Mark Shust

My name is Mark Shust and I'm the creator of this repo. I'm a <a href="https://www.credly.com/users/mark-shust/badges" target="_blank">6X Adobe Commerce Certified Developer</a> and have been involved with Magento since the early days (v0.8!). I create technical education courses full-time for my company, <a href="https://m.academy" target="_blank">M.academy</a>.

- <a href="https://m.academy/courses" target="_blank">🖥️ See my Magento lessons & courses</a>
- <a href="https://m.academy/articles" target="_blank">📖 Read my technical articles</a>
- <a href="https://youtube.com/chuccv" target="_blank">🎥 Watch my YouTube videos</a>
- <a href="https://www.linkedin.com/in/chuccv/" target="_blank">🔗 Connect on LinkedIn</a>
- <a href="https://twitter.com/chuccv" target="_blank">🐦 Follow me on X</a>
- <a href="mailto:mark@m.academy">💌 Contact me</a>

## License

[MIT](https://opensource.org/licenses/MIT)
