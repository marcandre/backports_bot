# -*- encoding : utf-8 -*-
require 'thor'
require 'open4'
require 'stickyflag/patches/capture4'
require 'stickyflag/patches/tempfile_encoding'

module StickyFlag
  module Tags
    module PDF
      module_function
      
      def extensions
        [ '.pdf' ]
      end
      def config_values
        [ :pdftk_path ]
      end
    
      def get(file_name, pdftk_path = 'pdftk')
        stdout_str = ''
        stderr_str = ''
        status = nil
      
        begin
          stdout_str, stderr_str, status = Open4.capture4 "#{pdftk_path} \"#{file_name}\" dump_data_utf8"
        rescue Exception => e
          raise Thor::Error.new("ERROR: Failed to get tags for #{file_name}; pdftk call failed")
        end
        if !status.success? || stderr_str.start_with?("Error: ") || stderr_str.include?("Errno::ENOENT")
          raise Thor::Error.new("ERROR: Failed to get tags for #{file_name}; pdftk call failed")
        end
      
        # More than one of these shouldn't be possible, but try to recover if
        # it somehow happens.
        matches = stdout_str.scan(/InfoKey: X-StickyFlag-Flags\nInfoValue: (.*?)\n/)
        return [] if matches.empty?
      
        tags = []
      
        matches.each do |m|
          match_string = m[0]
          match_tags = match_string.split(',').map { |t| t.empty? ? nil : t.strip }.compact
          next if match_tags.empty?
        
          tags.concat(match_tags)
        end
      
        tags
      end
      
      def write_tags_to(file_name, tags, pdftk_path = 'pdftk')
        info = Tempfile.new_with_encoding ['sfpdftag', '.txt']
        begin
          info.write("InfoKey: X-StickyFlag-Flags\n")
          info.write("InfoValue: #{tags.join(', ')}\n")
          info.close
        
          outpath = File.tmpnam('.pdf')
          ret = system(pdftk_path, file_name, 'update_info', info.path, 'output', outpath)
          unless ret == true
            raise Thor::Error.new("ERROR: Failed to write tag for #{file_name}; pdftk call failed")
          end
          
          FileUtils.mv outpath, file_name
        ensure
          info.unlink
        end
      end
    
      def set(file_name, tag, pdftk_path = 'pdftk')
        tags = get(file_name, pdftk_path)
        return if tags.include? tag
      
        tags << tag
        
        write_tags_to(file_name, tags, pdftk_path)
      end

      def unset(file_name, tag, pdftk_path = 'pdftk')
        tags = get(file_name, pdftk_path)
        return unless tags.include? tag
      
        tags.delete(tag)
        
        write_tags_to(file_name, tags, pdftk_path)
      end

      def clear(file_name, pdftk_path = 'pdftk')
        write_tags_to(file_name, [], pdftk_path)
      end
    end
  end
end
