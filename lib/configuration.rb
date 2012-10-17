# -*- encoding : utf-8 -*-
require 'thor'
require 'yaml'
require_relative 'paths'

module Configuration
  DEFAULT_CONFIG = {
    :have_pdftk => false,
    :pdftk_path => '',
    :root => ''
  }
  
  def get_config(key)
    @configuration ||= DEFAULT_CONFIG.clone
  
    unless @configuration.keys.include?(key.to_sym)
      raise Thor::Error.new('ERROR: Invalid configuration key') 
    end
    
    @configuration[key.to_sym]
  end
  
  def set_config(key, value)
    @configuration ||= DEFAULT_CONFIG.clone
  
    unless @configuration.keys.include?(key.to_sym)
      raise Thor::Error.new('ERROR: invalid configuration key')
    end
    
    @configuration[key.to_sym] = value
  end
  
  def reset_config!
    @configuration = DEFAULT_CONFIG.clone
    save_config!
  end
  
  def dump_config
    @configuration ||= DEFAULT_CONFIG.clone
  
    return if options.quiet?
    
    say "StickyFlag Configuration:"
    @configuration.each do |key, val|
      say "  #{key}: '#{val}'"
    end
  end
  
  def load_config!
    file_name = config_path
    if File.file? file_name
      @configuration = YAML::load(File.open(file_name, 'r:UTF-8'))
    end
  end
  
  def save_config!
    @configuration ||= DEFAULT_CONFIG.clone
  
    file_name = config_path
    File.open(file_name, 'w:UTF-8') do |f|
      YAML.dump(@configuration, f)
    end
  end
end
