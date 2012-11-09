# -*- encoding : utf-8 -*-
require 'stickyflag/patches/tempfile_encoding'

describe 'Tempfile' do
  describe '.new_with_encoding' do
    it 'successfully creates temporary files' do
      f = Tempfile.new_with_encoding 'asdf'
      f.should be
      
      f.close
      f.unlink
    end
    
    # JRuby <1.7.0 implements Ruby 1.9 but doesn't follow the spec for Tempfile.
    # RBX doesn't seem to set external_encoding right, at least on some
    # versions, so don't run that spec there.
    if RUBY_VERSION >= "1.9.0" && (RUBY_PLATFORM != 'java' || JRUBY_VERSION >= '1.7.0') && (!defined?(RUBY_ENGINE) || RUBY_ENGINE != 'rbx')
      it 'sets the correct external encoding' do
        f = Tempfile.new_with_encoding 'asdf'
        f.external_encoding.should be
        f.external_encoding.name.should eq('UTF-8')
        
        f.close
        f.unlink
      end
    end
  end
end
