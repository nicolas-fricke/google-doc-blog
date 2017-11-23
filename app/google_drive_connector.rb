require 'google_drive'
require_relative 'config'

class GoogleDriveConnector
  attr_reader :session

  def initialize
    current_dir = File.dirname(__FILE__)
    config_path = File.join([current_dir, '..', 'config', 'google.json'])
    @session = GoogleDrive::Session.from_config(config_path)
  end

  def docs
    session
      .file_by_id(Config[:folder_id])
      .files
      .select { |file| file.resource_type == 'document' }
      .sort_by(&:modified_time)
      .reverse
  end
end
