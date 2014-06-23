#!/usr/bin/env ruby
require './lib/base.rb'
require 'highline/import'
require 'mysql'

con = Mysql.new(config['import_database']['host'], config['import_database']['user'], config['import_database']['password'], config['import_database']['database'])

tables = fetch_tables
tables.each do |item|
  table = File.basename(item, '.ibd')
  result_dir = File.join(config['result_dir'], table)
  next if config['exclude'] && config['exclude'].select{|pattern| table.include?(pattern)}.size > 0
  if File.exists?(result_dir)
    pages = Dir.glob("#{result_dir}/FIL_PAGE_INDEX/**").sort_by { |word| word.split('-').last.to_i }
    if tables.size  == 1
      pages.each_index {|i| puts "[#{i}]: #{pages[i]}"}
      index =  ask('Select directory for import') { |q| q.default = '0' }
      pages = Array(pages[index.to_i])
    end
    page = pages.first
    data_file = File.absolute_path("#{page}/000-concatenated.tsv")
    if File.size(data_file) == 0
      puts "Skip '#{table}' because data file is empty!"
      next
    end
    begin
      cmd = File.readlines("#{page}/000-concatenated.load").last
      puts import_command = cmd.gsub(/INFILE(.*)REPLACE/im, "INFILE '#{data_file}' REPLACE")
      con.query(import_command)
    rescue Exception => e
      puts e.message
    end
  end
end
con.close
