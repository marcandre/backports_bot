require_relative './source_code'

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
    
    include SourceCode
    module_function :get, :set, :unset, :clear
  end
end
