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
  
    def get_tags_for(file_name)
      extension = File.extname file_name
      case extension
      when '.pdf' then return StickyFlag::Tags::PDF::get(file_name, get_config(:pdftk_path))
      when '.png' then return StickyFlag::Tags::PNG::get(file_name)
      when '.tex' then return StickyFlag::Tags::TeX::get(file_name)
      when '.c' then return StickyFlag::Tags::C::get(file_name)
      when '.cpp' then return StickyFlag::Tags::C::get(file_name)
      when '.cxx' then return StickyFlag::Tags::C::get(file_name)
      when '.c++' then return StickyFlag::Tags::C::get(file_name)
      when '.h' then return StickyFlag::Tags::C::get(file_name)
      when '.hpp' then return StickyFlag::Tags::C::get(file_name)
      when '.hxx' then return StickyFlag::Tags::C::get(file_name)
      when '.mmd' then return StickyFlag::Tags::MMD::get(file_name)
      else raise Thor::Error.new("ERROR: Don't know how to get tags for a file of extension '#{extension}'")
      end
    end
  
    def set_tag_for(file_name, tag)
      tags = get_tags_for file_name
      if tags.include? tag
        # Already set
        return
      end
    
      set_database_tag file_name, tag
    
      extension = File.extname file_name
      case extension
      when '.pdf' then return StickyFlag::Tags::PDF::set(file_name, tag, get_config(:pdftk_path))
      when '.png' then return StickyFlag::Tags::PNG::set(file_name, tag)
      when '.tex' then return StickyFlag::Tags::TeX::set(file_name, tag)
      when '.c' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.cpp' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.cxx' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.c++' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.h' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.hpp' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.hxx' then return StickyFlag::Tags::C::set(file_name, tag)
      when '.mmd' then return StickyFlag::Tags::MMD::set(file_name, tag)
      else raise Thor::Error.new("ERROR: Don't know how to set tags for a file of extension '#{extension}'")
      end
    end
  
    def unset_tag_for(file_name, tag)
      tags = get_tags_for file_name
      unless tags.include? tag
        raise Thor::Error.new("ERROR: Cannot unset tag #{tag} from file, not set")
      end
    
      unset_database_tag file_name, tag
    
      extension = File.extname file_name
      case extension
      when '.pdf' then return StickyFlag::Tags::PDF::unset(file_name, tag, get_config(:pdftk_path))
      when '.png' then return StickyFlag::Tags::PNG::unset(file_name, tag)
      when '.tex' then return StickyFlag::Tags::TeX::unset(file_name, tag)
      when '.c' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.cpp' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.cxx' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.c++' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.h' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.hpp' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.hxx' then return StickyFlag::Tags::C::unset(file_name, tag)
      when '.mmd' then return StickyFlag::Tags::MMD::unset(file_name, tag)
      else raise Thor::Error.new("ERROR: Don't know how to unset tags for a file of extension '#{extension}'")
      end
    end
  
    def clear_tags_for(file_name)
      clear_database_tags file_name
    
      extension = File.extname file_name
      case extension
      when '.pdf' then return StickyFlag::Tags::PDF::clear(file_name, get_config(:pdftk_path))
      when '.png' then return StickyFlag::Tags::PNG::clear(file_name)
      when '.tex' then return StickyFlag::Tags::TeX::clear(file_name)
      when '.c' then return StickyFlag::Tags::C::clear(file_name)
      when '.cpp' then return StickyFlag::Tags::C::clear(file_name)
      when '.cxx' then return StickyFlag::Tags::C::clear(file_name)
      when '.c++' then return StickyFlag::Tags::C::clear(file_name)
      when '.h' then return StickyFlag::Tags::C::clear(file_name)
      when '.hpp' then return StickyFlag::Tags::C::clear(file_name)
      when '.hxx' then return StickyFlag::Tags::C::clear(file_name)
      when '.mmd' then return StickyFlag::Tags::MMD::clear(file_name)
      else raise Thor::Error.new("ERROR: Don't know how to clear all tags for a file of extension '#{extension}'")
      end
    end
  end
end
