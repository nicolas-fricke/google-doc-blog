#!/usr/bin/env ruby

require_relative '../app/config'
require_relative '../app/google_drive_connector'

# Don't buffer the output to avoid broken IO in docker container...
$stdout.sync = true

puts 'This script will guide you through the required setup steps setup the '\
     'blog. Please follow these steps:'

settings = {}
print 'Enter your blog title: '
settings[:blog_title] = STDIN.gets.chomp

# The first time this is run it sets up the credentials
connector = GoogleDriveConnector.new

folder = nil
while folder.nil?
  print 'What Google Folder ID should be used for the blog? To get the folder '\
        'ID, open the folder within the browser. The ID is the last part of '\
        'the path, `https://drive.google.com/drive/u/0/folders/<ID>`. Please '\
        'copy this ID in here: '
  settings[:folder_id] = STDIN.gets.chomp
  begin
    folder = connector.session.file_by_id(settings[:folder_id])
    puts "Successfully selected '#{folder.title}'. All documents in there "\
         'will now be visible on your blog.'
  rescue Google::Apis::ClientError
    puts "Couldn't find any folder with the ID #{settings[:folder_id]}. "\
         'Please try again.'
  end
end

File.open(Config.path, 'w+') { |f| f.write YAML.dump(settings) }
