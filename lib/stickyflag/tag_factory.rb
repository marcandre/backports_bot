# -*- encoding : utf-8 -*-
require 'thor'
require 'pathname'
require 'backports'
require 'stickyflag/tags/pdf'
require 'stickyflag/tags/png'
require 'stickyflag/tags/tex'
require 'stickyflag/tags/c'
require 'stickyflag/tags/mmd'
require 'stickyflag/tags/mkv'

module StickyFlag
  module TagFactory
    TAG_MODULES = StickyFlag::Tags.constants.map { |sym| 
      StickyFlag::Tags.const_get(sym) 
    }.select { |const| 
      const.is_a?(Module) && const.respond_to?(:extensions)
    }
    
    TAG_EXTENSIONS = TAG_MODULES.map { |mod| mod.extensions }.reduce(:|)
    
    def available_tagging_extensions
      TAG_EXTENSIONS
    end
    
    def call_tag_method(file_name, method, *args)
      extension = File.extname file_name
      
      TAG_MODULES.each do |mod|
        if mod.send(:extensions).include? extension  
          if mod.respond_to?(:config_values)
            config_values = mod.send(:config_values)
            config_values.each { |val| args << get_config(val) }
          end
                  
          return mod.send(method, file_name, *args)
        end
      end
      
      raise Thor::Error.new("ERROR: Don't know how to tag a file of extension '#{extension}'")
    end
  
    def get_tags_for(file_name)
      call_tag_method(file_name, :get)
    end
  
    def set_tag_for(file_name, tag)
      tags = get_tags_for file_name
      return if tags.include? tag
    
      set_database_tag file_name, tag
      call_tag_method(file_name, :set, tag)
    end
  
    def unset_tag_for(file_name, tag)
      tags = get_tags_for file_name
      raise Thor::Error.new("ERROR: Cannot unset tag #{tag} from file, not set") unless tags.include? tag
    
      unset_database_tag file_name, tag
      call_tag_method(file_name, :unset, tag)
    end
  
    def clear_tags_for(file_name)
      clear_database_tags file_name
      call_tag_method(file_name, :clear)
    end
  end
end
