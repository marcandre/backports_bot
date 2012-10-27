# -*- encoding : utf-8 -*-

class StickyFlag
  module Tags
    module SourceCode
      module_function
    
      #
      # Specify:
      #   comment_line_regex: matches any line of comments at the start of the source code (when this doesn't match, we'll stop looking)
      #
      #   tag_line_regex: matches the specific line that contains the tags, the one group in this regex should be the comma-separated list of tags
      #
      #   tag_line_for(tags): convert the tag string (already a string!) into the output line we should print
      #
    
      def get(file_name)
        File.open(file_name, 'r:UTF-8').each_line do |line|
          return [] unless line =~ comment_line_regex

          m = line.match(tag_line_regex)
          if m
            tag_string = m[1]
            return [] if tag_string.nil? || tag_string.empty?
            return tag_string.split(',').map { |t| t.empty? ? nil : t.strip }.compact
          end
        end
      
        []
      end
    
      def set(file_name, tag)
        tags = get(file_name)
        return if tags.include? tag
      
        tags << tag      
        set_tags = false

        outpath = File.tmpnam
        File.open(outpath, 'w:UTF-8') do |outfile|
          File.open(file_name, 'r:UTF-8').each_line do |line|
            if line !~ comment_line_regex
              if set_tags == false
                # We haven't set the tags yet, but the current line does *not*
                # match the comment line regex.  Add the tags line as a new line
                # at the end of the comment block.
                outfile.puts tag_line_for(tags.join(', '))
                set_tags = true
              else
                outfile.puts line
              end
            else
              if line =~ tag_line_regex
                # Replace the old tag line with the new tag line
                outfile.puts tag_line_for(tags.join(', '))
              else
                outfile.puts line
              end
            end
          end
        end
      
        FileUtils.mv(outpath, file_name)
      end
    
      def unset(file_name, tag)
        tags = get(file_name)
        return unless tags.include? tag
      
        tags.delete(tag)
      
        outpath = File.tmpnam
        File.open(outpath, 'w:UTF-8') do |outfile|
          File.open(file_name, 'r:UTF-8').each_line do |line|
            if line =~ tag_line_regex
              outfile.puts tag_line_for(tags.join(', '))
            else
              outfile.puts line
            end
          end
        end
      
        FileUtils.mv(outpath, file_name)
      end
    
      def clear(file_name)
        outpath = File.tmpnam
        File.open(outpath, 'w:UTF-8') do |outfile|
          File.open(file_name, 'r:UTF-8').each_line do |line|
            next if line =~ tag_line_regex
            outfile.puts line
          end
        end
      
        FileUtils.mv(outpath, file_name)
      end
    end
  end
end
