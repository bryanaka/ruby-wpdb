require_relative 'test_helper'

describe WPDB do
	before do
		config_file = <<-EOF
<?php
define('DB_NAME', 'ruby-wp');
define('DB_USER', 'ddh');
define('DB_PASSWORD', 'password');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// random alphanumberic chars
define('AUTH_KEY',         '3vm93nbdo0eL@Fz9c72bas83ba0');
define('SECURE_AUTH_KEY',  'ErBc+na3o,n3-dklsduR#DC_6J8');
define('LOGGED_IN_KEY',    ',m-y/[ash38dm<L`=k|]BXm|]T|');

$table_prefix  = 'wp_';

// test integers
define('PORT_NUMBER', 8097);

//test booleans
define('CANIHAZ',           false);
define('WP_SHARKNADO_MODE', true);

define('WPLANG', '');

EOF
	File.expect(:open, StringIO.new(config_file) )
	@config = WPDB.from_wpconfig(config_file)
	end

	it '#from_wpconfig parses correctly' do
		assert_equal @config['DB_NAME'], 'ruby-wp'
	end

end