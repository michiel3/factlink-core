require 'pavlov_helper'
require_relative '../../../../app/interactors/commands/topics/unfavourite'

describe Commands::Topics::Unfavourite do
  include PavlovSupport

  describe '#execute' do
    before do
      described_class.any_instance.stub validate: true
      stub_classes 'UserFavouritedTopics'
    end

    it 'calls UserFavouritedTopics.unfavourite to unfavourite the topic' do
      graph_user_id = double
      topic_id = double
      users_favourited_topics = double

      UserFavouritedTopics.stub(:new)
                        .with(graph_user_id)
                        .and_return(users_favourited_topics)

      users_favourited_topics.should_receive(:unfavourite)
                           .with(topic_id)

      query = described_class.new graph_user_id: graph_user_id,
        topic_id: topic_id

      query.execute
    end
  end
end
