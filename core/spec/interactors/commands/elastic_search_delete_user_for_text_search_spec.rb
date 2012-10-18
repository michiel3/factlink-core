require_relative '../interactor_spec_helper'
require File.expand_path('../../../../app/interactors/commands/elastic_search_delete_user_for_text_search.rb', __FILE__)

describe Commands::ElasticSearchDeleteUserForTextSearch do
  let(:user) do
    user = stub()
    user.stub id: 1
    user
  end

  before do
    stub_const('HTTParty', Class.new)
    stub_const('FactlinkUI::Application', Class.new)
  end

  it 'intitializes' do
    interactor = Commands::ElasticSearchDeleteUserForTextSearch.new user

    interactor.should_not be_nil
  end

  it 'raises when user is not a User' do
    expect { interactor = Commands::ElasticSearchDeleteUserForTextSearch.new 'User' }.
      to raise_error(RuntimeError, 'user missing fields ([:id]).')
  end

  describe '.execute' do
    it 'correctly' do
      url = 'localhost:9200'
      config = mock()
      config.stub elasticsearch_url: url
      FactlinkUI::Application.stub config: config

      HTTParty.should_receive(:delete).with("http://#{url}/user/#{user.id}")
      interactor = Commands::ElasticSearchDeleteUserForTextSearch.new user

      interactor.execute
    end
  end

end

