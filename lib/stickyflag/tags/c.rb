# -*- encoding : utf-8 -*-
require 'stickyflag/tags/source_code'

module StickyFlag
  module Tags
    module C
      module_function
    
      def comment_line_regex
        /\A\/\/ .*/
      end
    
      def tag_line_regex
        /\A\/\/ SF_TAGS = (.*)/
      end
    
      def tag_line_for(str)
        "// SF_TAGS = #{str}"
      end
    
      include StickyFlag::Tags::SourceCode
      module_function :get, :set, :unset, :clear
    end
  end
end
