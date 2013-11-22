require_relative 'test_helper'

describe WPDB do

	describe '#from_config with wordpress config' do
		before do
			load_wpconfig
			Sequel.expects(:connect).returns(true)
		end

		it 'parses string-based options correctly' do
			assert_equal WPDB.config['DB_NAME'], 'ruby-wp'
			assert_equal WPDB.config['DB_USER'], 'dhh'
			assert_equal WPDB.config['SECURE_AUTH_KEY'], 'ErBc+na3o,n3-dklsduR#DC_6J8'
		end
	
		it 'parses empty string options correctly' do
			assert_equal WPDB.config['WPLANG'], ''
		end
	
		it 'parses boolean-based options correctly' do
			assert_equal WPDB.config['CANIHAZ'], false
			assert_equal WPDB.config['WP_SHARKNADO_MODE'], true
		end
	
		it 'parses interger-based options correctly' do
			assert_equal WPDB.config['PORT_NUMBER'], 8097
		end
	
		it 'parses the table prefix correctly' do
			assert_equal WPDB.config['TABLE_PREFIX'], 'wp_'
		end
	end

	# describe '#from_config with YAML file' do
	# 	before do
	# 		WPDB.from_config( File.expand_path('../support/wp-config.yml', __FILE__) )
	# 	end

	# 	it 'parses string-based options correctly' do
	# 		assert_equal WPDB.config['DB_NAME'], 'ruby-wp'
	# 		assert_equal WPDB.config['DB_USER'], 'dhh'
	# 		assert_equal WPDB.config['SECURE_AUTH_KEY'], 'ErBc+na3o,n3-dklsduR#DC_6J8'
	# 	end
	
	# 	it 'parses empty string options correctly' do
	# 		assert_equal WPDB.config['WPLANG'], ''
	# 	end
	
	# 	it 'parses boolean-based options correctly' do
	# 		assert_equal WPDB.config['CANIHAZ'], false
	# 		assert_equal WPDB.config['WP_SHARKNADO_MODE'], true
	# 	end
	
	# 	it 'parses interger-based options correctly' do
	# 		assert_equal WPDB.config['PORT_NUMBER'], 8097
	# 	end
	
	# 	it 'parses the table prefix correctly' do
	# 		assert_equal WPDB.config['TABLE_PREFIX'], 'wp_'
	# 	end
	# end

end