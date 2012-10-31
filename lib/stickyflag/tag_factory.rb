# -*- encoding : utf-8 -*-
require 'thor'
require 'pathname'
require 'backports'
require 'stickyflag/tags/pdf'
require 'stickyflag/tags/pdf'
require 'stickyflag/tags/png'
require 'stickyflag/tags/tex'
require 'stickyflag/tags/c'
require 'stickyflag/tags/mmd'

module StickyFlag
  module TagFactory
    def available_tagging_extensions
      ['.pdf', '.png', '.tex', '.c', '.cpp', '.cxx', '.c++',
       '.h', '.hpp', '.hxx', '.mmd']
    end
    
    def call_tag_method(file_name, method, *args)
      extension = File.extname file_name
      case extension
      when '.pdf'
        args << get_config(:pdftk_path)
        return StickyFlag::Tags::PDF.send(method, file_name, *args)
      when '.png' then return StickyFlag::Tags::PNG.send(method, file_name, *args)
      when '.tex' then return StickyFlag::Tags::TeX.send(method, file_name, *args)
      when '.c' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.cpp' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.cxx' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.c++' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.h' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.hpp' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.hxx' then return StickyFlag::Tags::C.send(method, file_name, *args)
      when '.mmd' then return StickyFlag::Tags::MMD.send(method, file_name, *args)
      else raise Thor::Error.new("ERROR: Don't know how to tag a file of extension '#{extension}'")
      end
    end
  
    def get_tags_for(file_name)
      call_tag_method(file_name, :get)
    end
  
    def set_tag_for(file_name, tag)
      tags = get_tags_for file_name
      if tags.include? tag
        # Already set
        return
      end
    
      set_database_tag file_name, tag
      call_tag_method(file_name, :set, tag)
    end
  
    def unset_tag_for(file_name, tag)
      tags = get_tags_for file_name
      unless tags.include? tag
        raise Thor::Error.new("ERROR: Cannot unset tag #{tag} from file, not set")
      end
    
      unset_database_tag file_name, tag
      call_tag_method(file_name, :unset, tag)
    end
  
    def clear_tags_for(file_name)
      clear_database_tags file_name
      call_tag_method(file_name, :clear)
    end
  end
end
