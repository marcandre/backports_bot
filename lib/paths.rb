require 'rbconfig'
require 'fileutils'

module Paths
  def config_path
    case RbConfig::CONFIG['target_os']
    when /darwin/i
      root_dir = File.expand_path("~/Library/Application Support/StickyFlag")
    when /linux/i
      require 'xdg'
      root_dir = File.join(XDG['CONFIG_HOME'], 'stickyflag')
    when /mswin|mingw/i
      root_dir = File.join(ENV['APPDATA'], 'StickyFlag')
    else
      root_dir = File.expand_path('~/.stickyflag')
    end
      
    FileUtils.mkdir_p root_dir
    File.join(root_dir, 'config.yml')
  end
  
  def data_path
    case RbConfig::CONFIG['target_os']
    when /darwin/i
      root_dir = File.expand_path("~/Library/Application Support/StickyFlag")
    when /linux/i
      require 'xdg'
      root_dir = File.join(XDG['DATA_HOME'], 'stickyflag')
    when /mswin|mingw/i
      root_dir = File.join(ENV['APPDATA'], 'StickyFlag')
    else
      root_dir = File.expand_path('~/.stickyflag')
    end
    
    FileUtils.mkdir_p root_dir
    File.join(root_dir, 'db.sqlite')
  end
end
