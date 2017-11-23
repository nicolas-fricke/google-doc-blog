require 'google_drive'

class GoogleDriveConnector
  attr_reader :session

  def initialize
    current_dir = File.dirname(__FILE__)
    config_path = File.join([current_dir, '..', 'config', 'google.json'])
    @session = GoogleDrive::Session.from_config(config_path)
  end
end
