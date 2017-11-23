#!/usr/bin/env ruby

puts 'This script will guide you through the required setup steps setup the '\
     'blog. Please follow these steps:'

settings = {}
print 'Enter your blog title: '
settings[:blog_title] = STDIN.gets.chomp

current_dir = File.dirname(__FILE__)
File.open(File.join([current_dir, '..', 'config', 'config.yml']), 'w+') do |f|
  f.write YAML.dump(settings)
end
