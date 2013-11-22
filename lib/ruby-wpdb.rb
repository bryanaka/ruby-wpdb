require 'bundler/setup'

require 'sequel'
require 'pry'
require 'pry-debugger'
# require 'ruby-wpdb/options'
# require 'ruby-wpdb/users'
# require 'ruby-wpdb/terms'
# require 'ruby-wpdb/posts'
# require 'ruby-wpdb/comments'
# require 'ruby-wpdb/links'
# require 'ruby-wpdb/gravityforms'

module WPDB
  class << self
    attr_accessor :db, :prefix, :user_prefix
    attr_reader :config

    # Given the path to a YAML file, will initialise WPDB using the
    # config files found in that file.
    def from_config(file = nil)
      @config = parse_config(file)
      uri = build_uri(@config)
      init(uri, @config['TABLE_PREFIX'])
    end

    # Initialises Sequel, sets up some necessary variables (like
    # WordPress's table prefix), and then includes our models.
    #
    # @param [String] A database connection uri, e.g.
    #   mysql2://user:pass@host:port/dbname
    # @param [String] The database table prefix used by the install of
    #   WordPress you'll be querying. Defaults to wp_
    # @param [String] The prefix of the users table; if not specified,
    #   the general database table prefix will be used.
    def init(uri, prefix = nil, user_prefix = nil)
      WPDB.db          = Sequel.connect(uri)
      WPDB.prefix      = prefix || 'wp_'
      WPDB.user_prefix = user_prefix || WPDB.prefix

      require_relative 'ruby-wpdb/options'
      require_relative 'ruby-wpdb/users'
      require_relative 'ruby-wpdb/terms'
      require_relative 'ruby-wpdb/posts'
      require_relative 'ruby-wpdb/comments'
      require_relative 'ruby-wpdb/links'
      require_relative 'ruby-wpdb/gravityforms'
    end

  private
    def parse_config(file)
      file ||= File.dirname(__FILE__) + '/../config.yml'
      input = File.open(file)
      File.extname(file) == ".php" ? from_wpconfig(input) : YAML::load(input)
    end

    def build_uri(opts)
      uri  = 'mysql2://'
      uri += "#{opts['DB_USER']}:#{opts['DB_PASSWORD']}"
      uri += "@#{opts['DB_HOST']}"
      uri += ":#{opts['PORT_NUMBER']}" if opts['PORT_NUMBER']
      uri += "/#{opts['DB_NAME']}"
    end

    def from_wpconfig(file)
      lines = [], table_prefix = nil
      file.each_line do |line|
        lines.push(line.strip) if line.include? "define("
        table_prefix = extract_value(line) if line.include? "$table_prefix"
      end
      wpconfig_to_hash(lines).merge( {"TABLE_PREFIX" => table_prefix} )
    end

    def extract_value(string)
      string[/\'[^']*\'/].to_s.gsub(/\'/, "")
    end

    def format_value(val)
      val.strip!.to_s
      return true     if val.downcase.include? "true"
      return false    if val.downcase.include? "false"
      return val.to_i if val.to_i.to_s == val.chop.chop
      extract_value(val)
    end
    
    def wpconfig_to_hash(lines)
      config = {}
      lines.reject! {|x| x.nil? || x.empty? }
      lines.map do |setting|
        setting = setting.split(",", 2).map { |el| format_value(el) }
        config[setting[0]] = setting[1]
      end
      config
    end
  end
end
