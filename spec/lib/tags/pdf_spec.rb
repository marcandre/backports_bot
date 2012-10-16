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
  
  context 'with a bad pdftk path' do
    it 'raises errors for everything' do
      expect { Tags::PDF.get(example_path("pdf_with_tag.pdf"), '/wut/bad') }.to raise_error(Thor::Error)
      expect { Tags::PDF.clear(example_path("pdf_with_tag.pdf"), '/wut/bad') }.to raise_error(Thor::Error)

      # If get doesn't succeed, we won't get all the way into set or unset
      # with the bad pdftk path.
      Tags::PDF.stub(:get) { [ 'test' ] }
      expect { Tags::PDF.set(example_path("pdf_with_tag.pdf"), 'test2', '/wut/bad') }.to raise_error(Thor::Error)
      expect { Tags::PDF.unset(example_path("pdf_with_tag.pdf"), 'test', '/wut/bad') }.to raise_error(Thor::Error)
      Tags::PDF.unstub(:get)
    end
  end
end
