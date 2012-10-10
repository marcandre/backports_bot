require_relative '../../lib/tmpnam'

describe 'File' do
  describe '.tmpnam' do
    it "creates file names that don't exist" do
      File.exist?(File.tmpnam).should be_false
    end
    
    it "puts extensions on files (no dot)" do
      path = File.tmpnam('txt')
      path[-4..-1].should eq('.txt')
    end
    
    it "puts extensions on files (with dot)" do
      path = File.tmpnam('txt')
      path[-4..-1].should eq('.txt')
    end
    
    it "puts files in the temporary directory" do
      File.tmpnam.should start_with(Dir.tmpdir)
    end
  end
end
