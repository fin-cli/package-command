Feature: Update FIN-CLI packages

  Background:
    When I run `fin package path`
    Then save STDOUT as {PACKAGE_PATH}

  Scenario: Updating FIN-CLI packages runs successfully
    Given an empty directory

    When I run `fin package install danielbachhuber/fin-cli-reset-post-date-command`
    Then STDOUT should contain:
      """
      Success: Package installed.
      """
    And STDERR should be empty

    When I run `fin package update`
    Then STDOUT should contain:
      """
      Using Composer to update packages...
      """
    And STDOUT should contain:
      """
      Packages updated.
      """
    And STDERR should be empty

  Scenario: Update a package with an update available
    Given an empty directory

    When I run `fin package install fin-cli-test/updateable-package:v1.0.0`
    Then STDOUT should contain:
      """
      Installing package fin-cli-test/updateable-package (v1.0.0)
      """
    And STDOUT should contain:
      """
      Success: Package installed.
      """

    When I run `cat {PACKAGE_PATH}/composer.json`
    Then STDOUT should contain:
      """
      "fin-cli-test/updateable-package": "v1.0.0"
      """

    When I run `fin help updateable-package v1`
    Then STDOUT should contain:
      """
      fin updateable-package v1
      """

    When I run `fin package update`
    Then STDOUT should match /Nothing to install(?: or update|, update or remove)/
    And STDOUT should contain:
      """
      Success: Packages updated.
      """

    When I run `fin package list --fields=name,update`
    Then STDOUT should be a table containing rows:
      | name                           | update    |
      | fin-cli-test/updateable-package | available |

    When I run `sed -i.bak s/v1.0.0/\>=1.0.0/g {PACKAGE_PATH}/composer.json`
    Then the return code should be 0

    When I run `cat {PACKAGE_PATH}/composer.json`
    Then STDOUT should contain:
      """
      "fin-cli-test/updateable-package": ">=1.0.0"
      """

    When I run `fin package list --fields=name,update`
    Then STDOUT should be a table containing rows:
      | name                           | update     |
      | fin-cli-test/updateable-package | available  |

    When I run `fin package update`
    Then STDOUT should contain:
      """
      Writing lock file
      """
    And STDOUT should contain:
      """
      Success: Packages updated.
      """
    And STDOUT should not match /Nothing to install(?: or update|, update or remove)/

    When I run `fin package list --fields=name,update`
    Then STDOUT should be a table containing rows:
      | name                           | update  |
      | fin-cli-test/updateable-package | none    |

    When I run `fin package update`
    Then STDOUT should match /Nothing to install(?: or update|, update or remove)/
    And STDOUT should contain:
      """
      Success: Packages updated.
      """
