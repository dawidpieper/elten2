<?php
/**
 * Plugin Name:     Elten Plugin
 * Description:     Provides integration with Elten.
 * Author:          Dawid Pieper
 * Copyright:       Dawid Pieper
 * Text Domain:     elten
 * Domain Path:     /languages
 * Version:         1.0.0
 *
 * @package         elten
 * @author          Dawid Pieper
 * @copyright       Dawid Pieper
 */

require_once 'class-elten-multisite-controller.php';
require_once 'elten-registration-hooks.php';
require_once 'elten-auth.php';
require_once 'elten-cs.php';
require_once 'elten-footer.php';
require_once 'elten-shortcodes.php';
require_once 'class-elten-rest-filter.php';
require_once 'elten-cfields.php';

add_action(
	'rest_api_init',
	function() {
		new Elten_Multisite_Controller();
	}
);