# -*- encoding : utf-8 -*-
require 'stickyflag/tags/jpg'

describe StickyFlag::Tags::JPG do
  it_behaves_like 'a tag handler'
  
  it "doesn't get tags that weren't set by stickyflag" do
    StickyFlag::Tags::JPG.get(example_path("jpg_with_tag.jpg")).should_not include('othertag')
  end
  
  it "doesn't unset tags that weren't set by stickyflag" do
    path = copy_example("jpg_with_tag.jpg")
    StickyFlag::Tags::JPG.unset(path, "test")

    image = MiniExiftool.new copy_example("jpg_with_tag.jpg")
    image.should_not be_nil
    
    keywords = image.keywords
    keywords.should_not be_nil

    keywords = [ keywords ] unless keywords.is_a? Array    
    keywords.should include("othertag")
  end
  
  it "doesn't clear tags that weren't set by stickyflag" do
    path = copy_example("jpg_with_tag.jpg")
    StickyFlag::Tags::JPG.clear(path)

    image = MiniExiftool.new copy_example("jpg_with_tag.jpg")
    image.should_not be_nil
    
    keywords = image.keywords
    keywords.should_not be_nil

    keywords = [ keywords ] unless keywords.is_a? Array    
    keywords.should include("othertag")
  end
end
