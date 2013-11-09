require 'bundler/setup'

require 'sequel'
require 'pry'
require 'pry-debugger'

module WPDB
  class << self
    attr_accessor :db, :prefix, :user_prefix

    # Given the path to a YAML file, will initialise WPDB using the
    # config files found in that file.
    def from_config(file = nil)
      file ||= File.dirname(__FILE__) + '/../config.yml'
      ext = File.extname(file)
      config = (ext == ".php" ? File.open(file) : YAML::load_file(file) )

      uri  = 'mysql2://'
      uri += "#{config['username']}:#{config['password']}"
      uri += "@#{config['hostname']}"
      uri += ":#{config['port']}" if config['port']
      uri += "/#{config['database']}"

      init(uri, config['prefix'])
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

    def from_wpconfig(file)
      lines = [], table_prefix = nil
      File.open(file).each_line do |line|
        line.strip!
        lines.push line if line.include? "define("
        table_prefix = extract_value(line) if line.include? "$table_prefix"
      end
      wpconfig_to_hash(lines).merge( {"TABLE_PREFIX" => table_prefix} )
    end

    def wpconfig_to_hash(lines)
      config = {}
      lines.map do |setting|
        setting = setting.split(",", 2)
        setting.map! do |el|
          format_value(el)
        end
        config[setting[0]] = setting[1]
      end
      config
    end

    def format_value(val)
      val.strip!
      val = true               if val.to_s.downcase.include? "true"
      val = false              if val.to_s.downcase.include? "false"
      val = val.to_i           if val.to_s.to_i.to_s == val
      val = extract_value(val) if val.kind_of?(String) && !val.to_s.empty?
      val
    end

    def extract_value(string)
      string[/\'[^']*\'/].to_s.gsub(/\'/, "")
    end

  end
end

