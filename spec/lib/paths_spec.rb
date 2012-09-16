require_relative '../../lib/paths'

describe 'Paths' do
  describe '.config' do
    it 'includes the config.yml filename' do
      Paths.config.should include('config.yml')
    end
    
    it "doesn't include any tildes" do
      Paths.config.should_not include('~')
    end
  end
  
  describe '.data' do
    it 'includes the db.sqlite filename' do
      Paths.data.should include('db.sqlite')
    end
    
    it "doesn't include any tildes" do
      Paths.config.should_not include('~')
    end
  end
end

