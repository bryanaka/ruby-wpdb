$:.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'bundler'
Bundler.setup

require 'yaml'
require 'letters'

require 'sequel'
require 'ruby-wpdb'
require 'logger'

def load_yaml_config
	WPDB.from_config( File.expand_path('../support/wp-config.yml', __FILE__) )
end

def load_wpconfig
	WPDB.from_config(File.expand_path('../support/wp-config.php', __FILE__) )
end

def log_queries
	WPDB.db.logger = Logger.new('data/query.log')
end

require 'minitest/autorun'
require 'mocha/setup'
