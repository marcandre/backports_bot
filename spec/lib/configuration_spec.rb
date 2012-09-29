require_relative '../../lib/paths'
require_relative '../../lib/configuration'

class ConfigTester < Thor
  include Paths
  include Configuration
end

describe 'Configuration' do
  describe '#initialize' do
    it 'loads default configuration values' do
      Configuration::DEFAULT_CONFIG.keys.each do |k|
        ConfigTester.new.get_config(k).should eq(Configuration::DEFAULT_CONFIG[k])
      end
    end
  end
  
  describe '.get_config' do
    before(:each) do
      @obj = ConfigTester.new
    end
    
    it 'reads default values' do
      @obj.get_config(:have_pdftk).should eq(false)
    end
    
    it 'reads updated values' do
      @obj.set_config :have_pdftk, true
      @obj.get_config(:have_pdftk).should eq(true)
    end
  end
  
  describe '.reset_config!' do
    before(:each) do
      @obj = ConfigTester.new
      @obj.set_config :have_pdftk, true
    end
    
    it 'resets changed values to defaults' do
      @obj.reset_config!
      @obj.get_config(:have_pdftk).should eq(false)
    end
  end
  
  describe '.dump_config' do
    before(:each) do
      @obj = ConfigTester.new
      @obj.set_config :pdftk_path, 'wut'
    end
    
    it 'prints out the set configuration values' do
      @obj.stub(:say) {}
      @obj.should_receive(:say).with(/pdftk_path: 'wut'/)
      @obj.dump_config
    end
  end
  
  describe '.load_config!' do
    before(:each) do
      @obj = ConfigTester.new

      Configuration.unstub(:load_config!)
      @config_file = File.join(File.dirname(__FILE__), 'config.yml')
      @obj.stub(:config_path) { @config_file }      
    end
    
    it 'should load from the requested YAML file' do
      config = {
        :have_pdftk => true,
        :pdftk_path => 'wut'
      }
      File.open(@config_file, 'w') do |f|
        YAML.dump(config, f)
      end
      
      @obj.load_config!
      @obj.get_config(:pdftk_path).should eq('wut')
      
      File.delete(@config_file)
    end
  end
  
  describe '.save_config!' do
    before(:each) do
      @obj = ConfigTester.new

      Configuration.unstub(:save_config!)
      @config_file = File.join(File.dirname(__FILE__), 'config.yml')
      @obj.stub(:config_path) { @config_file }      
    end
    
    it 'should save to the requested YAML file' do
      @obj.set_config :pdftk_path, 'wut'
      @obj.save_config!
      
      config = YAML::load(File.open(@config_file))
      config[:pdftk_path].should eq('wut')
      
      File.delete(@config_file)
    end
  end
end
