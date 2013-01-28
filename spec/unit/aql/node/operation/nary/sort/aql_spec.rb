require 'spec_helper'

describe AQL::Node::Operation::Nary::Sort, '#aql' do

  let(:object) { described_class.new(directions) }

  let(:foo) { AQL::Node::Name.new('foo') }
  let(:bar) { AQL::Node::Name.new('bar') }

  let(:direction_a) { AQL::Node::Operation::Unary::Direction::Ascending.new(foo) }
  let(:direction_b) { AQL::Node::Operation::Unary::Direction::Descending.new(bar) }

  context 'one direction' do
    let(:directions) { [direction_a] }
    let(:expected_aql) { 'SORT foo ASC' }

    it_should_behave_like 'Node#aql'
  end

  context 'two directions' do
    let(:directions) { [direction_a, direction_b] }
    let(:expected_aql) { 'SORT foo ASC, bar DESC' }

    it_should_behave_like 'Node#aql'
  end
end
