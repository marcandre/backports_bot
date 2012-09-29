require 'thor'
require_relative '../../lib/paths'
require_relative '../../lib/configuration'
require_relative '../../lib/external_cmds'

class ExternalCmdsTester < Thor
  include Paths
  include Configuration
  include ExternalCmds
end

describe 'ExternalCmds' do
  # We want to handle the path manually here
  def add_to_path(file_name)
    ENV['PATH'] = File.dirname(__FILE__)
    
    path = File.join(File.dirname(__FILE__), file_name)
    File.open(path, 'w') { |f| f.write('test') }
    File.chmod(0755, path)
    
    @files_to_delete << path
  end
  
  before(:each) do
    @files_to_delete = []
    @old_path = ENV['PATH']
    ENV['PATH'] = ''
  end
  
  after(:each) do
    ENV['PATH'] = @old_path
    @files_to_delete.each { |f| File.delete f }
  end
  
  describe '.find_external_cmds' do
    describe 'with no configuration set, no pdftk' do
      before(:each) do
        @obj = ExternalCmdsTester.new
        @obj.set_config :pdftk_path, ''
        @obj.set_config :have_pdftk, false
      end
      
      it 'sets have_pdftk to false' do
        @obj.find_external_cmds
        @obj.get_config(:have_pdftk).should eq(false)
      end
      
      it 'outputs a warning message' do
        @obj.should_receive(:say_status).with(:warning, kind_of(String), kind_of(Symbol))
        @obj.find_external_cmds
      end
    end
    
    describe 'with no configuration set, with pdftk' do
      before(:each) do
        @obj = ExternalCmdsTester.new
        @obj.set_config :pdftk_path, ''
        @obj.set_config :have_pdftk, false
        
        add_to_path('pdftk')
      end
      
      it 'sets have_pdftk to true' do
        @obj.find_external_cmds
        @obj.get_config(:have_pdftk).should eq(true)
      end
      
      it 'sets the right pdftk path' do
        @obj.find_external_cmds
        
        path = File.expand_path(File.join(File.dirname(__FILE__), 'pdftk'))
        @obj.get_config(:pdftk_path).should eq(path)
      end
      
      it 'should not print any messages' do
        @obj.should_not_receive(:say)
        @obj.should_not_receive(:say_status)
        @obj.find_external_cmds
      end
    end
    
    describe 'with configuration set, non-executable pdftk' do
      before(:each) do
        @obj = ExternalCmdsTester.new
        @obj.set_config :pdftk_path, __FILE__
        @obj.set_config :have_pdftk, true
      end
      
      it 'resets have_pdftk to false' do
        @obj.find_external_cmds
        @obj.get_config(:have_pdftk).should be(false)
      end
      
      it 'unsets the pdftk path' do
        @obj.find_external_cmds
        @obj.get_config(:pdftk_path).should eq('')
      end
      
      it 'prints out an error message' do
        @obj.stub(:say_status) {}
        @obj.should_receive(:say_status).with(:error, kind_of(String), kind_of(Symbol))
        @obj.find_external_cmds
      end
    end
    
    describe 'with configuration set, non-existent pdftk' do
      before(:each) do
        @obj = ExternalCmdsTester.new
        @obj.set_config :pdftk_path, '/nope/wut'
        @obj.set_config :have_pdftk, true
      end
      
      it 'resets have_pdftk to false' do
        @obj.find_external_cmds
        @obj.get_config(:have_pdftk).should be(false)
      end
      
      it 'unsets the pdftk path' do
        @obj.find_external_cmds
        @obj.get_config(:pdftk_path).should eq('')
      end
      
      it 'prints out an error message' do
        @obj.stub(:say_status) {}
        @obj.should_receive(:say_status).with(:error, kind_of(String), kind_of(Symbol))
        @obj.find_external_cmds
      end
    end
    
    describe 'with configuration set, with pdftk' do
      before(:each) do
        @obj = ExternalCmdsTester.new
        @obj.set_config :pdftk_path, File.expand_path(File.join(File.dirname(__FILE__), 'pdftk'))
        @obj.set_config :have_pdftk, true
        
        add_to_path('pdftk')
      end
      
      it 'leaves have_pdftk true' do
        @obj.find_external_cmds
        @obj.get_config(:have_pdftk).should eq(true)
      end
      
      it 'leaves the right pdftk path' do
        @obj.find_external_cmds
        
        path = File.expand_path(File.join(File.dirname(__FILE__), 'pdftk'))
        @obj.get_config(:pdftk_path).should eq(path)
      end
      
      it 'should not print any messages' do
        @obj.should_not_receive(:say)
        @obj.should_not_receive(:say_status)
        @obj.find_external_cmds
      end
    end
  end
end
