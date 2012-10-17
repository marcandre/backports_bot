require 'thor'
load File.join(File.dirname(__FILE__), '..', '..', 'bin', 'stickyflag')

def run_with_args(*args)
  StickyFlag.send(:dispatch, nil, args, nil, {}) do |instance|
    # Always stub out load_ and save_config! and database_path, so that we
    # don't tromp on the user's own private data.
    instance.stub(:load_config!) { }
    instance.stub(:save_config!) { }
    instance.stub(:database_path) { ":memory:" }
    
    yield instance if block_given?
  end
end
