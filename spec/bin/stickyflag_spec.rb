require 'thor'
load File.join(File.dirname(__FILE__), '..', '..', 'bin', 'stickyflag')

describe 'StickyFlag' do  
  describe '.config' do
    context 'without any further parameters' do
      it 'prints out the configuration' do
        run_with_args('config') do |sf|
          sf.should_receive(:dump_config)
        end
      end
    end
    
    context 'with --reset' do
      it 'resets the configuration' do
        run_with_args('config', '--reset') do |sf|
          sf.should_receive(:reset_config!)
        end
      end
    end
    
    context 'with --list' do
      it 'prints out the configuration' do
        run_with_args('config', '--list') do |sf|
          sf.should_receive(:dump_config)
        end
      end
    end
    
    context 'with a key but no value' do
      it 'prints the value for that configuration item' do
        run_with_args('config', '--key', 'root') do |sf|
          sf.set_config :root, "/usr"
          sf.should_receive(:say).with("root: '/usr'")
        end
      end
    end
    
    context 'with a value but no key' do
      it 'raises an error' do
        expect {
          run_with_args('config', 'asdf')
          }.to raise_error
      end
    end
    
    context 'with a key and a value' do
      it 'sets the configuration value' do
        run_with_args('config', '--key', 'root', '/usr') do |sf|
          sf.set_config :root, ''
          sf.should_receive(:set_config).with('root', '/usr')
        end
      end
      
      it 'prints the new value' do
        run_with_args('config', '--key', 'root', '/usr') do |sf|
          sf.set_config :root, ''
          sf.should_receive(:say).with("'root' set to '/usr'")
        end
      end
      
      it "doesn't print out if we're given --quiet" do
        run_with_args('config', '--key', 'root', '/usr', '--quiet') do |sf|
          sf.set_config :root, ''
          sf.should_not_receive(:say)          
        end
      end
    end
  end
  
  describe '.get' do
    
  end
  
  describe '.set' do
    
  end
  
  describe '.unset' do
    
  end
  
  describe '.clear' do
    
  end
  
  describe '.update' do
    
  end
  
  describe '.tags' do
    
  end
  
  describe '.find' do
    
  end
end
