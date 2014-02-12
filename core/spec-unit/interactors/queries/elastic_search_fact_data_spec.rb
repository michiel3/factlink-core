require 'pavlov_helper'
require_relative '../../../app/interactors/queries/elastic_search_fact_data.rb'

describe Queries::ElasticSearchFactData do
  include PavlovSupport

  before do
    stub_classes 'HTTParty', 'FactData', 'FactlinkUI::Application', 'Queries::Facts::GetDead'
  end

  it 'raises when initialized with an empty keywords string' do
    expect { described_class.new(keywords: '', page: 1, row_count: 20).call }
      .to raise_error(RuntimeError, 'Keywords must not be empty')
  end

  describe '#call' do
    it 'executes correctly with return value of FactData class' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = 'searching for evidence'
      wildcard_keywords = '(searching*+OR+searching)+AND+(for*+OR+for)+AND+(evidence*+OR+evidence)'
      query = described_class.new keywords: keywords,
                                  page: 1, row_count: 20
      hit = double
      results = double
      return_object = double

      hit.should_receive(:[]).with('_id').and_return(1)
      hit.should_receive(:[]).with('_type').and_return('factdata')
      results.stub parsed_response: { 'hits' => { 'hits' => [ hit ] } }
      results.stub code: 200

      HTTParty.should_receive(:get).
        with("http://#{base_url}/factdata/_search?q=#{wildcard_keywords}&from=0&size=20&analyze_wildcard=true").
        and_return(results)

      fd = double fact_id: 1
      FactData.stub(:find).with(1).and_return(fd)
      get_dead_fact = double call: return_object
      Queries::Facts::GetDead.stub(:new).with(id: fd.fact_id).and_return(get_dead_fact)
      FactData.should_receive(:find).with(1).and_return(fd)

      expect(query.call).to eq [return_object]
    end

    it 'logs and raises an error when HTTParty returns a non 2xx status code.' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = 'searching for this channel'
      error_response = 'error has happened server side'
      results = double response: error_response, code: 501
      HTTParty.stub get: results
      error_message = "Server error, status code: 501, response: '#{error_response}'."
      query = described_class.new(keywords: keywords, page: 1, row_count: 20)

      expect { query.call }.to raise_error(RuntimeError, error_message)
    end

    it 'url encodes keywords' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = '$+,:; @=?&=/'
      wildcard_keywords = '($%5C+,%5C:;*+OR+$%5C+,%5C:;)+AND+(@=%5C?&=/*+OR+@=%5C?&=/)'
      query = described_class.new keywords: keywords, page: 1, row_count: 20
      return_object = double
      hit = double
      results = double

      hit.stub(:[]).with('_id').and_return(1)
      hit.stub(:[]).with('_type').and_return('factdata')

      results.stub parsed_response: { 'hits' => { 'hits' => [ hit ] } }
      results.stub code: 200

      HTTParty.stub(:get)
        .with("http://#{base_url}/factdata/_search?q=#{wildcard_keywords}&from=0&size=20&analyze_wildcard=true")
        .and_return(results)

      fd = double fact_id: 1
      FactData.stub(:find).with(1).and_return(fd)
      get_dead_fact = double call: return_object
      Queries::Facts::GetDead.stub(:new).with(id: fd.fact_id).and_return(get_dead_fact)

      expect(query.call).to eq [return_object]
    end
  end
end
