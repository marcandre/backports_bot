require 'backports'
require 'aruba/cucumber'
require_relative '../../lib/paths'
require_relative '../../lib/patches/tmpnam'
require 'fileutils'

# Back up and restore the user's configuration and database
$backup_db = File.tmpnam('.sqlite')
$backup_config = File.tmpnam('.yml')

class GetPaths
  include Paths
end
$paths = GetPaths.new

FileUtils.mv $paths.config_path, $backup_config if File.exist? $paths.config_path
FileUtils.mv $paths.database_path, $backup_db if File.exist? $paths.database_path

at_exit do
  FileUtils.mv $backup_config, $paths.config_path if File.exist? $backup_config
  FileUtils.mv $backup_db, $paths.database_path if File.exist? $backup_db
end
