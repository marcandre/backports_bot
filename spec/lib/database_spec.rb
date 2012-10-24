require 'sqlite3'
require_relative '../../lib/paths'
require_relative '../../lib/configuration'
require_relative '../../lib/external_cmds'
require_relative '../../lib/tag_factory'
require_relative '../../lib/database'

class DatabaseTester < Thor
  include Paths
  include Configuration
  include ExternalCmds
  include TagFactory
  include Database
end

describe 'Database' do
  before(:each) do
    @obj = DatabaseTester.new
    
    @obj.stub(:load_config!) { }
    @obj.stub(:save_config!) { }
    
    @obj.find_external_cmds
    
    @database = SQLite3::Database.new ":memory:"
    @obj.stub(:load_database) { 
      @obj.instance_variable_set(:@database, @database)
      @obj.create_tables
    }
    @obj.load_database
  end
  
  after(:each) do
    @database.close
  end
  
  describe '.load_database' do
    before(:each) do
      @obj.stub(:database_path) { ":memory:" }
      @obj.unstub(:load_database)
    end
    
    it 'successfully creates a database' do
      expect { @obj.load_database }.to_not raise_error
    end
    
    it 'sets the member variable' do
      @obj.load_database
      @obj.instance_variable_get(:@database).should be
    end
  end
  
  describe '.update_database_from_files' do
    context 'without a specific directory' do
      before(:each) do
        @obj.update_database_from_files
      end
      
      it 'has some files in the database' do
        @database.execute("select * from tagged_files").should_not be_empty
      end
      
      it 'has found the test and asdf tags' do
        @obj.tag_list.should include('asdf')
        @obj.tag_list.should include('test')
      end
      
      it 'has found a sample markdown file' do
        path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_keys.mmd'))
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
        @database.execute("select * from tagged_files").should be_empty
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
        @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
      end
      
      it 'has some files in the database' do
        @database.execute("select * from tagged_files").should_not be_empty
      end
      
      it 'has found the test and asdf tags' do
        @obj.tag_list.should include('asdf')
        @obj.tag_list.should include('test')
      end
      
      it 'has found a sample markdown file' do
        path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_keys.mmd'))
        @obj.files_for_tags(['test']).map { |f| File.expand_path(f) }.should include(path)
      end
    end
  end
  
  describe '.set_database_tag' do
    context 'with an already extant tag' do
      before(:each) do
        @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
        @path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_with_tag.mmd')
        @obj.set_database_tag(@path, 'asdf')
      end
      
      it "adds the record for the tagged file" do
        file_id = @database.get_first_value("select id from file_list where file_name = ?", [ @path ])
        file_id.should_not be_nil
        
        tag_id = @database.get_first_value("select id from tag_list where tag_name = 'asdf'")
        tag_id.should_not be_nil
        
        rows = @database.execute("select * from tagged_files where file = ? and tag = ?", [ file_id, tag_id ])
        rows.should_not be_empty
        rows.count.should eq(1)
      end
      
      it "doesn't duplicate the entry for the tag" do
        rows = @database.execute("select * from tag_list where tag_name = 'asdf'")
        rows.count.should eq(1)
      end
    end
    
    context 'with a new tag' do
      before(:each) do
        @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
        @path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_with_tag.mmd')
        @obj.set_database_tag(@path, 'zuzzax')
      end
      
      it "adds a new record for the new tag" do
        rows = @database.execute("select * from tag_list where tag_name = 'zuzzax'")
        rows.should_not be_empty
        rows.count.should eq(1)
      end
      
      it "adds the record for the tagged file" do
        file_id = @database.get_first_value("select id from file_list where file_name = ?", [ @path ])
        file_id.should_not be_nil
        
        tag_id = @database.get_first_value("select id from tag_list where tag_name = 'zuzzax'")
        tag_id.should_not be_nil
        
        rows = @database.execute("select * from tagged_files where file = ? and tag = ?", [ file_id, tag_id ])
        rows.should_not be_empty
        rows.count.should eq(1)
      end
    end
  end
  
  describe '.unset_database_tag' do
    context 'with a multiply-present tag' do
      before(:each) do
        @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
        @path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_with_tag.mmd')
      end
      
      it 'removes the record for the tagged file' do
        @obj.unset_database_tag(@path, 'test')
        
        file_id = @database.get_first_value("select id from file_list where file_name = ?", [ @path ])
        file_id.should_not be_nil
        
        tag_id = @database.get_first_value("select id from tag_list where tag_name = 'test'")
        tag_id.should_not be_nil
        
        rows = @database.execute("select * from tagged_files where file = ? and tag = ?", [ file_id, tag_id ])
        rows.should be_empty
      end
    end
    
    context 'with a singly-present tag' do
      before(:each) do
        @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
        @path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd')
      end
      
      it 'removes the record for the tagged file' do        
        file_id = @database.get_first_value("select id from file_list where file_name = ?", [ @path ])
        file_id.should_not be_nil
        
        tag_id = @database.get_first_value("select id from tag_list where tag_name = 'qwer'")
        tag_id.should_not be_nil

        @obj.unset_database_tag(@path, 'qwer')
        
        rows = @database.execute("select * from tagged_files where file = ? and tag = ?", [ file_id, tag_id ])
        rows.should be_empty
      end
      
      it 'removes the record of the tag' do
        @obj.unset_database_tag(@path, 'qwer')
        tag_id = @database.get_first_value("select id from tag_list where tag_name = 'qwer'")
        tag_id.should be_nil
      end
    end
  end
  
  describe '.clear_database_tags' do
    before(:each) do
      @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
      @path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd')
      @obj.clear_database_tags(@path)
    end
    
    it 'removes all tag records for the file' do
      file_id = @database.get_first_value("select id from file_list where file_name = ?", [ @path ])
      file_id.should_not be_nil
      
      rows = @database.execute("select * from tagged_files where file = ?", [ file_id ])
      rows.should be_empty
    end
    
    it 'removes the tag after clearing single-instance tags' do
      rows = @database.execute("select * from tag_list where tag_name = 'qwer'")
      rows.should be_empty
    end
  end
  
  describe '.files_for_tags' do
    before(:each) do
      @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
    end
    
    context 'with good, single tags' do
      it 'includes one of the markdown files' do
        path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_keys.mmd')
        @obj.files_for_tags([ 'test' ]).should include(path)
      end
    
      it 'does not include files that lack a tag' do
        path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_with_tag.mmd')
        @obj.files_for_tags([ 'asdf' ]).should_not include(path)
      end
    
      it 'does not include untaggable files' do
        path = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'untaggable.txt')
        @obj.files_for_tags([ 'test' ]).should_not include(path)
      end
    end
    
    context 'with multiple tags' do
      it 'combines with boolean AND' do
        path1 = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd')
        path2 = File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_with_tag.mmd')
      
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
        @obj.update_database_from_files(File.join(File.dirname(__FILE__), '..', 'support', 'examples'))
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
