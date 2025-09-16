<?php

if ( ! class_exists( 'FIN_CLI' ) ) {
	return;
}

$fincli_package_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fincli_package_autoloader ) && ! class_exists( 'Package_Command' ) ) {
	require_once $fincli_package_autoloader;
}
FIN_CLI::add_command( 'package', 'Package_Command' );
