#!/usr/bin/env ruby
require './lib/base.rb'
Dir.mkdir(config['result_dir']) unless File.exists?(config['result_dir'])
fetch_tables.each do |item|
  table = File.basename(item, '.ibd')
  result_dir = File.join(config['result_dir'], table)
  next if config['exclude'] && config['exclude'].select{|pattern| table.include?(pattern)}.size > 0
  rebuild(table)
  command("cd #{config['innodb_tools']} && ./page_parser -5 -f #{item}", 'Parse pages')
  pages_dir = Dir.glob("#{config['innodb_tools']}/pages*").first
  if pages_dir
    puts 'Remove old results'
    FileUtils.rm_rf(result_dir)
    puts "Move pages to result #{pages_dir} -> #{result_dir}"
    FileUtils.mv(pages_dir, result_dir)
  end
  #puts "/constraints_parser -5 -f ./pages-1306247264/0-93/4-00000004.page"
  #puts "find ./pages-1306244252/0-121/ -type f -name '*.page' | sort -n | xargs cat > ./pages-1306244252/dbtable_allpages"
end
