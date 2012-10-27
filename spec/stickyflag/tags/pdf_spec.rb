# -*- encoding : utf-8 -*-
require 'stickyflag/tags/pdf'
require 'stickyflag/paths'
require 'stickyflag/configuration'
require 'stickyflag/external_cmds'

class GetConfiguration
  include StickyFlag::Paths
  include StickyFlag::Configuration
  include StickyFlag::ExternalCmds
end

describe StickyFlag::Tags::PDF do
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
      expect { StickyFlag::Tags::PDF.get(example_path("pdf_with_tag.pdf"), '/wut/bad') }.to raise_error(Thor::Error)
      expect { StickyFlag::Tags::PDF.clear(example_path("pdf_with_tag.pdf"), '/wut/bad') }.to raise_error(Thor::Error)

      # If get doesn't succeed, we won't get all the way into set or unset
      # with the bad pdftk path.
      StickyFlag::Tags::PDF.stub(:get) { [ 'test' ] }
      expect { StickyFlag::Tags::PDF.set(example_path("pdf_with_tag.pdf"), 'test2', '/wut/bad') }.to raise_error(Thor::Error)
      expect { StickyFlag::Tags::PDF.unset(example_path("pdf_with_tag.pdf"), 'test', '/wut/bad') }.to raise_error(Thor::Error)
      StickyFlag::Tags::PDF.unstub(:get)
    end
  end
end
