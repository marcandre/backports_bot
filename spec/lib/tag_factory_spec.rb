require 'thor'
require_relative '../../lib/paths'
require_relative '../../lib/configuration'
require_relative '../../lib/tag_factory'
require_relative '../../lib/external_cmds'

class TagFactoryTester
  include Paths
  include Configuration
  include TagFactory
  include ExternalCmds
end

describe 'TagFactory' do
  before(:each) do
    @obj = TagFactoryTester.new
    @obj.find_external_cmds
  end
  
  describe '.get_tags_for' do
    it 'should delegate to PDF' do
      path = example_path('pdf_no_tags.pdf')
      
      Tags::PDF.should_receive(:get).with(path, kind_of(String))
      @obj.get_tags_for(path)
    end
    
    it 'should raise error for unknown extensions' do
      expect {
        @obj.get_tags_for(Pathname.new('asdf.zzy'))
        }.to raise_error(Thor::Error)
    end
  end

  describe '.set_tag_for' do
    it 'should delegate to PDF' do
      path = example_path('pdf_no_tags.pdf')
      
      Tags::PDF.should_receive(:set).with(path, 'lol', kind_of(String))
      @obj.set_tag_for(path, 'lol')
    end
    
    it 'should not call through if the tag is already set' do
      path = example_path('pdf_with_tag.pdf')
      
      Tags::PDF.should_not_receive(:set)
      @obj.set_tag_for(path, 'test')
    end
    
    it 'should raise error for unknown extensions' do
      expect {
        @obj.set_tag_for(Pathname.new('asdf.zzy'), 'lol')
        }.to raise_error(Thor::Error)
    end
  end
  
  describe '.unset_tag_for' do
    it 'should delegate to PDF' do
      path = copy_example('pdf_with_tag.pdf')
      
      Tags::PDF.should_receive(:unset).with(path, 'test', kind_of(String))
      @obj.unset_tag_for(path, 'test')
      
      File.delete(path)
    end
    
    it 'should not call through if the tag is not set' do
      path = example_path('pdf_no_tags.pdf')
      
      Tags::PDF.should_not_receive(:unset)
      expect {
        @obj.unset_tag_for(path, 'test')
        }.to raise_error(Thor::Error)
    end
    
    it 'should raise error for unknown extensions' do
      expect {
        @obj.unset_tag_for(Pathname.new('asdf.zzy'), 'lol')
        }.to raise_error(Thor::Error)
    end
  end

  describe '.clear_tags_for' do
    it 'should delegate to PDF' do
      path = copy_example('pdf_with_tag.pdf')
      
      Tags::PDF.should_receive(:clear).with(path, kind_of(String))
      @obj.clear_tags_for(path)
      
      File.delete(path)
    end
    
    it 'should raise error for unknown extensions' do
      expect {
        @obj.clear_tags_for(Pathname.new('asdf.zzy'))
        }.to raise_error(Thor::Error)
    end
  end
end
