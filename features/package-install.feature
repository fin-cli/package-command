Feature: Install FIN-CLI packages

  Background:
    When I run `fin package path`
    Then save STDOUT as {PACKAGE_PATH}

  Scenario: Install a package with an http package index url in package composer.json
    Given an empty directory
    And a composer.json file:
      """
      {
        "repositories": {
          "test" : {
            "type": "path",
            "url": "./dummy-package/"
          },
          "fin-cli": {
            "type": "composer",
            "url": "http://fin-cli.org/package-index/"
          }
        }
      }
      """
    And a dummy-package/composer.json file:
      """
      {
        "name": "fin-cli/restful",
        "description": "This is a dummy package we will install instead of actually installing the real package. This prevents the test from hanging indefinitely for some reason, even though it passes. The 'name' must match a real package as it is checked against the package index."
      }
      """
    When I run `FIN_CLI_PACKAGES_DIR=. fin package install fin-cli/restful`
    Then STDOUT should contain:
      """
      Updating package index repository url...
      """
    And STDOUT should contain:
      """
      Success: Package installed
      """
    And the composer.json file should contain:
      """
      "url": "https://fin-cli.org/package-index/"
      """
    And the composer.json file should not contain:
      """
      "url": "http://fin-cli.org/package-index/"
      """

  @require-php-5.6
  Scenario: Install a package with 'fin-cli/fin-cli' as a dependency
    Given a FIN install

    When I run `fin package install fin-cli-test/test-command:v0.2.0`
    Then STDOUT should contain:
      """
      Success: Package installed
      """
    And STDOUT should not contain:
      """
      requires fin-cli/fin-cli
      """

    When I run `fin test-command`
    Then STDOUT should contain:
      """
      Version C.
      """

  @require-php-5.6 @broken
  Scenario: Install a package with a dependency
    Given an empty directory

    When I run `fin package install yoast/fin-cli-faker`
    Then STDOUT should contain:
      """
      Success: Package installed
      """
    And the {PACKAGE_PATH}/vendor/yoast directory should contain:
      """
      fin-cli-faker
      """
    And the {PACKAGE_PATH}/vendor/fzaninotto directory should contain:
      """
      faker
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                |
      | yoast/fin-cli-faker  |
    And STDOUT should not contain:
      """
      fzaninotto/faker
      """

    When I run `fin package uninstall yoast/fin-cli-faker`
    Then STDOUT should contain:
      """
      Removing require statement for package 'yoast/fin-cli-faker' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """
    And the {PACKAGE_PATH}/vendor directory should not contain:
      """
      yoast
      """
    And the {PACKAGE_PATH}/vendor directory should not contain:
      """
      fzaninotto
      """

    When I run `fin package list`
    Then STDOUT should not contain:
      """
      trendwerk/faker
      """

  @github-api
  Scenario: Install a package from a Git URL
    Given an empty directory

    When I try `fin package install git@github.com:fin-cli-test/repository-name.git`
    Then the return code should be 0
    And STDERR should contain:
      """
      Warning: Package name mismatch...Updating from git name 'fin-cli-test/repository-name' to composer.json name 'fin-cli-test/package-name'.
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the {PACKAGE_PATH}composer.json file should contain:
      """
      "fin-cli-test/package-name": "dev-master"
      """

    When I try `fin package install git@github.com:fin-cli.git`
    Then STDERR should contain:
      """
      Error: Couldn't parse package name from expected path '<name>/<package>'.
      """

    When I run `fin package install git@github.com:fin-cli/google-sitemap-generator-cli.git`
    Then STDOUT should contain:
      """
      Installing package fin-cli/google-sitemap-generator-cli (dev-main)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering git@github.com:fin-cli/google-sitemap-generator-cli.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                                |
      | fin-cli/google-sitemap-generator-cli |

    When I run `fin google-sitemap`
    Then STDOUT should contain:
      """
      usage: fin google-sitemap rebuild
      """

    When I run `fin package uninstall fin-cli/google-sitemap-generator-cli`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli/google-sitemap-generator-cli' from
      """
    And STDOUT should contain:
      """
      Removing repository details from
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      "fin-cli/google-sitemap-generator-cli": "dev-master"
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      "url": "git@github.com:fin-cli/google-sitemap-generator-cli.git"
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli/google-sitemap-generator-cli
      """

  @github-api
  Scenario: Install a package from a Git URL with mixed-case git name but lowercase composer.json name
    Given an empty directory

    When I try `fin package install https://github.com/CapitalFINCLI/examplecommand.git`
    Then the return code should be 0
    And STDERR should contain:
      """
      Warning: Package name mismatch...Updating from git name 'CapitalFINCLI/examplecommand' to composer.json name 'capitalfincli/examplecommand'.
      """
    And STDOUT should contain:
      """
      Installing package capitalfincli/examplecommand (dev-master)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/CapitalFINCLI/examplecommand.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the {PACKAGE_PATH}composer.json file should contain:
      """
      "capitalfincli/examplecommand"
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      "CapitalFINCLI/examplecommand"
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                        |
      | capitalfincli/examplecommand |

    When I run `fin hello-world`
    Then STDOUT should contain:
      """
      Success: Hello world.
      """

  @github-api
  Scenario: Install a package from a Git URL with mixed-case git name and the same mixed-case composer.json name
    Given an empty directory

    When I run `fin package install https://github.com/gitlost/TestMixedCaseCommand.git`
    Then STDERR should be empty
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the contents of the {PACKAGE_PATH}composer.json file should match /\"gitlost\/(?:TestMixedCaseCommand|testmixedcasecommand)\"/

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                         |
      | gitlost/TestMixedCaseCommand |

    When I run `fin TestMixedCaseCommand`
    Then STDOUT should contain:
      """
      Success: Test Mixed Case Command Name
      """

  @github-api @shortened
  Scenario: Install a package from Git using a shortened package identifier
    Given an empty directory

    When I run `fin package install fin-cli-test/github-test-command`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/github-test-command (dev-master)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/fin-cli-test/github-test-command.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name,version`
    Then STDOUT should be a table containing rows:
      | name                            | version    |
      | fin-cli-test/github-test-command | dev-master |

    When I run `fin test-command`
    Then STDOUT should contain:
      """
      Success: Version E.
      """

    When I run `fin package uninstall fin-cli-test/github-test-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli-test/github-test-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli-test/github-test-command
      """

  @github-api @shortened
  Scenario: Install a package from Git using a shortened package identifier with a version requirement
    Given an empty directory

    When I try `fin package install fin-cli-test/github-test-command:^0`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/github-test-command (^0)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/fin-cli-test/github-test-command.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name,version`
    Then STDOUT should be a table containing rows:
      | name                            | version |
      | fin-cli-test/github-test-command | v0.2.0  |

    When I run `fin test-command`
    Then STDOUT should contain:
      """
      Success: Version C.
      """

    When I run `fin package uninstall fin-cli-test/github-test-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli-test/github-test-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli-test/github-test-command
      """

  @github-api @shortened
  Scenario: Install a package from Git using a shortened package identifier with a specific version
    Given an empty directory

    # Need to specify actual tag.
    When I try `fin package install fin-cli-test/github-test-command:0.1.0`
    Then STDERR should contain:
      """
      Warning: Couldn't download composer.json file from 'https://raw.githubusercontent.com/fin-cli-test/github-test-command/0.1.0/composer.json' (HTTP code 404).
      """

    When I run `fin package install fin-cli-test/github-test-command:v0.1.0`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/github-test-command (v0.1.0)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/fin-cli-test/github-test-command.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name,version`
    Then STDOUT should be a table containing rows:
      | name                            | version |
      | fin-cli-test/github-test-command | v0.1.0  |

    When I run `fin test-command`
    Then STDOUT should contain:
      """
      Success: Version A.
      """

    When I run `fin package uninstall fin-cli-test/github-test-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli-test/github-test-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli-test/github-test-command
      """

  @github-api @shortened
  Scenario: Install a package from Git using a shortened package identifier and a specific commit hash
    Given an empty directory

    When I run `fin package install fin-cli-test/github-test-command:dev-master#bcfac95e2193e9f5f8fbd3004fab9d902a5e4de3`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/github-test-command (dev-master#bcfac95e2193e9f5f8fbd3004fab9d902a5e4de3)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/fin-cli-test/github-test-command.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name,version`
    Then STDOUT should be a table containing rows:
      | name                            | version    |
      | fin-cli-test/github-test-command | dev-master |

    When I run `fin test-command`
    Then STDOUT should contain:
      """
      Success: Version B.
      """

    When I run `fin package uninstall fin-cli-test/github-test-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli-test/github-test-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli-test/github-test-command
      """

  @github-api @shortened
  Scenario: Install a package from Git using a shortened package identifier and a branch
    Given an empty directory

    When I run `fin package install fin-cli-test/github-test-command:dev-custom-branch`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/github-test-command (dev-custom-branch)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/fin-cli-test/github-test-command.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name,version`
    Then STDOUT should be a table containing rows:
      | name                            | version           |
      | fin-cli-test/github-test-command | dev-custom-branch |

    When I run `fin test-command`
    Then STDOUT should contain:
      """
      Success: Version D.
      """

    When I run `fin package uninstall fin-cli-test/github-test-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli-test/github-test-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli-test/github-test-command
      """

  @github-api
  Scenario: Install a package from the fin-cli package index with a mixed-case name
    Given an empty directory

    # Install and uninstall with case-sensitive name
    When I try `fin package install GeekPress/fin-rocket-cli`
    Then STDERR should contain:
      """
      Warning: Package name mismatch...Updating from git name 'GeekPress/fin-rocket-cli' to composer.json name 'fin-media/fin-rocket-cli'.
      """
    And STDOUT should match /Installing package fin-media\/fin-rocket-cli \(dev-/
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the contents of the {PACKAGE_PATH}composer.json file should match /"fin-media\/fin-rocket-cli"/

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                   |
      | fin-media/fin-rocket-cli |

    When I run `fin help rocket`
    Then STDOUT should contain:
      """
      fin rocket
      """

    When I try `fin package uninstall GeekPress/fin-rocket-cli`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-media/fin-rocket-cli' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """
    And STDERR should contain:
      """
      Warning: Package name mismatch...Updating from git name 'GeekPress/fin-rocket-cli' to composer.json name 'fin-media/fin-rocket-cli'.
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      rocket
      """

    # Install with lowercase name (for BC - no warning) and uninstall with lowercase name (for BC and convenience)
    When I run `fin package install geekpress/fin-rocket-cli`
    Then STDERR should be empty
    And STDOUT should match /Installing package (?:GeekPress|geekpress)\/fin-rocket-cli \(dev-/
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the contents of the {PACKAGE_PATH}composer.json file should match /("?:GeekPress|geekpress)\/fin-rocket-cli"/

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                    |
      | geekpress/fin-rocket-cli |

    When I run `fin help rocket`
    Then STDOUT should contain:
      """
      fin rocket
      """

    When I run `fin package uninstall geekpress/fin-rocket-cli`
    Then STDOUT should contain:
      """
      Removing require statement for package 'geekpress/fin-rocket-cli' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      rocket
      """

  @github-api
  Scenario: Install a package with a composer.json that differs between versions
    Given an empty directory

    When I run `fin package install fin-cli-test/version-composer-json-different:v1.0.0`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/version-composer-json-different (v1.0.0)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the {PACKAGE_PATH}/vendor/fin-cli-test/version-composer-json-different/composer.json file should exist
    And the {PACKAGE_PATH}/vendor/fin-cli-test/version-composer-json-different/composer.json file should contain:
      """
      1.0.0
      """
    And the {PACKAGE_PATH}/vendor/fin-cli-test/version-composer-json-different/composer.json file should not contain:
      """
      1.0.1
      """
    And the {PACKAGE_PATH}/vendor/fin-cli/profile-command directory should not exist

    When I run `fin package install fin-cli-test/version-composer-json-different:v1.0.1`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/version-composer-json-different (v1.0.1)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the {PACKAGE_PATH}/vendor/fin-cli-test/version-composer-json-different/composer.json file should exist
    And the {PACKAGE_PATH}/vendor/fin-cli-test/version-composer-json-different/composer.json file should contain:
      """
      1.0.1
      """
    And the {PACKAGE_PATH}/vendor/fin-cli-test/version-composer-json-different/composer.json file should not contain:
      """
      1.0.0
      """
    And the {PACKAGE_PATH}/vendor/fin-cli/profile-command directory should exist

  Scenario: Install a package from a local zip
    Given an empty directory
    And I run `wget -q -O google-sitemap-generator-cli.zip https://github.com/fin-cli/google-sitemap-generator-cli/archive/master.zip`

    When I run `fin package install google-sitemap-generator-cli.zip`
    Then STDOUT should contain:
      """
      Installing package fin-cli/google-sitemap-generator-cli
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering {PACKAGE_PATH}local/fin-cli-google-sitemap-generator-cli as a path repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                                |
      | fin-cli/google-sitemap-generator-cli |

    When I run `fin google-sitemap`
    Then STDOUT should contain:
      """
      usage: fin google-sitemap rebuild
      """

    When I run `fin package uninstall fin-cli/google-sitemap-generator-cli`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli/google-sitemap-generator-cli' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli/google-sitemap-generator-cli
      """

  @github-api
  Scenario: Install a package from Git using a shortened mixed-case package identifier but lowercase composer.json name
    Given an empty directory

    When I try `fin package install CapitalFINCLI/examplecommand`
    Then the return code should be 0
    And STDERR should contain:
      """
      Warning: Package name mismatch...Updating from git name 'CapitalFINCLI/examplecommand' to composer.json name 'capitalfincli/examplecommand'.
      """
    And STDOUT should contain:
      """
      Installing package capitalfincli/examplecommand (dev-master)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering https://github.com/CapitalFINCLI/examplecommand.git as a VCS repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """
    And the {PACKAGE_PATH}composer.json file should contain:
      """
      "capitalfincli/examplecommand"
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      "CapitalFINCLI/examplecommand"
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                        |
      | capitalfincli/examplecommand |

    When I run `fin hello-world`
    Then STDOUT should contain:
      """
      Success: Hello world.
      """

    When I run `fin package uninstall capitalfincli/examplecommand`
    Then STDOUT should contain:
      """
      Removing require statement for package 'capitalfincli/examplecommand' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """
    And the {PACKAGE_PATH}composer.json file should not contain:
      """
      capital
      """

  @github-api
  Scenario: Install a package from a remote ZIP
    Given an empty directory

    When I try `fin package install https://github.com/fin-cli/google-sitemap-generator.zip`
    Then STDERR should be:
      """
      Error: Couldn't download package from 'https://github.com/fin-cli/google-sitemap-generator.zip' (HTTP code 404).
      """

    When I run `fin package install https://github.com/fin-cli/google-sitemap-generator-cli/archive/master.zip`
    Then STDOUT should contain:
      """
      Installing package fin-cli/google-sitemap-generator-cli (dev-
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering {PACKAGE_PATH}local/fin-cli-google-sitemap-generator-cli as a path repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                                |
      | fin-cli/google-sitemap-generator-cli |

    When I run `fin google-sitemap`
    Then STDOUT should contain:
      """
      usage: fin google-sitemap rebuild
      """

    When I run `fin package uninstall fin-cli/google-sitemap-generator-cli`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli/google-sitemap-generator-cli' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli/google-sitemap-generator-cli
      """

  @gitlab-api
  Scenario: Install a package from a GitLab URL
    Given an empty directory

    When I try `fin package install https://gitlab.com/gitlab-examples/php.git`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Invalid package: no name in composer.json file 'https://gitlab.com/gitlab-examples/php/-/raw/master/composer.json'.
      """

  Scenario: Install a package at an existing path
    Given an empty directory
    And a path-command/command.php file:
      """
      <?php
      FIN_CLI::add_command( 'community-command', function(){
        FIN_CLI::success( "success!" );
      }, array( 'when' => 'before_fin_load' ) );
      """
    And a path-command/composer.json file:
      """
      {
        "name": "fin-cli/community-command",
        "description": "A demo community command.",
        "license": "MIT",
        "minimum-stability": "dev",
        "require": {
        },
        "autoload": {
          "files": [ "command.php" ]
        },
        "require-dev": {
          "behat/behat": "~2.5"
        }
      }
      """

    When I run `pwd`
    Then save STDOUT as {CURRENT_PATH}

    When I run `fin package install path-command`
    Then STDOUT should contain:
      """
      Installing package fin-cli/community-command
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering {CURRENT_PATH}/path-command as a path repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                            |
      | fin-cli/community-command        |

    When I run `fin community-command`
    Then STDOUT should be:
      """
      Success: success!
      """

    When I run `fin package uninstall fin-cli/community-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli/community-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """
    And the path-command directory should exist

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli/community-command
      """

  Scenario: Install a package at an existing path with a version constraint
    Given an empty directory
    And a path-command/command.php file:
      """
      <?php
      FIN_CLI::add_command( 'community-command', function(){
        FIN_CLI::success( "success!" );
      }, array( 'when' => 'before_fin_load' ) );
      """
    And a path-command/composer.json file:
      """
      {
        "name": "fin-cli/community-command",
        "description": "A demo community command.",
        "license": "MIT",
        "minimum-stability": "dev",
        "version": "0.2.0-beta",
        "require": {
        },
        "autoload": {
          "files": [ "command.php" ]
        },
        "require-dev": {
          "behat/behat": "~2.5"
        }
      }
      """

    When I run `pwd`
    Then save STDOUT as {CURRENT_PATH}

    When I run `fin package install path-command`
    Then STDOUT should contain:
      """
      Installing package fin-cli/community-command (0.2.0-beta)
      """
    # This path is sometimes changed on Macs to prefix with /private
    And STDOUT should contain:
      """
      {PACKAGE_PATH}composer.json to require the package...
      """
    And STDOUT should contain:
      """
      Registering {CURRENT_PATH}/path-command as a path repository...
      Using Composer to install the package...
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `fin package list --fields=name`
    Then STDOUT should be a table containing rows:
      | name                            |
      | fin-cli/community-command        |

    When I run `fin community-command`
    Then STDOUT should be:
      """
      Success: success!
      """

    When I run `fin package uninstall fin-cli/community-command`
    Then STDOUT should contain:
      """
      Removing require statement for package 'fin-cli/community-command' from
      """
    And STDOUT should contain:
      """
      Success: Uninstalled package.
      """
    And the path-command directory should exist

    When I run `fin package list --fields=name`
    Then STDOUT should not contain:
      """
      fin-cli/community-command
      """

  Scenario: Try to install bad packages
    Given an empty directory
    And a package-dir/composer.json file:
      """
      {
      }
      """
    And a package-dir-bad-composer/composer.json file:
      """
      {
      """
    And a package-dir/zero.zip file:
      """
      """

    When I try `fin package install https://github.com/non-existent-git-user-asdfasdf/non-existent-git-repo-asdfasdf.git`
    Then the return code should be 1
    And STDERR should contain:
      """
      Warning: Couldn't download composer.json file from 'https://raw.githubusercontent.com/non-existent-git-user-asdfasdf/non-existent-git-repo-asdfasdf/master/composer.json' (HTTP code 404). Presuming package name is 'non-existent-git-user-asdfasdf/non-existent-git-repo-asdfasdf'.
      """

    When I try `fin package install https://github.com/fin-cli-test/private-repository.git`
    Then STDERR should contain:
      """
      Warning: Couldn't download composer.json file from 'https://raw.githubusercontent.com/fin-cli-test/private-repository/master/composer.json' (HTTP code 404). Presuming package name is 'fin-cli-test/private-repository'.
      """

    When I try `fin package install non-existent-git-user-asdfasdf/non-existent-git-repo-asdfasdf`
    Then the return code should be 1
    And STDERR should be:
      """
      Error: Invalid package: shortened identifier 'non-existent-git-user-asdfasdf/non-existent-git-repo-asdfasdf' not found.
      """
    And STDOUT should be empty

    When I try `fin package install https://example.com/non-existent-zip-asdfasdf.zip`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Couldn't download package from 'https://example.com/non-existent-zip-asdfasdf.zip'
      """
    And STDOUT should be empty

    When I try `fin package install package-dir-bad-composer`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Invalid package: failed to parse composer.json file
      """
    # Split string up to get around Mac OS X inconsistencies with RUN_DIR
    And STDERR should contain:
      """
      /package-dir-bad-composer/composer.json' as json.
      """
    And STDOUT should be empty

    When I try `fin package install package-dir`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Invalid package: no name in composer.json file
      """
    # Split string up to get around Mac OS X inconsistencies with RUN_DIR
    And STDERR should contain:
      """
      /package-dir/composer.json'.
      """
    And STDOUT should be empty

    When I try `fin package install package-dir/zero.zip`
    Then the return code should be 1
    And STDERR should be:
      """
      Error: ZipArchive failed to unzip 'package-dir/zero.zip': Not a zip archive (19).
      """
    And STDOUT should be empty
