require 'spec_helper'

describe OpinionatorsController do
  include PavlovSupport

  render_views

  let(:user) { create(:user) }

  describe :index do
    it "should keep the same content" do
      FactoryGirl.reload

      fact = create :fact

      fact.add_opiniated :believes, (create :user).graph_user
      2.times do
        fact.add_opiniated :disbelieves, (create :user).graph_user
      end

      get :index, fact_id: fact.id

      Approvals.verify(response.body, format: :json, name: 'opinionators#index should keep the same content')
    end
  end
end