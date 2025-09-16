<?php
/**
 * A Composer IO class so we can provide some level of interactivity from FIN-CLI.
 *
 * Due to PHP 5.6 compatibility, we have two different implementations of this class.
 * This is implemented via traits to make static analysis easier.
 *
 * See https://github.com/fin-cli/package-command/issues/172.
 */

namespace FIN_CLI\Package;

use Composer\IO\NullIO;
use FIN_CLI\Package\Compat\NullIOMethodsTrait;

class ComposerIO extends NullIO {
	use NullIOMethodsTrait;
}
