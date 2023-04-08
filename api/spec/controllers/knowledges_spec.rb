# frozen_string_literal: true

require_relative '../../controllers/knowledges'

RSpec.describe KnowledgesController do
  describe '.split_into_n_parts' do
    let(:input) { 'AAAABBBBCCCCDDDD' }

    it 'splits' do
      expect(described_class.split_into_n_parts(input, 4)).to eq(
        %w[AAAA BBBB CCCC DDDD]
      )

      expect(described_class.split_into_n_parts(input, 4, intersections: true)).to eq(
        %w[AABB BBCC CCDD DD]
      )
    end
  end
end
