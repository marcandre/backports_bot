# -*- encoding : utf-8 -*-
require_relative '../../../lib/tags/pdf'
require_relative '../../../lib/paths'
require_relative '../../../lib/configuration'
require_relative '../../../lib/external_cmds'

class GetConfiguration
  include Paths
  include Configuration
  include ExternalCmds
end

describe Tags::PDF do
  it_behaves_like 'a tag handler' do
    let(:params) {
      config = GetConfiguration.new
      config.stub(:load_config!) { }
      config.stub(:save_config!) { }

      config.find_external_cmds
      
      [ config.get_config(:pdftk_path) ]
    }
  end
end
