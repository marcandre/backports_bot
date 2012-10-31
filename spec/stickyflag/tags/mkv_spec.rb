# -*- encoding : utf-8 -*-
require 'stickyflag/tags/mkv'
require 'stickyflag/paths'
require 'stickyflag/configuration'
require 'stickyflag/external_cmds'

class GetConfiguration
  include StickyFlag::Paths
  include StickyFlag::Configuration
  include StickyFlag::ExternalCmds
end

describe StickyFlag::Tags::MKV do
  before(:each) do
    config = GetConfiguration.new
    config.stub(:load_config!) { }
    config.stub(:save_config!) { }

    config.find_external_cmds
    
    @mkve = config.get_config(:mkvextract_path)
    @mkvp = config.get_config(:mkvpropedit_path)
  end
  
  it_behaves_like 'a tag handler' do
    let(:params) {
      [ @mkve, @mkvp ]
    }
  end
  
  context 'when we set our own tag' do
    it "doesn't wipe out other tags set on the file" do
      path = copy_example("mkv_with_tag.mkv")
      StickyFlag::Tags::MKV.set(path, 'test2', @mkve, @mkvp)
      
      # This is an internal method, but it's too useful not to use
      xml_doc = StickyFlag::Tags::MKV.get_tag_xml(path, @mkve, @mkvp)
      
      # This is one of the original tags on the file
      tag = xml_doc.at_xpath("/Tags/Tag[Targets[TargetTypeValue = '50']]/Simple[Name = 'TITLE']")
      tag.should_not be_nil
      tag.at_xpath("String").content.should eq('Big Buck Bunny - test 1')
    end
  end
  
  context 'with bad mkv utility paths' do
    it 'raises errors for everything' do
      expect { StickyFlag::Tags::MKV.get(example_path("mkv_with_tag.mkv"), '/wut/bad', '/wut/no') }.to raise_error(Thor::Error)
      expect { StickyFlag::Tags::MKV.clear(example_path("mkv_with_tag.mkv"), '/wut/bad', '/wut/no') }.to raise_error(Thor::Error)
      expect { StickyFlag::Tags::MKV.set(example_path("mkv_with_tag.mkv"), 'test2', '/wut/bad', '/wut/no') }.to raise_error(Thor::Error)
      expect { StickyFlag::Tags::MKV.unset(example_path("mkv_with_tag.mkv"), 'test', '/wut/bad', '/wut/no') }.to raise_error(Thor::Error)
    end
  end
end
