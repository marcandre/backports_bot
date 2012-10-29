# -*- encoding : utf-8 -*-
require 'stickyflag/paths'
require 'stickyflag/configuration'
require 'stickyflag/external_cmds'
require 'stickyflag/tag_factory'
require 'stickyflag/database'

class DatabaseTester < Thor
  include StickyFlag::Paths
  include StickyFlag::Configuration
  include StickyFlag::ExternalCmds
  include StickyFlag::TagFactory
  include StickyFlag::Database
end

describe 'StickyFlag::Database' do
  before(:each) do
    @obj = DatabaseTester.new
    
    @obj.stub(:load_config!) { }
    @obj.stub(:save_config!) { }
    @obj.stub(:database_path) { ":memory:" }
    
    @obj.find_external_cmds
    @obj.load_database
    
    # Save this out for (lots of) later use
    @database = @obj.instance_variable_get(:@database)
  end
  
  after(:each) do
    # We've disabled automatic cleanup, so make sure we do this
    @database.disconnect
  end
  
  describe '.load_database' do
    it 'sets the member variable' do
      @database.should be
    end
  end
  
  describe '.update_database_from_files' do
    context 'without a specific directory' do
      before(:each) do
        @obj.update_database_from_files
      end
      
      it 'has some files in the database' do
        @database[:tagged_files].should_not be_empty
      end
      
      it 'has found the test and asdf tags' do
        @obj.tag_list.should include('asdf')
        @obj.tag_list.should include('test')
      end
      
      it 'has found a sample markdown file' do
        path = example_path 'mmd_crazy_keys.mmd'
        @obj.files_for_tags(['test']).map { |f| File.expand_path(f) }.should include(path)
      end
    end
    
    context 'with an empty directory' do
      before(:each) do
        @dir = File.tmpnam('.dir')
        Dir.mkdir(@dir)
        
        @obj.update_database_from_files(@dir)
      end
      
      after(:each) do
        Dir.rmdir(@dir)
      end
      
      it 'has no files in the database' do
        @database[:tagged_files].should be_empty
      end
    end
    
    context 'with some bad files in the directory' do
      before(:each) do
        @dir = File.tmpnam('.dir')
        Dir.mkdir(@dir)
        
        file = File.new(File.join(@dir, 'bad.pdf'), 'w:UTF-8')
        file.puts('test bad')
        file.close
      end
      
      after(:each) do
        File.unlink(File.join(@dir, 'bad.pdf'))
        Dir.rmdir(@dir)
      end
      
      it 'does not throw an exception' do
        expect { @obj.update_database_from_files(@dir) }.to_not raise_error
      end
      
      it 'prints a warning' do
        @obj.should_receive(:say_status).with(:warning, kind_of(String), kind_of(Symbol))
        @obj.update_database_from_files(@dir)
      end
    end
    
    context 'with a full directory' do
      before(:each) do
        @obj.update_database_from_files(example_root)
      end
      
      it 'has some files in the database' do
        @database[:tagged_files].should_not be_empty
      end
      
      it 'has found the test and asdf tags' do
        @obj.tag_list.should include('asdf')
        @obj.tag_list.should include('test')
      end
      
      it 'has found a sample markdown file' do
        path = example_path 'mmd_crazy_keys.mmd'
        @obj.files_for_tags(['test']).map { |f| File.expand_path(f) }.should include(path)
      end
    end
  end
  
  describe '.set_database_tag' do
    context 'with an already extant tag' do
      before(:each) do
        @obj.update_database_from_files example_root
        @path = example_path 'mmd_with_tag.mmd'
        @obj.set_database_tag(@path, 'asdf')
      end
      
      it "adds the record for the tagged file" do
        file_id = @database[:file_list].where(:file_name => @path).get(:id)
        file_id.should_not be_nil
        
        tag_id = @database[:tag_list].where(:tag_name => 'asdf').get(:id)
        tag_id.should_not be_nil
        
        ds = @database[:tagged_files].where(:file => file_id).and(:tag => tag_id)
        ds.should_not be_empty
        ds.count.should eq(1)
      end
      
      it "doesn't duplicate the entry for the tag" do
        ds = @database[:tag_list].where(:tag_name => 'asdf')
        ds.count.should eq(1)
      end
    end
    
    context 'with a new tag' do
      before(:each) do
        @obj.update_database_from_files example_root
        @path = example_path 'mmd_with_tag.mmd'
        @obj.set_database_tag(@path, 'zuzzax')
      end
      
      it "adds a new record for the new tag" do
        ds = @database[:tag_list].where(:tag_name => 'zuzzax')
        ds.should_not be_empty
        ds.count.should eq(1)
      end
      
      it "adds the record for the tagged file" do
        file_id = @database[:file_list].where(:file_name => @path).get(:id)
        file_id.should_not be_nil
        
        tag_id = @database[:tag_list].where(:tag_name => 'zuzzax').get(:id)
        tag_id.should_not be_nil
        
        ds = @database[:tagged_files].where(:file => file_id).and(:tag => tag_id)
        ds.should_not be_empty
        ds.count.should eq(1)
      end
    end
  end
  
  describe '.unset_database_tag' do
    context 'with a multiply-present tag' do
      before(:each) do
        @obj.update_database_from_files example_root
        @path = example_path 'mmd_with_tag.mmd'
      end
      
      it 'removes the record for the tagged file' do
        @obj.unset_database_tag(@path, 'test')
        
        file_id = @database[:file_list].where(:file_name => @path).get(:id)
        file_id.should_not be_nil
        
        tag_id = @database[:tag_list].where(:tag_name => 'test').get(:id)
        tag_id.should_not be_nil
        
        ds = @database[:tagged_files].where(:file => file_id).and(:tag => tag_id)
        ds.should be_empty
      end
    end
    
    context 'with a singly-present tag' do
      before(:each) do
        @obj.update_database_from_files example_root
        @path = example_path 'mmd_crazy_tags.mmd'
      end
      
      it 'removes the record for the tagged file' do        
        file_id = @database[:file_list].where(:file_name => @path).get(:id)
        file_id.should_not be_nil
        
        tag_id = @database[:tag_list].where(:tag_name => 'qwer').get(:id)
        tag_id.should_not be_nil

        @obj.unset_database_tag(@path, 'qwer')
        
        ds = @database[:tagged_files].where(:file => file_id).and(:tag => tag_id)
        ds.should be_empty
      end
      
      it 'removes the record of the tag' do
        @obj.unset_database_tag(@path, 'qwer')
        ds = @database[:tag_list].where(:tag_name => 'qwer')
        ds.should be_empty
      end
    end
  end
  
  describe '.clear_database_tags' do
    before(:each) do
      @obj.update_database_from_files example_root
      @path = example_path 'mmd_crazy_tags.mmd'
      @obj.clear_database_tags(@path)
    end
    
    it 'removes all tag records for the file' do
      file_id = @database[:file_list].where(:file_name => @path).get(:id)
      file_id.should_not be_nil
      
      ds = @database[:tagged_files].where(:file => file_id)
      ds.should be_empty
    end
    
    it 'removes the tag after clearing single-instance tags' do
      ds = @database[:tag_list].where(:tag_name => 'qwer')
      ds.should be_empty
    end
  end
  
  describe '.files_for_tags' do
    before(:each) do
      @obj.update_database_from_files example_root
    end
    
    context 'with good, single tags' do
      it 'includes one of the markdown files' do
        path = example_path 'mmd_crazy_keys.mmd'
        @obj.files_for_tags([ 'test' ]).should include(path)
      end
    
      it 'does not include files that lack a tag' do
        path = example_path 'mmd_with_tag.mmd'
        @obj.files_for_tags([ 'asdf' ]).should_not include(path)
      end
    
      it 'does not include untaggable files' do
        path = example_path 'untaggable.txt'
        @obj.files_for_tags([ 'test' ]).should_not include(path)
      end
    end
    
    context 'with multiple tags' do
      it 'combines with boolean AND' do
        path1 = example_path 'mmd_crazy_tags.mmd'
        path2 = example_path 'mmd_with_tag.mmd'
      
        files = @obj.files_for_tags([ 'sdfg', 'asdf', 'qwer' ])
        files.should include(path1)
        files.should_not include(path2)
      end
      
      it 'prints a warning if no files have all those tags' do
        @obj.should_receive(:say_status).with(:warning, kind_of(String), kind_of(Symbol))
        @obj.files_for_tags([ 'asdf', 'test' ])
      end
      
      it 'returns an empty array if no files have all those tags' do
        @obj.files_for_tags([ 'asdf', 'test' ]).should be_empty
      end
    end
    
    context 'with missing tags' do
      it "doesn't throw" do
        expect { @obj.files_for_tags([ 'zuzzax' ]) }.to_not raise_error
      end

      it 'prints a warning' do
        @obj.should_receive(:say_status).with(:warning, kind_of(String), kind_of(Symbol))
        @obj.files_for_tags([ 'zuzzax' ])
      end
    
      it 'returns an empty array' do
        @obj.files_for_tags([ 'zuzzax', 'test' ]).should be_empty
      end
    end
  end
  
  describe '.tag_list' do
    context 'prior to loading anything into the database' do
      it 'is empty' do
        @obj.tag_list.should be_empty
      end
    end
    
    context 'after loading files into the database' do
      before(:each) do
        @obj.update_database_from_files example_root
      end
      
      it 'includes multiply-present tags' do
        @obj.tag_list.should include('test')
      end
      
      it 'includes singly-present tags' do
        @obj.tag_list.should include('qwer')
      end
      
      it 'does not include absent tags' do
        @obj.tag_list.should_not include('zuzzax')
      end
    end
  end
end
