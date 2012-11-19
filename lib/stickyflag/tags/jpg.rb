# -*- encoding : utf-8 -*-
require 'thor'
require 'mini_exiftool'
require 'fileutils'

module StickyFlag
  module Tags
    module JPG
      def self.set_exiftool_path path
        MiniExiftool.command = path
      end
      
      module_function
      
      def extensions
        [ '.jpg', '.jpeg' ]
      end
      def config_values
        [ :exiftool_path ]
      end
    
      def get(file_name, exiftool_path = 'exiftool')
        set_exiftool_path exiftool_path
        
        image = MiniExiftool.new file_name
        return [] if image.nil?
        
        keywords = image.keywords
        return [] if keywords.nil?
        
        # Preface our keywords with 'sf:' since this is a general-purpose
        # EXIF field
        keywords = [ keywords ] unless keywords.is_a? Array
        keywords.to_a.keep_if { |k| k.start_with? 'sf:' }.map { |k| k[3..-1] }
      end
    
      def set(file_name, tag, exiftool_path = 'exiftool')
        set_exiftool_path exiftool_path
        
        image = MiniExiftool.new file_name
        raise Thor::Error.new("ERROR: Cannot load file to set tags with MiniExiftool") if image.nil?

        keywords = image.keywords
        keywords ||= []
        
        return if keywords.include? "sf:#{tag}"
        keywords << "sf:#{tag}"
        
        image.keywords = keywords
        image.save
      end
    
      def unset(file_name, tag, exiftool_path = 'exiftool')
        set_exiftool_path exiftool_path
        
        image = MiniExiftool.new file_name
        raise Thor::Error.new("ERROR: Cannot load file to unset tags with MiniExiftool") if image.nil?

        keywords = image.keywords
        keywords ||= []
        
        return unless keywords.include? "sf:#{tag}"
        keywords.delete "sf:#{tag}"
        
        image.keywords = keywords
        image.save
      end
    
      def clear(file_name, exiftool_path = 'exiftool')
        set_exiftool_path exiftool_path
        
        image = MiniExiftool.new file_name
        raise Thor::Error.new("ERROR: Cannot load file to set tags with MiniExiftool") if image.nil?

        keywords = image.keywords
        keywords ||= []
        
        keywords.reject! { |k| k.start_with? "sf:" }
        
        image.keywords = keywords
        image.save
      end
    end
  end
end
