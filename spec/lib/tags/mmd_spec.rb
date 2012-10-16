# -*- encoding : utf-8 -*-
require_relative '../../../lib/tags/mmd'

describe Tags::MMD do
  it_behaves_like 'a tag handler'
  
  it 'handles multiline metadata documents' do
    Tags::MMD.get(example_path('mmd_crazy_keys.mmd')).should include('test')
  end
  
  it 'handles multiline tag documents' do
    Tags::MMD.get(example_path('mmd_crazy_tags.mmd')).should include('sdfg')
  end
  
  it 'handles all-metadata documents' do
    Tags::MMD.get(example_path('mmd_all_meta.mmd')).should be_empty   
  end
  
  it 'can edit multiline metadata documents' do
    path = copy_example('mmd_crazy_keys.mmd')
    
    Tags::MMD.set(path, 'test2')
    Tags::MMD.get(path).should include('test2')
    
    File.open(path, 'r:UTF-8').each_line.to_a.should include("Tags:        test, test2  \n")
    
    File.delete path
  end    
  
  it 'can edit multiline tag documents' do
    path = copy_example('mmd_crazy_tags.mmd')
    
    Tags::MMD.set(path, 'test2')
    Tags::MMD.get(path).should include('test2')
    
    File.open(path, 'r:UTF-8').each_line.to_a.should include("Tags:        asdf, sdfg, dfgh, fghj, qwer, test2  \n")
    
    File.delete path
  end
end
