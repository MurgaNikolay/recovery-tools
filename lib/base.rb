require 'fileutils'
require 'yaml'

def config
  @config ||= YAML.load_file('config.yml')
end

def fetch_tables
  ARGV[0] ? Array(ARGV[0]) : Dir.glob("#{config['data_dir']}/*.ibd")
end

def command(command, comment=nil)
  puts comment if comment
  puts command
  system command
end

def rebuild(table)
  command("cd #{config['innodb_tools']} && ./create_defs.pl --host=#{config['schema_database']['host']} --user=#{config['schema_database']['user']} --password=#{config['schema_database']['password']} --db=#{config['schema_database']['database']} --table=#{table} > include/table_defs.h", 'Generate table definition from schema')
  command("cd #{config['innodb_tools']} && make clean && make > /dev/null 2> /dev/null", 'Make scripts for schema')
end
