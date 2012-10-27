# -*- encoding : utf-8 -*-
require 'stickyflag/paths'
require 'stickyflag/configuration'

class ConfigTester < Thor
  include StickyFlag::Paths
  include StickyFlag::Configuration
end

describe 'StickyFlag::Configuration' do  
  describe '#initialize' do
    it 'loads default configuration values' do
      @obj = ConfigTester.new
      @obj.stub(:load_config!) { }
      @obj.stub(:save_config!) { }
      
      StickyFlag::Configuration::DEFAULT_CONFIG.keys.each do |k|        
        @obj.get_config(k).should eq(StickyFlag::Configuration::DEFAULT_CONFIG[k])
      end
    end
  end
  
  describe '.get_config' do
    before(:each) do      
      @obj = ConfigTester.new
      
      @obj.stub(:load_config!) { }
      @obj.stub(:save_config!) { }
    end
    
    context 'with good keys' do
      it 'reads default values' do
        @obj.get_config(:have_pdftk).should eq(false)
      end
    
      it 'reads updated values' do
        @obj.set_config :have_pdftk, true
        @obj.get_config(:have_pdftk).should eq(true)
      end
    end
    
    context 'with bad keys' do
      it 'raises an error on get' do
        expect { @obj.get_config(:bad_key) }.to raise_error
      end
      
      it 'raises an error on set' do
        expect { @obj.set_config(:bad_key, 'test') }.to raise_error
      end
    end
  end
  
  describe '.reset_config!' do
    before(:each) do      
      @obj = ConfigTester.new
      
      @obj.stub(:load_config!) { }
      @obj.stub(:save_config!) { }
      
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
      
      @obj.stub(:load_config!) { }
      @obj.stub(:save_config!) { }
      
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
      
      @obj.stub(:save_config!) { }

      @config_file = File.join(File.dirname(__FILE__), 'config.yml')
      @obj.stub(:config_path) { @config_file }      
    end
    
    it 'should load from the requested YAML file' do
      config = {
        :have_pdftk => true,
        :pdftk_path => 'wut'
      }
      File.open(@config_file, 'w:UTF-8') do |f|
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
      
      @obj.stub(:load_config!) { }

      @config_file = File.join(File.dirname(__FILE__), 'config.yml')
      @obj.stub(:config_path) { @config_file }      
    end
    
    it 'should save to the requested YAML file' do
      @obj.set_config :pdftk_path, 'wut'
      @obj.save_config!
      
      config = YAML::load(File.open(@config_file, 'r:UTF-8'))
      config[:pdftk_path].should eq('wut')
      
      File.delete(@config_file)
    end
  end
end
