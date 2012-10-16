require 'fileutils'

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
    
    it "can create lots and lots in a row" do
      files = []
      (1..1000).each do |i|
        files << File.tmpnam
        FileUtils.touch(files.last)
      end
      
      files.each { |f| File.unlink(f) }
    end
  end
end
