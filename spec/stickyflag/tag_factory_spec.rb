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
    # Some extensions require the presence of actual, good files, not
    # just empty shells, so we can't test them in this way.  Skip those.
    CANNOT_TEST = [ '.pdf', '.png' ]
    
    it 'should call get for every good extension' do
      (@obj.available_tagging_extensions - CANNOT_TEST).each do |ext|
        file = Tempfile.new_with_encoding(['ext', ext])
        file.puts('test')        
        file.close
        
        expect { @obj.get_tags_for(file.path) }.to_not raise_error
        file.unlink
      end
    end
    
    it 'should call get for other extensions' do
      CANNOT_TEST.each do |ext|
        path = copy_example "#{ext[1..-1]}_with_tag#{ext}"
        expect { @obj.clear_tags_for(path) }.to_not raise_error
        File.unlink(path)
      end
    end

    it 'should call set/unset for every good extension' do
      (@obj.available_tagging_extensions - CANNOT_TEST).each do |ext|
        file = Tempfile.new_with_encoding(['ext', ext])
        file.puts('test')        
        file.close
        
        expect { 
          @obj.set_tag_for(file.path, 'test')
          @obj.unset_tag_for(file.path, 'test')
          }.to_not raise_error
        file.unlink
      end
    end
    
    it 'should call set/unset for other extensions' do
      CANNOT_TEST.each do |ext|
        path = copy_example "#{ext[1..-1]}_with_tag#{ext}"
        expect {
          @obj.set_tag_for(path, 'test2')
          @obj.unset_tag_for(path, 'test2')
          }.to_not raise_error
        File.unlink(path)
      end
    end
    
    it 'should call clear for every good extension' do
      (@obj.available_tagging_extensions - CANNOT_TEST).each do |ext|
        file = Tempfile.new_with_encoding(['ext', ext])
        file.puts('test')        
        file.close
        
        expect { @obj.clear_tags_for(file.path) }.to_not raise_error
        file.unlink
      end
    end
    
    it 'should call clear for other extensions' do
      CANNOT_TEST.each do |ext|
        path = copy_example "#{ext[1..-1]}_with_tag#{ext}"
        expect { @obj.clear_tags_for(path) }.to_not raise_error
        File.unlink(path)
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
