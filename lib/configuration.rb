require 'thor'
require 'yaml'
require_relative 'paths'

class Configuration
  DEFAULT_CONFIG = {
    :wut => 'nope'
  }
  
  @@configuration = DEFAULT_CONFIG.clone
  
  def self.get(key)
    unless @@configuration.keys.include?(key.to_sym)
      raise Thor::Error('stickyflag config: invalid configuration key') 
    end
    
    @@configuration[key.to_sym]
  end
  
  def self.set(key, value)
    unless @@configuration.keys.include?(key.to_sym)
      raise Thor::Error('stickyflag config: invalid configuration key')
    end
    
    @@configuration[key.to_sym] = value
  end
  
  def self.reset!
    @@configuration = DEFAULT_CONFIG.clone
    
    file_name = Paths.config
    if File.file? file_name
      FileUtils::rm_f file_name
    end
  end
  
  def self.dump
    puts "StickyFlag Configuration:"
    @@configuration.each do |key, val|
      puts "  `#{key}`: `#{val}`"
    end
  end
  
  def self.load!
    file_name = Paths.config
    if File.file? file_name
      @@configuration = YAML::load(File.open(file_name))
    end
  end
  
  def self.save!
    file_name = Paths.config
    File.open(file_name, 'w') do |f|
      YAML.dump(@@configuration, f)
    end
  end
end
