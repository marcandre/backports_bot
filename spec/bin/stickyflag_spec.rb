require 'thor'
load File.join(File.dirname(__FILE__), '..', '..', 'bin', 'stickyflag')

describe 'StickyFlag' do  
  describe '#config' do
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

      it 'prints out the configuration with --quiet' do
        run_with_args('config', '--list', '--quiet') do |sf|
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
  
  describe '#get' do
    context 'with no arguments' do
      it 'raises an error' do
        expect {
          run_with_args('get')
          }.to raise_error
      end
    end
    
    context 'with a missing file' do
      it 'prints an error message' do
        run_with_args('get', 'bad.pdf') do |sf|
          sf.should_receive(:say_status).with(:error, /bad\.pdf/, kind_of(Symbol))
        end
      end
      
      it 'does not print an error message with --quiet' do
        run_with_args('get', 'bad.pdf', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
      
      it 'does not print an error message with --force' do
        run_with_args('get', 'bad.pdf', '--force') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a file without tags' do
      it 'prints a no-tags message' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'c_no_tags.c')) do |sf|
          sf.should_receive(:say).with(/.*c_no_tags.c: no tags/)
        end
      end
      
      it 'does not print a no-tags message with --quiet' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'c_no_tags.c'), '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end

      it 'does not print a no-tags message with --force' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'c_no_tags.c'), '--force') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a file with tags' do
      it 'prints the tags' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd')) do |sf|
          sf.should_receive(:say).with(/ asdf, /)
        end
      end
      
      it 'prints the tags with --quiet' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd'), '--quiet') do |sf|
          sf.should_receive(:say).with(/ asdf, /)
        end        
      end

      it 'prints the tags with --force' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd'), '--force') do |sf|
          sf.should_receive(:say).with(/ asdf, /)
        end        
      end
    end
    
    context 'with multiple files with tags' do
      it 'prints all the files' do
        run_with_args('get', File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'mmd_crazy_tags.mmd'), File.join(File.dirname(__FILE__), '..', 'support', 'examples', 'c_with_tag.c')) do |sf|
          sf.should_receive(:say).with(/mmd_crazy_tags\.mmd/)
          sf.should_receive(:say).with(/c_with_tag\.c/)
        end
      end
    end
  end
  
  describe '#set' do
    context 'with no parameters' do
      it 'raises an error' do
        expect {
          run_with_args('set')
          }.to raise_error
      end
    end
    
    context 'with just a file' do
      it 'raises an error' do
        expect {
          run_with_args('set', 'bad.pdf')
          }.to raise_error
      end
    end
    
    context 'with a good file and an invalid tag' do
      it 'raises an error' do
        expect {
          run_with_args('set', __FILE__, 'asdf,asdf')
          }.to raise_error
      end
      
      it 'also raises on blank tags' do
        expect {
          run_with_args('set', __FILE__, '')
          }.to raise_error
      end
    end
    
    context 'with a missing file and a good tag' do
      it 'prints an error message' do
        run_with_args('set', 'bad.pdf', 'asdf') do |sf|
          sf.should_receive(:say_status).with(:error, /bad\.pdf/, :red)
        end
      end
      
      it 'does not print an error message with --quiet' do
        run_with_args('set', 'bad.pdf', 'asdf', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a good file and a good tag' do
      before(:each) do
        @path = copy_example('c_with_tag.c').to_s
      end
      after(:each) do
        File.unlink(@path)
      end
      
      it 'sets the tags' do
        run_with_args('set', @path, 'test2')
        run_with_args('get', @path) do |sf|
          sf.should_receive(:say).with(/ test2/)
        end
      end
      
      it 'prints all the tags' do
        run_with_args('set', @path, 'test2') do |sf|
          sf.should_receive(:say_status).with(:success, /: test, test2/, :green)
        end
      end
      
      it 'prints nothing with --quiet' do
        run_with_args('set', @path, 'test2', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
  end
  
  describe '#unset' do
    context 'with no parameters' do
      it 'raises an error' do
        expect {
          run_with_args('unset')
          }.to raise_error
      end
    end
    
    context 'with just a file' do
      it 'raises an error' do
        expect {
          run_with_args('unset', 'bad.pdf')
          }.to raise_error
      end
    end
    
    context 'with a good file and an invalid tag' do
      it 'raises an error' do
        expect {
          run_with_args('unset', __FILE__, 'asdf,asdf')
          }.to raise_error
      end
    end
    
    context 'with a missing file and a good tag' do
      it 'prints an error message' do
        run_with_args('unset', 'bad.pdf', 'asdf') do |sf|
          sf.should_receive(:say_status).with(:error, /bad\.pdf/, :red)
        end
      end
      
      it 'does not print an error message with --quiet' do
        run_with_args('unset', 'bad.pdf', 'asdf', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a good file and a good tag' do
      before(:each) do
        @path = copy_example('c_with_tag.c').to_s
      end
      after(:each) do
        File.unlink(@path)
      end
      
      it 'sets the tags' do
        run_with_args('unset', @path, 'test')
        run_with_args('get', @path) do |sf|
          sf.should_receive(:say).with(/ no tags/)
        end
      end
      
      it 'prints no tags' do
        run_with_args('unset', @path, 'test') do |sf|
          sf.should_receive(:say_status).with(:success, /: no tags/, :green)
        end
      end
      
      it 'prints nothing with --quiet' do
        run_with_args('unset', @path, 'test', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a file with multiple tags' do
      before(:each) do
        @path = copy_example('mmd_crazy_tags.mmd').to_s
      end
      after(:each) do
        File.unlink(@path)
      end
      
      it 'prints the remaining tags' do
        run_with_args('unset', @path, 'asdf') do |sf|
          sf.should_receive(:say_status).with(:success, /: sdfg/, :green)
        end
      end
    end
  end
  
  describe '#clear' do
    context 'with no parameters' do
      it 'raises an error' do
        expect {
          run_with_args('clear')
          }.to raise_error
      end
    end
    
    context 'with a missing file' do
      it 'prints an error message' do
        run_with_args('clear', 'bad.pdf') do |sf|
          sf.should_receive(:say_status).with(:error, /bad\.pdf/, :red)
        end
      end
      
      it 'does not print an error message with --quiet' do
        run_with_args('clear', 'bad.pdf', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end

      it 'does not print an error message with --force' do
        run_with_args('clear', 'bad.pdf', '--force') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a good file' do
      before(:each) do
        @path = copy_example('c_with_tag.c').to_s
      end
      after(:each) do
        File.unlink(@path)
      end
      
      it 'clears the tags' do
        run_with_args('clear', @path)
        run_with_args('get', @path) do |sf|
          sf.should_receive(:say).with(/ no tags/)
        end
      end
      
      it 'prints a success message' do
        run_with_args('clear', @path) do |sf|
          sf.should_receive(:say_status).with(:success, /Tags cleared for /, :green)
        end
      end
      
      it 'prints nothing with --quiet' do
        run_with_args('unset', @path, 'test', '--quiet') do |sf|
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
  end
  
  describe '#update' do
    it 'updates in the current directory by default' do
      run_with_args('update') do |sf|
        sf.set_config(:root, '')
        sf.should_receive(:update_database_from_files).with('.')
      end
    end
    
    it 'updates from the configured root dir' do
      run_with_args('update') do |sf|
        sf.set_config(:root, '/usr/')
        sf.should_receive(:update_database_from_files).with('/usr/')
      end
    end
  end
  
  describe '#tags' do
    context 'with --quiet' do
      it 'just prints all the tags, with no padding' do
        run_with_args('tags', '--quiet') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_receive(:say).with('asdf').once
          sf.should_receive(:say).with(kind_of(String)).any_number_of_times
        end
      end
    end
    
    context 'without --quiet' do
      it 'prints an intro message and padded tags' do
        run_with_args('tags') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_receive(:say).with('Tags currently in use:').once
          sf.should_receive(:say).with(/ ?test/).once
          sf.should_receive(:say).with(kind_of(String)).any_number_of_times
        end
      end
    end
  end
  
  describe '#find' do
    context 'with no tags' do
      it 'raises an error' do
        expect {
          run_with_args('find')
          }.to raise_error
      end
    end
    
    context 'with an invalid tag' do
      it 'raises an error' do
        expect {
          run_with_args('find', 'asdf,wut')
          }.to raise_error
      end
    end
    
    context 'with a missing tag' do
      it 'prints a warning message' do
        run_with_args('find', 'zuzzax') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_receive(:say_status).with(:warning, /not present/, :yellow)
        end
      end
      
      it 'prints nothing with --quiet' do
        run_with_args('find', 'zuzzax', '--quiet') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a bad boolean combo' do
      it 'prints a warning message' do
        run_with_args('find', 'test', 'asdf') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_receive(:say_status).with(:warning, /not found/, :yellow)
        end
      end
      
      it 'prints nothing with --quiet' do
        run_with_args('find', 'test', 'asdf', '--quiet') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_not_receive(:say)
          sf.should_not_receive(:say_status)
        end
      end
    end
    
    context 'with a good tag' do
      it 'prints some filenames' do
        run_with_args('find', 'test') do |sf|
          sf.update_database_from_files File.join(File.dirname(__FILE__), '..')
          sf.should_receive(:say).with(/#{File.join(File.dirname(__FILE__), '..')}/).at_least(:once)
        end
      end
    end
  end
end
