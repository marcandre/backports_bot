# -*- encoding : utf-8 -*-
require 'stickyflag/patches/tmpnam.rb'

class StickyFlag
  module Tags
    module MMD    
      module_function
    
      # We duplicate the source-code module here because we want to have
      # cute support for the indentation of tag contents in MMD, and because
      # MMD metadata blocks have slightly weird syntax rules.
    
      def metadata_key_regex
        /([A-Za-z0-9][A-Za-z0-9\-_ ]*):\s*(.*)/
      end
      def tag_line_regex
        /[Tt]\s*[Aa]\s*[Gg]\s*[Ss]\s*:.*/
      end
    
      def tag_line_for(tags, last_line = nil)
        padding = ''
      
        if last_line
          match = last_line.match(/([A-Za-z0-9][A-Za-z0-9\-_ ]*:\s*|\s*).*/)
          if match
            num = match[1].length - 'Tags: '.length
            if num > 0
              padding = ' ' * num
            end
          end
        end
      
        "Tags: #{padding}#{tags.join(', ')}  "
      end
    
      def write_tags(file_name, tags)
        set_tags = false
        eating_tags = false
        last_line = ''
        counter = 0

        outpath = File.tmpnam
        File.open(outpath, 'w:UTF-8') do |outfile|
          File.open(file_name, 'r:UTF-8').each_line do |line|
            if counter == 0
              if line !~ metadata_key_regex
                # If we're on the first line and there's no metadata at all,
                # then we have to add a metadata block
                outfile.puts tag_line_for(tags) if tags
                outfile.puts ''
                set_tags = true
              end
            else
              # Not on the first line
              if set_tags == true
                # If we've already set tags, this is easy
                outfile.puts line
              else
                # We're somewhere in the metadta, and we've yet to set any
                # tags.
                if line =~ tag_line_regex
                  # We want to eat the tag block, which could theoretically
                  # be extended onto multiple lines
                  eating_tags = true
                elsif eating_tags
                  # We're currently eating tags; if this line is blank or a
                  # key/value pair, we're done eating tags, time to print
                  if line =~ metadata_key_regex || line.strip.empty?
                    eating_tags = false
                    outfile.puts tag_line_for(tags, last_line) if tags
                    set_tags = true
                  end
                else
                  # Not eating the tags key, just keep going, checking to see
                  # if the metadata block is over
                  if line.strip.empty?
                    outfile.puts tag_line_for(tags, last_line) if tags
                    set_tags = true
                  end

                  outfile.puts line
                end
              end
            end
          
            counter += 1
            last_line = line
          end
        end
      
        FileUtils.mv(outpath, file_name)
      end
    
      def get(file_name)
        counter = 0
        key = ''
        value = ''
      
        File.open(file_name, 'r:UTF-8').each_line do |line|
          if counter == 0
            # Check to see if there's any metadata at all
            m = line.match(metadata_key_regex)
            return [] unless m
          
            # Start capturing values
            key = m[1]
            value = m[2]
          else
            # Check to see if the metadata is over, or if there's another
            # key/value pair starting on this line
            m = line.match(metadata_key_regex)
        
            if m || line.strip.empty?
              # We're done capturing this value, check if it's 'tags' (after
              # removing whitespace and lowercasing, as per the spec)
              key.gsub!(/\s/, '')
              key.downcase!
            
              if key == 'tags'
                return [] if value.nil? || value.empty?
                return value.split(',').map { |t| t.empty? ? nil : t.strip }.compact
              end
            end
        
            # Quit if there's no more metadata
            return if line.strip.empty?
        
            # Start grabbing a new key/value if there is one, or else just
            # add to the current value
            if m
              key = m[1]
              value = m[2]
            else
              # This doesn't strip the indentation off of the values, but
              # that's okay, since we always strip whitespace off
              # individual tags
              value << line
            end
          end
        
          counter += 1
        end
      
        []
      end
    
      def set(file_name, tag)
        tags = get(file_name)
        return if tags.include? tag
      
        tags << tag
        write_tags(file_name, tags)
      end
    
      def unset(file_name, tag)
        tags = get(file_name)
        return unless tags.include? tag
      
        tags.delete(tag)
        write_tags(file_name, tags)
      end
    
      def clear(file_name)
        write_tags(file_name, nil)
      end
    end
  end
end
