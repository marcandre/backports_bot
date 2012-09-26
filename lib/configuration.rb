require 'thor'
require 'yaml'
require_relative 'paths'

module Configuration
  DEFAULT_CONFIG = {
    :have_pdftk => false,
    :pdftk_path => ''
  }
  
  @@configuration = DEFAULT_CONFIG.clone
  
  def get_config(key)
    unless @@configuration.keys.include?(key.to_sym)
      raise Thor::Error.new('ERROR: Invalid configuration key') 
    end
    
    @@configuration[key.to_sym]
  end
  
  def set_config(key, value)
    unless @@configuration.keys.include?(key.to_sym)
      raise Thor::Error.new('ERROR: invalid configuration key')
    end
    
    @@configuration[key.to_sym] = value
  end
  
  def reset_config!
    @@configuration = DEFAULT_CONFIG.clone
    
    file_name = config_path
    if File.file? file_name
      FileUtils::rm_f file_name
    end
  end
  
  def dump_config
    puts "StickyFlag Configuration:"
    @@configuration.each do |key, val|
      puts "  #{key}: '#{val}'"
    end
  end
  
  def load_config!
    file_name = config_path
    if File.file? file_name
      @@configuration = YAML::load(File.open(file_name))
    end
  end
  
  def save_config!
    file_name = config_path
    File.open(file_name, 'w') do |f|
      YAML.dump(@@configuration, f)
    end
  end
end
