require 'thor'
require 'pathname'
require 'backports'
require_relative 'tags/pdf'

module TagFactory
  def get_tags_for(file_name)
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::get(file_name, get_config(:pdftk_path))
    else raise Thor::Error.new("Don't know how to get tags for a file of extension '#{extension}'")
    end
  end
  
  def set_tag_for(file_name, tag)
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::set(file_name, tag, get_config(:pdftk_path))
    else raise Thor::Error.new("Don't know how to set tags for a file of extension '#{extension}'")
    end
  end
  
  def unset_tag_for(file_name, tag)
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::unset(file_name, tag, get_config(:pdftk_path))
    else raise Thor::Error.new("Don't know how to unset tags for a file of extension '#{extension}'")
    end
  end
  
  def clear_tags_for(file_name)
    extension = file_name.extname
    case extension
    when '.pdf' then return Tags::PDF::clear(file_name, get_config(:pdftk_path))
    else raise Thor::Error.new("Don't know how to clear all tags for a file of extension '#{extension}'")
    end
  end
end
