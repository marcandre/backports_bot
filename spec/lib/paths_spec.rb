require_relative '../../lib/paths'

class PathsTester
  include Paths
end

describe 'Paths' do
  describe '.config' do
    it 'includes the config.yml filename' do
      PathsTester.new.config_path.should include('config.yml')
    end
    
    it "doesn't include any tildes" do
      PathsTester.new.config_path.should_not include('~')
    end
  end
  
  describe '.data' do
    it 'includes the db.sqlite filename' do
      PathsTester.new.data_path.should include('db.sqlite')
    end
    
    it "doesn't include any tildes" do
      PathsTester.new.data_path.should_not include('~')
    end
  end
end

