# -*- encoding : utf-8 -*-
require 'thor'
begin
  require 'oily_png'
rescue LoadError
  require 'chunky_png'
end
require 'fileutils'

module StickyFlag
  module Tags
    module PNG
      module_function
    
      def get(file_name)
        image = ChunkyPNG::Image.from_file(file_name)
        tag_string = image.metadata['X-StickyFlag-Flags']
        return [] if tag_string.nil?
        tag_string.force_encoding('UTF-8') if RUBY_VERSION >= "1.9.0"
        tag_string.split(',').map { |t| t.empty? ? nil : t.strip }.compact
      end
    
      def set(file_name, tag)
        tags = get(file_name)
        return if tags.include? tag
      
        tags << tag
      
        image = ChunkyPNG::Image.from_file(file_name)
        image.metadata['X-StickyFlag-Flags'] = tags.join(', ')
      
        outpath = File.tmpnam('.png')
        image.save(outpath)
        FileUtils.mv(outpath, file_name)
      end
    
      def unset(file_name, tag)
        tags = get(file_name)
        return unless tags.include? tag
      
        tags.delete(tag)
      
        image = ChunkyPNG::Image.from_file(file_name)
        image.metadata['X-StickyFlag-Flags'] = tags.join(', ')
      
        outpath = File.tmpnam('.png')
        image.save(outpath)
        FileUtils.mv(outpath, file_name)
      end
    
      def clear(file_name)
        image = ChunkyPNG::Image.from_file(file_name)
        image.metadata.delete('X-StickyFlag-Flags')
      
        outpath = File.tmpnam('.png')
        image.save(outpath)
        FileUtils.mv(outpath, file_name)
      end
    end
  end
end
