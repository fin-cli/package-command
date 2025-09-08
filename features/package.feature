Feature: Manage FP-CLI packages

  Scenario: Package CRUD
    Given an empty directory

    When I run `fp package browse`
    Then STDOUT should contain:
      """
      runcommand/hook
      """

    When I run `fp package install runcommand/hook`
    Then STDERR should be empty

    When I run `fp help hook`
    Then STDERR should be empty
    And STDOUT should contain:
      """
      List callbacks registered to a given action or filter.
      """

    When I try `fp --skip-packages --debug help hook`
    Then STDERR should contain:
      """
      Debug (bootstrap): Skipped loading packages.
      """
    And STDERR should contain:
      """
      Warning: No FinPress install
      """

    When I run `fp package list`
    Then STDOUT should contain:
      """
      runcommand/hook
      """

    When I run `fp package uninstall runcommand/hook`
    Then STDERR should be empty

    When I run `fp package list`
    Then STDOUT should not contain:
      """
      runcommand/hook
      """

  Scenario: Run package commands early, before any bad code can break them
    Given an empty directory
    And a bad-command.php file:
      """
      <?php
      FP_CLI::error( "Doing it wrong." );
      """

    When I try `fp --require=bad-command.php option`
    Then STDERR should contain:
      """
      Error: Doing it wrong.
      """

    When I run `fp --require=bad-command.php package list`
    Then STDERR should be empty

  @require-php-7.2 @broken
  Scenario: Revert the FP-CLI packages composer.json when fail to install/uninstall a package due to memory limit
    Given an empty directory
    When I try `{INVOKE_FP_CLI_WITH_PHP_ARGS--dmemory_limit=10M -ddisable_functions=ini_set} package install runcommand/hook`
    Then the return code should not be 0
    And STDERR should contain:
      """
      Reverted composer.json.
      """

    When I run `fp package install runcommand/hook`
    Then STDOUT should contain:
      """
      Success: Package installed.
      """

    When I try `{INVOKE_FP_CLI_WITH_PHP_ARGS--dmemory_limit=10M -ddisable_functions=ini_set} package uninstall runcommand/hook`
    Then the return code should not be 0
    And STDERR should contain:
      """
      Reverted composer.json.
      """

    # Create a default composer.json first to compare.
    When I run `FP_CLI_PACKAGES_DIR={RUN_DIR}/mypackages fp package list`
    Then the {RUN_DIR}/mypackages/composer.json file should exist
    And save the {RUN_DIR}/mypackages/composer.json file as {MYPACKAGES_COMPOSER_JSON}

    When I try `FP_CLI_PACKAGES_DIR={RUN_DIR}/mypackages {INVOKE_FP_CLI_WITH_PHP_ARGS--dmemory_limit=10M -ddisable_functions=ini_set} package install runcommand/hook`
    Then the return code should not be 0
    And STDERR should contain:
      """
      Reverted composer.json.
      """
    And the mypackages/composer.json file should be:
      """
      {MYPACKAGES_COMPOSER_JSON}
      """

  @github-api
  Scenario: Try to run with a bad FP_CLI_PACKAGES_DIR/composer.json
    Given an empty directory
    And a packages-bad-json/composer.json file:
      """
      {
        "name": "fp-cli/fp-cli",
      }
      """

    When I try `FP_CLI_PACKAGES_DIR={RUN_DIR}/packages-bad-json fp package list`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Failed to get composer instance
      """
    And STDERR should contain:
      """
      Parse error
      """
    And STDOUT should be empty

    When I try `FP_CLI_PACKAGES_DIR={RUN_DIR}/packages-bad-json fp package install runcommand/hook`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Failed to parse
      """
    And STDERR should contain:
      """
      Parse error
      """
    And STDOUT should contain:
      """
      Installing
      """

    When I try `FP_CLI_PACKAGES_DIR={RUN_DIR}/packages-bad-json fp package update`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Failed to get composer instance
      """
    And STDERR should contain:
      """
      Parse error
      """
    And STDOUT should be empty

    Given a packages-no-such-package/composer.json file:
      """
      {
        "name": "fp-cli/fp-cli",
        "repositories": {
          "no-such-gituser/no-such-package": {
             "type": "vcs",
             "url": "https://github.com/no-such-gituser/no-such-package.git"
          }
        },
        "require": {
          "no-such-gituser/no-such-package": "dev-master"
        }
      }
      """
    And save the {RUN_DIR}/packages-no-such-package/composer.json file as {NO_SUCH_PACKAGE_COMPOSER_JSON}

    When I try `FP_CLI_PACKAGES_DIR={RUN_DIR}/packages-no-such-package fp package install runcommand/hook`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Package installation failed.
      """
    And STDERR should contain:
      """
      Repository not found
      """
    And STDERR should contain:
      """
      Reverted composer.json.
      """
    And STDOUT should contain:
      """
      Installing
      """
    And the packages-no-such-package/composer.json file should be:
      """
      {NO_SUCH_PACKAGE_COMPOSER_JSON}
      """

    When I try `FP_CLI_PACKAGES_DIR={RUN_DIR}/packages-no-such-package fp package update`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Failed to update packages.
      """
    And STDERR should contain:
      """
      Repository not found
      """
    And STDERR should not contain:
      """
      Reverted composer.json.
      """
    And STDOUT should not be empty
    And the packages-no-such-package/composer.json file should be:
      """
      {NO_SUCH_PACKAGE_COMPOSER_JSON}
      """
