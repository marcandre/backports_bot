# -*- encoding : utf-8 -*-
require 'thor'
require 'open3'
require_relative '../tempfile_encoding'

module Tags
  module PDF
    module_function
    
    def get(file_name, pdftk_path = 'pdftk')
      stdout_str = ''
      stderr_str = ''
      
      begin
        Open3.popen3(pdftk_path, file_name.to_s, 'dump_data_utf8') do |i, o, e, t|
          out_reader = Thread.new { o.read }
          err_reader = Thread.new { e.read }
          i.close
          stdout_str = out_reader.value
          stderr_str = err_reader.value

          stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
          stderr_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
        end
      rescue Exception
        raise Thor::Error.new("ERROR: Failed to get tags for #{file_name}; pdftk call failed")
        return
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
    
    def set(file_name, tag, pdftk_path = 'pdftk')
      tags = get(file_name, pdftk_path)
      return if tags.include? tag
      
      tags << tag
      
      info = Tempfile.new_with_encoding ['sfpdftag', '.txt']
      begin
        info.write("InfoKey: X-StickyFlag-Flags\n")
        info.write("InfoValue: #{tags.join(', ')}\n")
        info.close
        
        outpath = File.tmpnam('.pdf')
        unless system pdftk_path, file_name.to_s, 'update_info', info.path, 'output', outpath
          raise Thor::Error.new("ERROR: Failed to set tag for #{file_name}; pdftk call failed")
          return
        end
          
        FileUtils.mv outpath, file_name
      ensure
        info.unlink
      end
    end

    def unset(file_name, tag, pdftk_path = 'pdftk')
      tags = get(file_name, pdftk_path)
      return unless tags.include? tag
      
      tags.delete(tag)
      
      info = Tempfile.new_with_encoding ['sfpdftag', '.txt']
      begin
        info.write("InfoKey: X-StickyFlag-Flags\n")
        info.write("InfoValue: #{tags.join(', ')}\n")
        info.close
        
        outpath = File.tmpnam('.pdf')
        unless system pdftk_path, file_name.to_s, 'update_info', info.path, 'output', outpath
          raise Thor::Error.new("ERROR: Failed to unset tag for #{file_name}; pdftk call failed")
          return
        end
          
        FileUtils.mv outpath, file_name
      ensure
        info.unlink
      end
    end

    def clear(file_name, pdftk_path = 'pdftk')
      info = Tempfile.new_with_encoding ['sfpdftag', '.txt']
      begin
        info.write("InfoKey: X-StickyFlag-Flags\n")
        info.write("InfoValue: \n")
        info.close
        
        outpath = File.tmpnam('.pdf')
        unless system pdftk_path, file_name.to_s, 'update_info', info.path, 'output', outpath
          raise Thor::Error.new("ERROR: Failed to clear tags for #{file_name}; pdftk call failed")
          return
        end
          
        FileUtils.mv outpath, file_name
      ensure
        info.unlink
      end
    end
  end
end
