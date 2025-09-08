<?php

if ( ! class_exists( 'FP_CLI' ) ) {
	return;
}

$fpcli_package_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fpcli_package_autoloader ) && ! class_exists( 'Package_Command' ) ) {
	require_once $fpcli_package_autoloader;
}
FP_CLI::add_command( 'package', 'Package_Command' );
