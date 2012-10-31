# -*- encoding : utf-8 -*-
require 'thor'
require 'yaml'
require 'stickyflag/paths'

module StickyFlag
  module Configuration
    DEFAULT_CONFIG = {
      :have_pdftk => false,
      :pdftk_path => '',
      :have_mkvextract => false,
      :mkvextract_path => '',
      :have_mkvpropedit => false,
      :mkvpropedit_path => '',
      
      :root => ''
    }
  
    def get_config(key)
      @configuration ||= DEFAULT_CONFIG.clone
  
      unless @configuration.keys.include?(key.to_sym)
        raise Thor::Error.new("ERROR: Invalid configuration key (#{key.to_s})") 
      end
    
      @configuration[key.to_sym]
    end
  
    def set_config(key, value)
      @configuration ||= DEFAULT_CONFIG.clone
  
      unless @configuration.keys.include?(key.to_sym)
        raise Thor::Error.new("ERROR: invalid configuration key (#{key.to_s})")
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
        
        # Merge with the default to pick up new keys
        @configuration = DEFAULT_CONFIG.merge(@configuration)
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
end
