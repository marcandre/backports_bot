# -*- encoding : utf-8 -*-
$:.unshift File.expand_path("../../../lib", __FILE__)

require 'rubygems'
require 'bundler/setup'

require 'backports'
require 'aruba/cucumber'
require 'stickyflag'
require 'fileutils'
require_relative './cukegem'

# JRuby is slow to start up
Before do
  @aruba_timeout_seconds = 10
end

# Back up and restore the user's configuration and database
$backup_db = File.tmpnam('.sqlite')
$backup_config = File.tmpnam('.yml')

class GetPaths
  include StickyFlag::Paths
end
$paths = GetPaths.new

FileUtils.mv $paths.config_path, $backup_config if File.exist? $paths.config_path
FileUtils.mv $paths.database_path, $backup_db if File.exist? $paths.database_path

CukeGem.setup(File.expand_path('../../../stickyflag.gemspec', __FILE__))

at_exit do
  CukeGem.teardown
  
  FileUtils.mv $backup_config, $paths.config_path if File.exist? $backup_config
  FileUtils.mv $backup_db, $paths.database_path if File.exist? $backup_db
end
