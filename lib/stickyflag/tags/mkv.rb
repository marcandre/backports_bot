# -*- encoding : utf-8 -*-
require 'thor'
require 'open3'
require 'nokogiri'
require 'stickyflag/patches/tempfile_encoding'

module StickyFlag
  module Tags
    module MKV
      module_function
      
      def extensions
        [ '.mkv' ]
      end
      def config_values
        [ :mkvextract_path, :mkvpropedit_path ]
      end
      
      def get_tag_xml(file_name, mkvextract_path = 'mkvextract', mkvpropedit_path = 'mkvpropedit')
        stdout_str = ''
        stderr_str = ''
      
        begin
          Open3.popen3("#{mkvextract_path} tags #{file_name} -q") do |i, o, e, t|
            out_reader = Thread.new { o.read }
            err_reader = Thread.new { e.read }
            i.close
            stdout_str = out_reader.value
            stderr_str = err_reader.value

            stdout_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
            stderr_str.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
          end
        rescue Exception
          raise Thor::Error.new("ERROR: Failed to get tags for #{file_name}; mkvextract call failed")
        end
        if stderr_str.start_with?("Error: ") || stderr_str.include?("Errno::ENOENT") || stdout_str.start_with?("Error: ")
          raise Thor::Error.new("ERROR: Failed to get tags for #{file_name}; mkvextract call failed")
        end
        
        if stdout_str == ''
          # This is what happens when a file has no tags whatsoever, we need
          # to build a skeleton document
          stdout_str = <<-XML
          <?xml version="1.0" encoding="UTF-8"?>

          <!DOCTYPE Tags SYSTEM "matroskatags.dtd">

          <Tags>
            <Tag>
              <Targets>
              </Targets>
            </Tag>
          </Tags>
          XML
        end
        
        # Strip off newlines and BOM, these wreak havoc on the Java XML parser,
        # which considers them content before the prolog
        stdout_str.strip!.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
        
        Nokogiri::XML(stdout_str)        
      end
      
      def get_stickyflag_root(xml_doc)
        xml_doc.xpath("/Tags/Tag").each do |tag|
          targets = tag.at_xpath("Targets")
          next if targets.nil? # This shouldn't ever happen
          
          # If there's no UID elements under this tag, then we're good (note
          # that sometimes mkvpropedit will *force* in a TargetTypeValue or
          # a TargetType, and we don't want to block on those)
          good = true
          targets.children.each do |child|
            if child.name.end_with? 'UID'
              good = false
              break
            end
          end
          
          return tag if good
        end
        
        # Make one, then
        tag_tag = Nokogiri::XML::Node.new 'Tag', xml_doc
        targets_tag = Nokogiri::XML::Node.new 'Targets', xml_doc
        tag_tag.add_child targets_tag

        root_elem = xml_doc.at_xpath("/Tags")
        root_elem.add_child tag_tag
        
        tag_tag
      end
      
      def get_stickyflag_tag(xml_doc)
        tag_tag = get_stickyflag_root(xml_doc)
        if tag_tag.nil?
          # Should never happen!
          raise Thor::Error.new("INTERNAL ERROR: Failed to find the StickyFlag tag root in MKV XML")
        end
        
        tag_tag.at_xpath("Simple[Name = 'X_STICKYFLAG_FLAGS']/String")
      end
      
      def set_tag_xml(xml_doc, file_name, mkvextract_path = 'mkvextract', mkvpropedit_path = 'mkvpropedit')
        # Write out this XML file and attach it to the MKV
        outfile = Tempfile.new_with_encoding ['sfmkvtag', '.xml']
        begin
          outfile.write(xml_doc.to_xml)
          outfile.close
          
          ret = system(mkvpropedit_path, file_name, '--tags', "all:#{outfile.path}", "-q")
          unless ret == true
            raise Thor::Error.new("ERROR: Failed to update tag for #{file_name}; mkvpropedit call failed")
          end
        ensure
          outfile.unlink
        end
      end
    
      def get(file_name, mkvextract_path = 'mkvextract', mkvpropedit_path = 'mkvpropedit')
        xml_doc = get_tag_xml(file_name, mkvextract_path, mkvpropedit_path)
        stickyflag_tag = get_stickyflag_tag(xml_doc)
        return [] if stickyflag_tag.nil?
        
        tag_string = stickyflag_tag.content
        return [] if tag_string.nil? || tag_string.empty?
        
        tag_string.split(',').map { |t| t.empty? ? nil : t.strip }.compact
      end
    
      def set(file_name, tag, mkvextract_path = 'mkvextract', mkvpropedit_path = 'mkvpropedit')
        xml_doc = get_tag_xml(file_name, mkvextract_path, mkvpropedit_path)
        stickyflag_tag = get_stickyflag_tag(xml_doc)
        
        unless stickyflag_tag.nil?
          # We already have the right tag, check it
          tag_string = stickyflag_tag.content
          unless tag_string.nil? || tag_string.empty?
            tags = tag_string.split(',').map { |t| t.empty? ? nil : t.strip }.compact
            return if tags.include? tag
            tags << tag
            
            # Set the new string in the XML file
            new_tag_string = tags.join(', ')
            stickyflag_tag.content = new_tag_string
          else
            # Somehow the tag has no content, write it in
            stickyflag_tag.content = tag
          end
        else
          # No tag, add it
          root = get_stickyflag_root(xml_doc)
          simple_tag = Nokogiri::XML::Node.new 'Simple', xml_doc
          
          name_tag = Nokogiri::XML::Node.new 'Name', xml_doc
          name_tag.content = 'X_STICKYFLAG_FLAGS'
          string_tag = Nokogiri::XML::Node.new 'String', xml_doc
          string_tag.content = tag
          
          simple_tag.add_child(name_tag)
          simple_tag.add_child(string_tag)
          
          root.add_child(simple_tag)
        end
        
        set_tag_xml(xml_doc, file_name, mkvextract_path, mkvpropedit_path)
      end

      def unset(file_name, tag, mkvextract_path = 'mkvextract', mkvpropedit_path = 'mkvpropedit')
        xml_doc = get_tag_xml(file_name, mkvextract_path, mkvpropedit_path)
        stickyflag_tag = get_stickyflag_tag(xml_doc)
        
        unless stickyflag_tag.nil?
          # We already have the right tag, check it
          tag_string = stickyflag_tag.content
          unless tag_string.nil? || tag_string.empty?
            tags = tag_string.split(',').map { |t| t.empty? ? nil : t.strip }.compact
            return unless tags.include? tag
            tags.delete(tag)
            
            # Set the new string in the XML file
            new_tag_string = tags.join(', ')
            stickyflag_tag.content = new_tag_string
            
            set_tag_xml(xml_doc, file_name, mkvextract_path, mkvpropedit_path)
          end
        end
      end

      def clear(file_name, mkvextract_path = 'mkvextract', mkvpropedit_path = 'mkvpropedit')
        xml_doc = get_tag_xml(file_name, mkvextract_path, mkvpropedit_path)
        stickyflag_tag = get_stickyflag_tag(xml_doc)
        
        unless stickyflag_tag.nil?
          stickyflag_tag.remove
          set_tag_xml(xml_doc, file_name, mkvextract_path, mkvpropedit_path)
        end
      end
    end
  end
end
