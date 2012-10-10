# -*- encoding : utf-8 -*-
require_relative '../../lib/paths'

class PathsTester
  include Paths
end

describe 'Paths' do
  describe '.config_path' do
    it 'includes the config.yml file name' do
      PathsTester.new.config_path.should include('config.yml')
    end
    
    it "doesn't include any tildes" do
      PathsTester.new.config_path.should_not include('~')
    end
  end
  
  describe '.database_path' do
    it 'includes the db.sqlite file name' do
      PathsTester.new.database_path.should include('db.sqlite')
    end
    
    it "doesn't include any tildes" do
      PathsTester.new.database_path.should_not include('~')
    end
  end
end

