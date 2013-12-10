require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/activities/graph_user_ids_following_fact'

describe Queries::Activities::GraphUserIdsFollowingFact do
  include PavlovSupport

  before do
    stub_classes 'Comment'
  end

  describe '#call' do
    it 'returns a unique list of ids' do
      fact = double :fact,
        created_by_id: 1,
        opinionated_users_ids: [2, 3],
        data_id: 133
      fact_relation = double
      comments = double
      query = described_class.new fact: fact

      Comment.stub(:where)
             .with(fact_data_id: fact.data_id)
             .and_return(comments)
      Pavlov.stub(:query)
            .with(:'activities/graph_user_ids_following_comments',
                      comments: comments)
            .and_return([4,5])
      Pavlov.stub(:query)
            .with(:'activities/graph_user_ids_following_fact_relations',
                      fact_relations: [fact_relation])
            .and_return [3, 4]
      Pavlov.stub(:query)
            .with(:'fact_relations/for_fact', fact: fact)
            .and_return [fact_relation]

      expect(query.call).to eq [1, 2, 3, 4, 5]
    end
  end
end
