# -*- encoding : utf-8 -*-
require 'thor'
require 'stickyflag'

class DatabaseHelper
  def database_path
    ":memory:"
  end
  
  include StickyFlag::Database
end

def run_with_args(*args)
  # We want to load an in-memory database ourselves, so that we can tear it
  # down in this function (there's nowhere to hook in Thor for after the
  # task is completed)
  dbh = DatabaseHelper.new
  dbh.load_database
  database = dbh.instance_variable_get(:@database)
  
  StickyFlag::ThorApp.send(:dispatch, nil, args, nil, {}) do |instance|
    # Always stub out load_ and save_config! and database_path, so that we
    # don't tromp on the user's own private data.
    instance.stub(:load_config!) { }
    instance.stub(:save_config!) { }
    
    # Patch in the new database
    instance.instance_variable_set(:@database, database)
    instance.create_tables
    
    yield instance if block_given?
  end
  
  # Clean up
  database.disconnect
end
