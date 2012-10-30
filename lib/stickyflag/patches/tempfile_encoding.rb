# -*- encoding : utf-8 -*-
require 'tempfile'

class Tempfile
  
  unless Tempfile.respond_to?(:new_with_encoding)
    def self.new_with_encoding(params)
      # JRuby's Tempfile constructor got the third hash parameter in JRuby
      # 1.7.0-preview1.
      if RUBY_VERSION >= "1.9.0" || (RUBY_PLATFORM == 'java' && JRUBY_VERSION >= '1.7.0')
        return Tempfile.new(params, Dir.tmpdir, :encoding => "UTF-8")
      else
        # No coverage on Ruby 1.8, ignore
        #:nocov:
        return Tempfile.new(params)
        #:nocov:
      end
    end
  end
  
end

