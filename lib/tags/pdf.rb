require 'thor'
require 'open3'
require 'tempfile'

module Tags
  module PDF
    def self.get(file_name, pdftk_path = 'pdftk')
      stdout_str, stderr_str, status = Open3.capture3(pdftk_path, file_name, 'dump_data_utf8')
      unless status.success?
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
    
    def self.set(file_name, tag, pdftk_path = 'pdftk')
      tags = get(file_name, pdftk_path)
      tags << tag
      
      info = Tempfile.new(['sfpdftag', '.txt'])
      begin
        info.write("InfoKey: X-StickyFlag-Flags\n")
        info.write("InfoValue: #{tags.join(', ')}\n")
        info.close
        
        out = Tempfile.new(['sfpdfout', '.pdf'])
        out.close
        begin
          unless system pdftk_path, file_name, 'update_info', info.path, 'output', out.path
            raise Thor::Error.new("ERROR: Failed to set tags for #{file_name}; pdftk call failed")
            return
          end
          
          FileUtils.mv out.path, file_name
        ensure
          out.unlink
        end
      ensure
        info.unlink
      end
    end
  end
end
