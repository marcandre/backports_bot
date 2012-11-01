# -*- encoding : utf-8 -*-
require 'thor'
require 'stickyflag/patches/tempfile_encoding'
require 'stickyflag/paths'
require 'stickyflag/configuration'
require 'stickyflag/tag_factory'
require 'stickyflag/external_cmds'
require 'stickyflag/database'

class TagFactoryTester < Thor
  include StickyFlag::Paths
  include StickyFlag::Configuration
  include StickyFlag::TagFactory
  include StickyFlag::ExternalCmds
  include StickyFlag::Database
end

describe 'StickyFlag::TagFactory' do
  before(:each) do
    @obj = TagFactoryTester.new
    
    @obj.stub(:load_config!) { }
    @obj.stub(:save_config!) { }
    
    @obj.stub(:load_database) { }
    @obj.stub(:update_database_from_files) { }
    @obj.stub(:set_database_tag) { }
    @obj.stub(:unset_database_tag) { }
    @obj.stub(:clear_database_tags) { }
    @obj.stub(:files_for_tags) { [] }
    
    @obj.find_external_cmds
  end
  
  describe '.available_tagging_extensions' do
    it 'should be able to call through to a class method for every good extension' do
      # Add a test method to each of these classes that eats all its args
      StickyFlag::Tags.constants.map { |sym| 
        StickyFlag::Tags.const_get(sym) 
      }.select { |const| 
        const.is_a?(Module) && const.respond_to?(:extensions)
      }.each do |klass|
        klass.send(:define_method, :eat_all_args) do |*args|
        end
        klass.send(:module_function, :eat_all_args)
      end
      
      @obj.available_tagging_extensions.each do |ext|
        expect { @obj.call_tag_method("test#{ext}", :eat_all_args) }.to_not raise_error
      end
    end
  end
  
  describe '.get_tags_for' do
    it 'should delegate to PDF' do
      path = example_path('pdf_no_tags.pdf')
      
      StickyFlag::Tags::PDF.should_receive(:get).with(path, kind_of(String))
      @obj.get_tags_for(path)
    end
    
    it 'should raise error for unknown extensions' do
      expect {
        @obj.get_tags_for('asdf.zzy')
        }.to raise_error(Thor::Error)
    end
  end

  describe '.set_tag_for' do
    it 'should delegate to PDF' do
      path = example_path('pdf_no_tags.pdf')
      
      StickyFlag::Tags::PDF.should_receive(:set).with(path, 'lol', kind_of(String))
      @obj.set_tag_for(path, 'lol')
    end
    
    it 'should not call through if the tag is already set' do
      path = example_path('pdf_with_tag.pdf')
      
      StickyFlag::Tags::PDF.should_not_receive(:set)
      @obj.set_tag_for(path, 'test')
    end
    
    it 'should raise error for unknown extensions' do
      @obj.stub(:get_tags_for) { [] }
      expect {
        @obj.set_tag_for('asdf.zzy', 'lol')
        }.to raise_error(Thor::Error)
    end
  end
  
  describe '.unset_tag_for' do
    it 'should delegate to PDF' do
      path = copy_example('pdf_with_tag.pdf')
      
      StickyFlag::Tags::PDF.should_receive(:unset).with(path, 'test', kind_of(String))
      @obj.unset_tag_for(path, 'test')
      
      File.delete(path)
    end
    
    it 'should not call through if the tag is not set' do
      path = example_path('pdf_no_tags.pdf')
      
      StickyFlag::Tags::PDF.should_not_receive(:unset)
      expect {
        @obj.unset_tag_for(path, 'test')
        }.to raise_error(Thor::Error)
    end
    
    it 'should raise error for unknown extensions' do
      @obj.stub(:get_tags_for) { [ 'lol' ] }
      expect {
        @obj.unset_tag_for('asdf.zzy', 'lol')
        }.to raise_error(Thor::Error)
    end
  end

  describe '.clear_tags_for' do
    it 'should delegate to PDF' do
      path = copy_example('pdf_with_tag.pdf')
      
      StickyFlag::Tags::PDF.should_receive(:clear).with(path, kind_of(String))
      @obj.clear_tags_for(path)
      
      File.delete(path)
    end
    
    it 'should raise error for unknown extensions' do
      expect {
        @obj.clear_tags_for('asdf.zzy')
        }.to raise_error(Thor::Error)
    end
  end
end
