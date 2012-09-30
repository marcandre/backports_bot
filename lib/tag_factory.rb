require 'thor'
require 'pathname'
require 'backports'
require_relative 'tags/pdf'
require_relative 'tags/png'
require_relative 'tags/tex'
require_relative 'tags/c'

module TagFactory
  def get_tags_for(file_name)
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::get(file_name, get_config(:pdftk_path))
    when '.png' then return Tags::PNG::get(file_name)
    when '.tex' then return Tags::TeX::get(file_name)
    when '.c' then return Tags::C::get(file_name)
    when '.cpp' then return Tags::C::get(file_name)
    when '.cxx' then return Tags::C::get(file_name)
    when '.c++' then return Tags::C::get(file_name)
    when '.h' then return Tags::C::get(file_name)
    when '.hpp' then return Tags::C::get(file_name)
    when '.hxx' then return Tags::C::get(file_name)
    else raise Thor::Error.new("ERROR: Don't know how to get tags for a file of extension '#{extension}'")
    end
  end
  
  def set_tag_for(file_name, tag)
    tags = get_tags_for file_name
    if tags.include? tag
      # Already set
      return
    end
    
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::set(file_name, tag, get_config(:pdftk_path))
    when '.png' then return Tags::PNG::set(file_name, tag)
    when '.tex' then return Tags::TeX::set(file_name, tag)
    when '.c' then return Tags::C::set(file_name, tag)
    when '.cpp' then return Tags::C::set(file_name, tag)
    when '.cxx' then return Tags::C::set(file_name, tag)
    when '.c++' then return Tags::C::set(file_name, tag)
    when '.h' then return Tags::C::set(file_name, tag)
    when '.hpp' then return Tags::C::set(file_name, tag)
    when '.hxx' then return Tags::C::set(file_name, tag)
    else raise Thor::Error.new("ERROR: Don't know how to set tags for a file of extension '#{extension}'")
    end
  end
  
  def unset_tag_for(file_name, tag)
    tags = get_tags_for file_name
    unless tags.include? tag
      raise Thor::Error.new("ERROR: Cannot unset tag #{tag} from file, not set")
      return
    end
    
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::unset(file_name, tag, get_config(:pdftk_path))
    when '.png' then return Tags::PNG::unset(file_name, tag)
    when '.tex' then return Tags::TeX::unset(file_name, tag)
    when '.c' then return Tags::C::unset(file_name, tag)
    when '.cpp' then return Tags::C::unset(file_name, tag)
    when '.cxx' then return Tags::C::unset(file_name, tag)
    when '.c++' then return Tags::C::unset(file_name, tag)
    when '.h' then return Tags::C::unset(file_name, tag)
    when '.hpp' then return Tags::C::unset(file_name, tag)
    when '.hxx' then return Tags::C::unset(file_name, tag)
    else raise Thor::Error.new("ERROR: Don't know how to unset tags for a file of extension '#{extension}'")
    end
  end
  
  def clear_tags_for(file_name)
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::clear(file_name, get_config(:pdftk_path))
    when '.png' then return Tags::PNG::clear(file_name)
    when '.tex' then return Tags::TeX::clear(file_name)
    when '.c' then return Tags::C::clear(file_name)
    when '.cpp' then return Tags::C::clear(file_name)
    when '.cxx' then return Tags::C::clear(file_name)
    when '.c++' then return Tags::C::clear(file_name)
    when '.h' then return Tags::C::clear(file_name)
    when '.hpp' then return Tags::C::clear(file_name)
    when '.hxx' then return Tags::C::clear(file_name)
    else raise Thor::Error.new("ERROR: Don't know how to clear all tags for a file of extension '#{extension}'")
    end
  end
end
