#!/usr/bin/env ruby
require './lib/base.rb'

fetch_tables.each do |item|
  table = File.basename(item, '.ibd')
  rebuild(table)
  result_dir = File.join(config['result_dir'], table)
  next if config['exclude'] && config['exclude'].select{|pattern| table.include?(pattern)}.size > 0
  if File.exists?(result_dir)
    Dir.glob("#{result_dir}/FIL_PAGE_INDEX/**").each do |page|
      %W(#{page}/000-concatenated #{page}/000-concatenated.tsv #{page}/000-concatenated.load).each do |f|
        FileUtils.rm(f) if File.exist?(f)
      end
      command("find #{page} -type f -name '*.page' | sort -n | xargs cat > #{page}/000-concatenated", 'Concat pages')
      command("#{config['innodb_tools']}/constraints_parser -5 -f #{page}/000-concatenated > #{page}/000-concatenated.tsv 2>#{page}/000-concatenated.load", 'Concat pages')
    end
  end
end
