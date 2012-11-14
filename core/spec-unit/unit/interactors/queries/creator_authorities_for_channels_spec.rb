require 'pavlov_helper'
require File.expand_path('../../../../../app/interactors/queries/creator_authorities_for_channels.rb', __FILE__)

describe Queries::CreatorAuthoritiesForChannels do
  describe '.query' do
    it 'should retrieve the authority for each channel and return this in a list' do
      channels = [mock, mock]
      channel_authorities = [mock,mock]
      query = Queries::CreatorAuthoritiesForChannels.new channels

      0.upto(1) do |i|
        query.should_receive(:authority_for).with(channels[i]).
              and_return(channel_authorities[i])
      end

      result = query.execute

      expect(result).to eq channel_authorities
    end
  end
  describe '.authority_for' do
    it "should retrieve the topic, and retrieve the authority for the topic" do
      channel = mock
      topic = mock
      topic_authority = mock
      query = Queries::CreatorAuthoritiesForChannels.new mock

      query.should_receive(:topic_for).with(channel).
            and_return(topic)

      query.should_receive(:query).
            with(:authority_on_topic_for,topic).
            and_return(topic_authority)

      result = query.authority_for(channel)

      expect(result).to eq topic_authority
    end
  end
  describe "topic_for" do
    it "should retrieve the topic for the channel, and return it" do
      channel = mock(channel, slug_title: 'mock')
      topic = mock(channel, slug_title: 'mock')
      query = Queries::CreatorAuthoritiesForChannels.new [channel]

      query.should_receive(:topics).and_return([topic])

      result = query.topic_for(channel)

      expect(result).to eq topic
    end
    it "should find the topic with the same slug_title as the channel, and return that one" do
      channel = mock('channel', slug_title: 'channel_slug')
      channel_topic = mock('topic', slug_title: 'channel_slug')

      topics = [
        mock('topic', slug_title: 'some_slug'),
        mock('topic', slug_title: 'some_other_slug'),
        channel_topic,
        mock('topic', slug_title: 'another_slug')
      ]

      query = Queries::CreatorAuthoritiesForChannels.new [channel]
      query.should_receive(:topics).and_return(topics)

      result = query.topic_for(channel)

      expect(result).to eq channel_topic

    end
  end

  describe ".topics" do
    it "should retrieve the topics for all the channels" do
      channels = mock
      topics = mock
      query = Queries::CreatorAuthoritiesForChannels.new channels

      query.should_receive(:query).
            with(:topics_for_channels,channels).
            and_return(topics)

      expect(query.topics).to eq topics
    end
    it "should retrieve the topics once when invoked multiple times" do
      channels = mock
      topics = mock
      query = Queries::CreatorAuthoritiesForChannels.new channels

      query.should_receive(:query).
            with(:topics_for_channels,channels).once.
            and_return(topics)

      expect(query.topics).to eq topics
      expect(query.topics).to eq topics
    end
  end
end
