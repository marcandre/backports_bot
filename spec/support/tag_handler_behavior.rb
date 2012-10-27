# -*- encoding : utf-8 -*-

shared_examples_for 'a tag handler' do
  let(:params) { [] }
  
  def file_extension
    described_class.to_s.gsub('StickyFlag::Tags::', '').downcase
  end
  
  def example_with_tag
    example_path "#{file_extension}_with_tag.#{file_extension}"
  end  
  def example_no_tags
    example_path "#{file_extension}_no_tags.#{file_extension}"
  end
  def copy_example_with_tag
    copy_example "#{file_extension}_with_tag.#{file_extension}"
  end  
  def copy_example_no_tags
    copy_example "#{file_extension}_no_tags.#{file_extension}"
  end
  
  def params_for(*new_params)
    new_params.concat(params)
  end
  
  describe '.get' do
    it 'exists' do
      described_class.methods.should include(:get) if RUBY_VERSION >= "1.9.0"
      described_class.methods.should include("get") if RUBY_VERSION < "1.9.0"
    end
    
    it 'gets tags from tagged files' do
      described_class.get(*params_for(example_with_tag)).should include('test')
    end
    
    it 'does not get tags from untagged files' do
      described_class.get(*params_for(example_no_tags)).should_not include('test')
    end
  end
  
  describe '.set' do
    it 'exists' do
      described_class.methods.should include(:set) if RUBY_VERSION >= "1.9.0"
      described_class.methods.should include("set") if RUBY_VERSION < "1.9.0"
    end
    
    it 'sets tags in an untagged file' do
      path = copy_example_no_tags
      
      described_class.set(*params_for(path, 'rspec'))
      described_class.get(*params_for(path)).should include('rspec')
      
      File.unlink(path)
    end
    
    it 'sets tags in a tagged file' do
      path = copy_example_with_tag
      
      described_class.set(*params_for(path, 'rspec'))
      described_class.get(*params_for(path)).should include('rspec')
      
      File.unlink(path)
    end
    
    it 'does the right thing when setting an already set tag' do
      path = copy_example_with_tag
      
      described_class.set(*params_for(path, 'test'))
      described_class.get(*params_for(path)).count('test').should eq(1)
      
      File.unlink(path)
    end
  end
  
  describe '.unset' do
    it 'exists' do
      described_class.methods.should include(:unset) if RUBY_VERSION >= "1.9.0"
      described_class.methods.should include("unset") if RUBY_VERSION < "1.9.0"
    end
    
    it 'removes tags from a tagged file' do
      path = copy_example_with_tag
      
      described_class.unset(*params_for(path, 'test'))
      described_class.get(*params_for(path)).should_not include('test')
      
      File.unlink(path)
    end
    
    it 'does the right thing when removing an already removed tag' do
      path = copy_example_with_tag
      
      described_class.unset(*params_for(path, 'rspec'))
      described_class.get(*params_for(path)).should eq([ 'test' ])
      
      File.unlink(path)
    end
  end
  
  describe '.clear' do
    it 'exists' do
      described_class.methods.should include(:clear) if RUBY_VERSION >= "1.9.0"
      described_class.methods.should include("clear") if RUBY_VERSION < "1.9.0"
    end
    
    it 'clears tags from tagged files' do
      path = copy_example_with_tag
      
      described_class.clear(*params_for(path))
      described_class.get(*params_for(path)).should be_empty
      
      File.unlink(path)
    end
    
    it 'does not break untagged files' do
      path = copy_example_no_tags
      
      described_class.clear(*params_for(path))
      described_class.get(*params_for(path)).should be_empty
      
      File.unlink(path)
    end
  end
end
