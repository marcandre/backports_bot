# -*- encoding : utf-8 -*-
require_relative '../../../lib/tags/c'

describe Tags::C do
  it_behaves_like 'a tag handler'
  
  it 'can open a file with all comments and no tags' do
    ret = nil
    expect {
     ret = Tags::C.get(example_path('c_all_comments.c'))
     }.to_not raise_error
   ret.should be_empty
  end
end
