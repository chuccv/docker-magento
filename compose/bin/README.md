# Bin Directory - Helper Scripts

This directory contains helper scripts that simplify working with the Docker-based Magento development environment. These scripts act as wrappers to execute commands inside Docker containers without needing to remember complex Docker Compose commands.

## Overview

The `bin` directory provides a collection of command-line utilities that abstract Docker operations, making it easier to:
- Execute Magento CLI commands
- Run PHP, Composer, Node.js, and other tools
- Manage Docker containers
- Handle database operations
- Configure development tools (Xdebug, Blackfire, etc.)
- Perform common Magento setup and maintenance tasks

## Usage

All scripts in this directory are executable bash scripts. You can run them directly from the project root:

```bash
bin/<script-name> [arguments]
```

For example:
```bash
bin/magento cache:flush
bin/composer install
bin/mysql
```

## Main Scripts

### Magento Commands

#### `magento`
Runs the Magento CLI command-line tool. This is the main entry point for all Magento operations.

**Usage:**
```bash
bin/magento <command> [options]
```

**Examples:**
```bash
bin/magento cache:flush
bin/magento setup:upgrade
bin/magento indexer:reindex
bin/magento setup:di:compile
```

**Note:** This script is a PHP CLI entry point that bootstraps the Magento application. It must be run from within the Docker container context.

### Container Management

#### `cli`
Execute any CLI command inside the `phpfpm` container.

**Usage:**
```bash
bin/cli <command> [arguments]
```

**Examples:**
```bash
bin/cli ls -la
bin/cli php -v
bin/cli whoami
```

#### `clinotty`
Same as `cli`, but runs without TTY (useful for scripts and automation).

**Usage:**
```bash
bin/clinotty <command> [arguments]
```

**Examples:**
```bash
bin/clinotty chmod u+x bin/magento
bin/clinotty php script.php
```

#### `bash`
Drop into an interactive bash shell inside the `phpfpm` container.

**Usage:**
```bash
bin/bash
```

#### `root`
Execute commands as root user inside the container.

**Usage:**
```bash
bin/root <command> [arguments]
```

**Examples:**
```bash
bin/root apt-get update
bin/root chown -R app:app /var/www/html
```

#### `rootnotty`
Execute commands as root without TTY.

**Usage:**
```bash
bin/rootnotty <command> [arguments]
```

### Docker Operations

#### `start`
Start all Docker containers for the project.

**Usage:**
```bash
bin/start [--no-dev]
```

**Options:**
- `--no-dev`: Start containers without development tools

#### `stop`
Stop all project containers.

**Usage:**
```bash
bin/stop
```

#### `restart`
Stop and then start all containers.

**Usage:**
```bash
bin/restart
```

#### `status`
Check the status of all containers.

**Usage:**
```bash
bin/status
```

#### `remove`
Remove all containers.

**Usage:**
```bash
bin/remove
```

#### `removeall`
Remove all containers, networks, volumes, and images.

**Usage:**
```bash
bin/removeall
```

**Warning:** This will delete all Docker resources associated with the project.

### Package Management

#### `composer`
Run Composer commands inside the container.

**Usage:**
```bash
bin/composer <command> [options]
```

**Examples:**
```bash
bin/composer install
bin/composer update
bin/composer require vendor/package
bin/composer show
```

#### `npm`
Run npm commands inside the container.

**Usage:**
```bash
bin/npm <command> [options]
```

**Examples:**
```bash
bin/npm install
bin/npm run build
bin/npm --version
```

#### `node`
Run Node.js commands inside the container.

**Usage:**
```bash
bin/node <command> [options]
```

**Examples:**
```bash
bin/node --version
bin/node script.js
```

### Database Operations

#### `mysql`
Access the MySQL CLI with database configuration from `env/db.env`.

**Usage:**
```bash
bin/mysql [options]
bin/mysql < file.sql  # Import SQL file
```

**Examples:**
```bash
bin/mysql
bin/mysql -e "SHOW TABLES;"
bin/mysql < backup.sql
```

#### `mysqldump`
Export/backup the Magento database.

**Usage:**
```bash
bin/mysqldump [options] > output.sql
```

**Examples:**
```bash
bin/mysqldump > backup.sql
bin/mysqldump --single-transaction > backup.sql
```

### File Operations

#### `copytocontainer`
Copy files or folders from host to container.

**Usage:**
```bash
bin/copytocontainer [path]
bin/copytocontainer --all  # Copy all files
```

**Examples:**
```bash
bin/copytocontainer vendor
bin/copytocontainer app/code
bin/copytocontainer --all
```

#### `copyfromcontainer`
Copy files or folders from container to host.

**Usage:**
```bash
bin/copyfromcontainer [path]
bin/copyfromcontainer --all  # Copy all files
```

**Examples:**
```bash
bin/copyfromcontainer vendor
bin/copyfromcontainer generated
bin/copyfromcontainer --all
```

### Setup & Installation

#### `setup`
Run the Magento setup process to install Magento from source code.

**Usage:**
```bash
bin/setup [domain-name]
```

**Examples:**
```bash
bin/setup
bin/setup magento.test
```

#### `download`
Download a specific Magento version from Composer.

**Usage:**
```bash
bin/download [edition] [version]
```

**Arguments:**
- `edition`: `community` (default), `enterprise`, or `mageos`
- `version`: Magento version (defaults to latest if not specified)

**Examples:**
```bash
bin/download
bin/download community 2.4.8
bin/download enterprise 2.4.7-p3
bin/download mageos
```

#### `setup-domain`
Configure Magento domain name.

**Usage:**
```bash
bin/setup-domain <domain>
```

**Examples:**
```bash
bin/setup-domain magento.test
bin/setup-domain local.magento.com
```

#### `setup-ssl`
Generate SSL certificates for one or more domains.

**Usage:**
```bash
bin/setup-ssl <domain1> [domain2] ...
```

**Examples:**
```bash
bin/setup-ssl magento.test
bin/setup-ssl magento.test admin.magento.test
```

### Development Tools

#### `xdebug`
Enable, disable, or check Xdebug status.

**Usage:**
```bash
bin/xdebug [enable|disable|status|mode]
```

**Examples:**
```bash
bin/xdebug enable
bin/xdebug disable
bin/xdebug status
bin/xdebug debug  # Set custom mode
```

#### `debug-cli`
Enable Xdebug for `bin/magento` commands.

**Usage:**
```bash
bin/debug-cli enable [IDE_KEY]
```

**Examples:**
```bash
bin/debug-cli enable
bin/debug-cli enable PHPSTORM
```

#### `blackfire`
Enable or disable Blackfire profiler.

**Usage:**
```bash
bin/blackfire [enable|disable|status]
```

**Examples:**
```bash
bin/blackfire enable
bin/blackfire disable
bin/blackfire status
```

#### `spx`
Enable or disable SPX profiler.

**Usage:**
```bash
bin/spx [enable|disable]
```

**Examples:**
```bash
bin/spx enable
bin/spx disable
```

### Code Quality

#### `phpcs`
Run PHP CodeSniffer with Magento 2 coding standards.

**Usage:**
```bash
bin/phpcs <path>
```

**Examples:**
```bash
bin/phpcs app/code
bin/phpcs app/code/Vendor/Module
```

#### `phpcbf`
Auto-fix PHP CodeSniffer errors.

**Usage:**
```bash
bin/phpcbf <path>
```

**Examples:**
```bash
bin/phpcbf app/code
bin/phpcbf app/code/Vendor/Module
```

#### `analyse`
Run PHPStan static analysis.

**Usage:**
```bash
bin/analyse <path>
```

**Examples:**
```bash
bin/analyse app/code
bin/analyse app/code/Vendor/Module
```

### Utilities

#### `log`
Monitor Magento log files.

**Usage:**
```bash
bin/log [log-file]
```

**Examples:**
```bash
bin/log              # Tail all log files
bin/log system.log
bin/log exception.log
bin/log debug.log
```

#### `cache-clean`
Access the cache-clean CLI for intelligent cache management.

**Usage:**
```bash
bin/cache-clean [cache-type]
```

**Examples:**
```bash
bin/cache-clean config
bin/cache-clean full_page
bin/cache-clean block_html
```

#### `fixperms`
Fix filesystem permissions within the container.

**Usage:**
```bash
bin/fixperms
```

#### `fixowns`
Fix filesystem ownership within the container.

**Usage:**
```bash
bin/fixowns
```

#### `cron`
Start or stop the Magento cron service.

**Usage:**
```bash
bin/cron [start|stop]
```

**Examples:**
```bash
bin/cron start
bin/cron stop
```

#### `redis`
Run Redis CLI commands.

**Usage:**
```bash
bin/redis <command>
```

**Examples:**
```bash
bin/redis redis-cli monitor
bin/redis redis-cli info
bin/redis redis-cli flushall
```

#### `magento-version`
Display the installed Magento version.

**Usage:**
```bash
bin/magento-version
```

### Advanced Tools

#### `grunt`
Run Grunt JavaScript task runner.

**Usage:**
```bash
bin/grunt <task>
```

**Examples:**
```bash
bin/grunt exec
bin/grunt watch
bin/grunt less
```

#### `n98-magerun2`
Access the n98-magerun2 CLI tool.

**Usage:**
```bash
bin/n98-magerun2 <command>
```

**Examples:**
```bash
bin/n98-magerun2 dev:console
bin/n98-magerun2 sys:info
bin/n98-magerun2 cache:clean
```

#### `mftf`
Run Magento Functional Testing Framework commands.

**Usage:**
```bash
bin/mftf <command>
```

**Examples:**
```bash
bin/mftf build:project
bin/mftf run:test AdminLoginSuccessfulTest
bin/mftf doctor
```

#### `deploy`
Run the standard Magento deployment process.

**Usage:**
```bash
bin/deploy [locale1] [locale2] ...
```

**Examples:**
```bash
bin/deploy
bin/deploy en_US nl_NL
```

## Common Workflows

### Initial Setup
```bash
bin/download community 2.4.8
bin/setup magento.test
bin/setup-ssl magento.test
```

### Daily Development
```bash
bin/start
bin/magento cache:flush
bin/composer require vendor/package
bin/magento setup:upgrade
```

### Database Backup & Restore
```bash
# Backup
bin/mysqldump > backup.sql

# Restore
bin/mysql < backup.sql
```

### Code Quality Check
```bash
bin/phpcs app/code/Vendor/Module
bin/phpcbf app/code/Vendor/Module
bin/analyse app/code/Vendor/Module
```

### Debugging
```bash
bin/xdebug enable
bin/debug-cli enable PHPSTORM
# Set breakpoints in your IDE and run:
bin/magento cache:flush
```

## Notes

- All scripts assume you're running them from the project root directory (where `compose.yaml` is located)
- Scripts automatically handle Docker Compose configuration
- Most scripts require the containers to be running (`bin/start`)
- Some scripts may require root access on your host machine (e.g., for `/etc/hosts` modifications)
- Scripts use environment variables from the `env/` directory for configuration

## Troubleshooting

### Script not found
Make sure you're in the project root directory and the script has execute permissions:
```bash
chmod +x bin/<script-name>
```

### Container not running
Start containers first:
```bash
bin/start
```

### Permission errors
Fix permissions inside the container:
```bash
bin/fixperms
bin/fixowns
```

## See Also

- Main project README: `/README.md`
- Docker Compose configuration: `/compose/compose.yaml`
- Environment configuration: `/compose/env/`
