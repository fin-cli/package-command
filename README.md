fin-cli/package-command
======================

Lists, installs, and removes FIN-CLI packages.

[![Testing](https://github.com/fin-cli/package-command/actions/workflows/testing.yml/badge.svg)](https://github.com/fin-cli/package-command/actions/workflows/testing.yml)

Quick links: [Using](#using) | [Installing](#installing) | [Contributing](#contributing) | [Support](#support)

## Using

This package implements the following commands:

### fin package

Lists, installs, and removes FIN-CLI packages.

~~~
fin package
~~~

FIN-CLI packages are community-maintained projects built on FIN-CLI. They can
contain FIN-CLI commands, but they can also just extend FIN-CLI in some way.

Learn how to create your own command from the
[Commands Cookbook](https://make.finpress.org/cli/handbook/guides/commands-cookbook/)

**EXAMPLES**

    # List installed packages.
    $ fin package list
    +-----------------------+------------------+----------+-----------+----------------+
    | name                  | authors          | version  | update    | update_version |
    +-----------------------+------------------+----------+-----------+----------------+
    | fin-cli/server-command | Daniel Bachhuber | dev-main | available | 2.x-dev        |
    +-----------------------+------------------+----------+-----------+----------------+

    # Install the latest development version of the package.
    $ fin package install fin-cli/server-command
    Installing package fin-cli/server-command (dev-main)
    Updating /home/person/.fin-cli/packages/composer.json to require the package...
    Using Composer to install the package...
    ---
    Loading composer repositories with package information
    Updating dependencies
    Resolving dependencies through SAT
    Dependency resolution completed in 0.005 seconds
    Analyzed 732 packages to resolve dependencies
    Analyzed 1034 rules to resolve dependencies
     - Installing package
    Writing lock file
    Generating autoload files
    ---
    Success: Package installed.

    # Uninstall package.
    $ fin package uninstall fin-cli/server-command
    Removing require statement for package 'fin-cli/server-command' from /home/person/.fin-cli/packages/composer.json
    Removing repository details from /home/person/.fin-cli/packages/composer.json
    Removing package directories and regenerating autoloader...
    Success: Uninstalled package.



### fin package browse

Browses FIN-CLI packages available for installation.

~~~
fin package browse [--fields=<fields>] [--format=<format>]
~~~

Lists packages available for installation from the [Package Index](http://fin-cli.org/package-index/).
Although the package index will remain in place for backward compatibility reasons, it has been
deprecated and will not be updated further. Please refer to https://github.com/fin-cli/ideas/issues/51
to read about its potential replacement.

**OPTIONS**

	[--fields=<fields>]
		Limit the output to specific fields. Defaults to all fields.

	[--format=<format>]
		Render output in a particular format.
		---
		default: table
		options:
		  - table
		  - csv
		  - ids
		  - json
		  - yaml
		---

**AVAILABLE FIELDS**

These fields will be displayed by default for each package:

* name
* description
* authors
* version

There are no optionally available fields.

**EXAMPLES**

    $ fin package browse --format=yaml
    ---
    10up/mu-migration:
      name: 10up/mu-migration
      description: A set of FIN-CLI commands to support the migration of single FinPress instances to multisite
      authors: Nícholas André
      version: dev-main, dev-develop
    aaemnnosttv/fin-cli-dotenv-command:
      name: aaemnnosttv/fin-cli-dotenv-command
      description: Dotenv commands for FIN-CLI
      authors: Evan Mattson
      version: v0.1, v0.1-beta.1, v0.2, dev-main, dev-dev, dev-develop, dev-tests/behat
    aaemnnosttv/fin-cli-http-command:
      name: aaemnnosttv/fin-cli-http-command
      description: FIN-CLI command for using the FinPress HTTP API
      authors: Evan Mattson
      version: dev-main



### fin package install

Installs a FIN-CLI package.

~~~
fin package install <name|git|path|zip> [--insecure]
~~~

Packages are required to be a valid Composer package, and can be
specified as:

* Package name from FIN-CLI's package index.
* Git URL accessible by the current shell user.
* Path to a directory on the local machine.
* Local or remote .zip file.

Packages are installed to `~/.fin-cli/packages/` by default. Use the
`FIN_CLI_PACKAGES_DIR` environment variable to provide a custom path.

When installing a local directory, FIN-CLI simply registers a
reference to the directory. If you move or delete the directory, FIN-CLI's
reference breaks.

When installing a .zip file, FIN-CLI extracts the package to
`~/.fin-cli/packages/local/<package-name>`.

If Github token authorization is required, a GitHub Personal Access Token
(https://github.com/settings/tokens) can be used. The following command
will add a GitHub Personal Access Token to Composer's global configuration:
composer config -g github-oauth.github.com <GITHUB_TOKEN>
Once this has been added, the value used for <GITHUB_TOKEN> will be used
for future authorization requests.

**OPTIONS**

	<name|git|path|zip>
		Name, git URL, directory path, or .zip file for the package to install.
		Names can optionally include a version constraint
		(e.g. fin-cli/server-command:@stable).

	[--insecure]
		Retry downloads without certificate validation if TLS handshake fails. Note: This makes the request vulnerable to a MITM attack.

**EXAMPLES**

    # Install a package hosted at a git URL.
    $ fin package install runcommand/hook

    # Install the latest stable version.
    $ fin package install fin-cli/server-command:@stable

    # Install a package hosted at a GitLab.com URL.
    $ fin package install https://gitlab.com/foo/fin-cli-bar-command.git

    # Install a package in a .zip file.
    $ fin package install google-sitemap-generator-cli.zip



### fin package list

Lists installed FIN-CLI packages.

~~~
fin package list [--fields=<fields>] [--format=<format>]
~~~

**OPTIONS**

	[--fields=<fields>]
		Limit the output to specific fields. Defaults to all fields.

	[--format=<format>]
		Render output in a particular format.
		---
		default: table
		options:
		  - table
		  - csv
		  - ids
		  - json
		  - yaml
		---

**AVAILABLE FIELDS**

These fields will be displayed by default for each package:

* name
* authors
* version
* update
* update_version

These fields are optionally available:

* description

**EXAMPLES**

    # List installed packages.
    $ fin package list
    +-----------------------+------------------+----------+-----------+----------------+
    | name                  | authors          | version  | update    | update_version |
    +-----------------------+------------------+----------+-----------+----------------+
    | fin-cli/server-command | Daniel Bachhuber | dev-main | available | 2.x-dev        |
    +-----------------------+------------------+----------+-----------+----------------+



### fin package update

Updates all installed FIN-CLI packages to their latest version.

~~~
fin package update 
~~~

**EXAMPLES**

    $ fin package update
    Using Composer to update packages...
    ---
    Loading composer repositories with package information
    Updating dependencies
    Resolving dependencies through SAT
    Dependency resolution completed in 0.074 seconds
    Analyzed 1062 packages to resolve dependencies
    Analyzed 22383 rules to resolve dependencies
    Writing lock file
    Generating autoload files
    ---
    Success: Packages updated.



### fin package uninstall

Uninstalls a FIN-CLI package.

~~~
fin package uninstall <name> [--insecure]
~~~

**OPTIONS**

	<name>
		Name of the package to uninstall.

	[--insecure]
		Retry downloads without certificate validation if TLS handshake fails. Note: This makes the request vulnerable to a MITM attack.

**EXAMPLES**

    # Uninstall package.
    $ fin package uninstall fin-cli/server-command
    Removing require statement for package 'fin-cli/server-command' from /home/person/.fin-cli/packages/composer.json
    Removing repository details from /home/person/.fin-cli/packages/composer.json
    Removing package directories and regenerating autoloader...
    Success: Uninstalled package.

## Installing

This package is included with FIN-CLI itself, no additional installation necessary.

To install the latest version of this package over what's included in FIN-CLI, run:

    fin package install git@github.com:fin-cli/package-command.git

## Contributing

We appreciate you taking the initiative to contribute to this project.

Contributing isn’t limited to just code. We encourage you to contribute in the way that best fits your abilities, by writing tutorials, giving a demo at your local meetup, helping other users with their support questions, or revising our documentation.

For a more thorough introduction, [check out FIN-CLI's guide to contributing](https://make.finpress.org/cli/handbook/contributing/). This package follows those policy and guidelines.

### Reporting a bug

Think you’ve found a bug? We’d love for you to help us get it fixed.

Before you create a new issue, you should [search existing issues](https://github.com/fin-cli/package-command/issues?q=label%3Abug%20) to see if there’s an existing resolution to it, or if it’s already been fixed in a newer version.

Once you’ve done a bit of searching and discovered there isn’t an open or fixed issue for your bug, please [create a new issue](https://github.com/fin-cli/package-command/issues/new). Include as much detail as you can, and clear steps to reproduce if possible. For more guidance, [review our bug report documentation](https://make.finpress.org/cli/handbook/bug-reports/).

### Creating a pull request

Want to contribute a new feature? Please first [open a new issue](https://github.com/fin-cli/package-command/issues/new) to discuss whether the feature is a good fit for the project.

Once you've decided to commit the time to seeing your pull request through, [please follow our guidelines for creating a pull request](https://make.finpress.org/cli/handbook/pull-requests/) to make sure it's a pleasant experience. See "[Setting up](https://make.finpress.org/cli/handbook/pull-requests/#setting-up)" for details specific to working on this package locally.

## Support

GitHub issues aren't for general support questions, but there are other venues you can try: https://fin-cli.org/#support


*This README.md is generated dynamically from the project's codebase using `fin scaffold package-readme` ([doc](https://github.com/fin-cli/scaffold-package-command#fin-scaffold-package-readme)). To suggest changes, please submit a pull request against the corresponding part of the codebase.*
