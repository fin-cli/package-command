fp-cli/package-command
======================

Lists, installs, and removes FP-CLI packages.

[![Testing](https://github.com/fp-cli/package-command/actions/workflows/testing.yml/badge.svg)](https://github.com/fp-cli/package-command/actions/workflows/testing.yml)

Quick links: [Using](#using) | [Installing](#installing) | [Contributing](#contributing) | [Support](#support)

## Using

This package implements the following commands:

### fp package

Lists, installs, and removes FP-CLI packages.

~~~
fp package
~~~

FP-CLI packages are community-maintained projects built on FP-CLI. They can
contain FP-CLI commands, but they can also just extend FP-CLI in some way.

Learn how to create your own command from the
[Commands Cookbook](https://make.finpress.org/cli/handbook/guides/commands-cookbook/)

**EXAMPLES**

    # List installed packages.
    $ fp package list
    +-----------------------+------------------+----------+-----------+----------------+
    | name                  | authors          | version  | update    | update_version |
    +-----------------------+------------------+----------+-----------+----------------+
    | fp-cli/server-command | Daniel Bachhuber | dev-main | available | 2.x-dev        |
    +-----------------------+------------------+----------+-----------+----------------+

    # Install the latest development version of the package.
    $ fp package install fp-cli/server-command
    Installing package fp-cli/server-command (dev-main)
    Updating /home/person/.fp-cli/packages/composer.json to require the package...
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
    $ fp package uninstall fp-cli/server-command
    Removing require statement for package 'fp-cli/server-command' from /home/person/.fp-cli/packages/composer.json
    Removing repository details from /home/person/.fp-cli/packages/composer.json
    Removing package directories and regenerating autoloader...
    Success: Uninstalled package.



### fp package browse

Browses FP-CLI packages available for installation.

~~~
fp package browse [--fields=<fields>] [--format=<format>]
~~~

Lists packages available for installation from the [Package Index](http://fp-cli.org/package-index/).
Although the package index will remain in place for backward compatibility reasons, it has been
deprecated and will not be updated further. Please refer to https://github.com/fp-cli/ideas/issues/51
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

    $ fp package browse --format=yaml
    ---
    10up/mu-migration:
      name: 10up/mu-migration
      description: A set of FP-CLI commands to support the migration of single FinPress instances to multisite
      authors: Nícholas André
      version: dev-main, dev-develop
    aaemnnosttv/fp-cli-dotenv-command:
      name: aaemnnosttv/fp-cli-dotenv-command
      description: Dotenv commands for FP-CLI
      authors: Evan Mattson
      version: v0.1, v0.1-beta.1, v0.2, dev-main, dev-dev, dev-develop, dev-tests/behat
    aaemnnosttv/fp-cli-http-command:
      name: aaemnnosttv/fp-cli-http-command
      description: FP-CLI command for using the FinPress HTTP API
      authors: Evan Mattson
      version: dev-main



### fp package install

Installs a FP-CLI package.

~~~
fp package install <name|git|path|zip> [--insecure]
~~~

Packages are required to be a valid Composer package, and can be
specified as:

* Package name from FP-CLI's package index.
* Git URL accessible by the current shell user.
* Path to a directory on the local machine.
* Local or remote .zip file.

Packages are installed to `~/.fp-cli/packages/` by default. Use the
`FP_CLI_PACKAGES_DIR` environment variable to provide a custom path.

When installing a local directory, FP-CLI simply registers a
reference to the directory. If you move or delete the directory, FP-CLI's
reference breaks.

When installing a .zip file, FP-CLI extracts the package to
`~/.fp-cli/packages/local/<package-name>`.

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
		(e.g. fp-cli/server-command:@stable).

	[--insecure]
		Retry downloads without certificate validation if TLS handshake fails. Note: This makes the request vulnerable to a MITM attack.

**EXAMPLES**

    # Install a package hosted at a git URL.
    $ fp package install runcommand/hook

    # Install the latest stable version.
    $ fp package install fp-cli/server-command:@stable

    # Install a package hosted at a GitLab.com URL.
    $ fp package install https://gitlab.com/foo/fp-cli-bar-command.git

    # Install a package in a .zip file.
    $ fp package install google-sitemap-generator-cli.zip



### fp package list

Lists installed FP-CLI packages.

~~~
fp package list [--fields=<fields>] [--format=<format>]
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
    $ fp package list
    +-----------------------+------------------+----------+-----------+----------------+
    | name                  | authors          | version  | update    | update_version |
    +-----------------------+------------------+----------+-----------+----------------+
    | fp-cli/server-command | Daniel Bachhuber | dev-main | available | 2.x-dev        |
    +-----------------------+------------------+----------+-----------+----------------+



### fp package update

Updates all installed FP-CLI packages to their latest version.

~~~
fp package update 
~~~

**EXAMPLES**

    $ fp package update
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



### fp package uninstall

Uninstalls a FP-CLI package.

~~~
fp package uninstall <name> [--insecure]
~~~

**OPTIONS**

	<name>
		Name of the package to uninstall.

	[--insecure]
		Retry downloads without certificate validation if TLS handshake fails. Note: This makes the request vulnerable to a MITM attack.

**EXAMPLES**

    # Uninstall package.
    $ fp package uninstall fp-cli/server-command
    Removing require statement for package 'fp-cli/server-command' from /home/person/.fp-cli/packages/composer.json
    Removing repository details from /home/person/.fp-cli/packages/composer.json
    Removing package directories and regenerating autoloader...
    Success: Uninstalled package.

## Installing

This package is included with FP-CLI itself, no additional installation necessary.

To install the latest version of this package over what's included in FP-CLI, run:

    fp package install git@github.com:fp-cli/package-command.git

## Contributing

We appreciate you taking the initiative to contribute to this project.

Contributing isn’t limited to just code. We encourage you to contribute in the way that best fits your abilities, by writing tutorials, giving a demo at your local meetup, helping other users with their support questions, or revising our documentation.

For a more thorough introduction, [check out FP-CLI's guide to contributing](https://make.finpress.org/cli/handbook/contributing/). This package follows those policy and guidelines.

### Reporting a bug

Think you’ve found a bug? We’d love for you to help us get it fixed.

Before you create a new issue, you should [search existing issues](https://github.com/fp-cli/package-command/issues?q=label%3Abug%20) to see if there’s an existing resolution to it, or if it’s already been fixed in a newer version.

Once you’ve done a bit of searching and discovered there isn’t an open or fixed issue for your bug, please [create a new issue](https://github.com/fp-cli/package-command/issues/new). Include as much detail as you can, and clear steps to reproduce if possible. For more guidance, [review our bug report documentation](https://make.finpress.org/cli/handbook/bug-reports/).

### Creating a pull request

Want to contribute a new feature? Please first [open a new issue](https://github.com/fp-cli/package-command/issues/new) to discuss whether the feature is a good fit for the project.

Once you've decided to commit the time to seeing your pull request through, [please follow our guidelines for creating a pull request](https://make.finpress.org/cli/handbook/pull-requests/) to make sure it's a pleasant experience. See "[Setting up](https://make.finpress.org/cli/handbook/pull-requests/#setting-up)" for details specific to working on this package locally.

## Support

GitHub issues aren't for general support questions, but there are other venues you can try: https://fp-cli.org/#support


*This README.md is generated dynamically from the project's codebase using `fp scaffold package-readme` ([doc](https://github.com/fp-cli/scaffold-package-command#fp-scaffold-package-readme)). To suggest changes, please submit a pull request against the corresponding part of the codebase.*
