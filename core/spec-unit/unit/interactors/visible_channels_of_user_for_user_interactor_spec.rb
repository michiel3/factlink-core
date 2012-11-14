require 'pavlov_helper'
require File.expand_path('../../../../app/interactors/visible_channels_of_user_for_user_interactor.rb', __FILE__)

describe VisibleChannelsOfUserForUserInteractor do
  include PavlovSupport
  before do
    stub_classes 'Channel'
  end
  describe '.execute' do
    it do
      user = mock
      ch1 = mock
      ch2 = mock
      topic_authority = mock
      containing_channels = mock

      VisibleChannelsOfUserForUserInteractor.any_instance.stub(authorized?: true)
      query = VisibleChannelsOfUserForUserInteractor.new user

      query.stub(
        channels_with_authorities: [[ch1, topic_authority], [ch2, topic_authority]],
        containing_channel_ids: containing_channels
      )

      query.should_receive(:kill_channel).with(ch1, topic_authority, containing_channels, user)
      query.should_receive(:kill_channel).with(ch2, topic_authority, containing_channels, user)
      query.execute
    end
  end

  describe ".channels_with_authorities" do
    it "combines the list of channels with the list of authorities" do
      visible_channels = [mock(:ch1), mock(:ch2)]
      authorities = [mock(:a1), mock(:a2)]

      VisibleChannelsOfUserForUserInteractor.any_instance.stub(authorized?: true)
      interactor = VisibleChannelsOfUserForUserInteractor.new mock
      interactor.stub(visible_channels: visible_channels)

      interactor.should_receive(:query).
                 with(:creator_authorities_for_channels, visible_channels).
                 and_return(authorities)

      result = interactor.channels_with_authorities

      expect(result).to eq [
        [visible_channels[0],authorities[0]],
        [visible_channels[1],authorities[1]]
      ]
    end
  end

  describe ".authorized?" do
    it "initiating raises when the currently ability doesn't enable indexing channels" do
      ability = mock
      ability.should_receive(:can?).with(:index, Channel).and_return(:false)
      expect do
        interactor = VisibleChannelsOfUserForUserInteractor.new mock, ability: ability
      end.not_to raise_error

    end
  end
end
