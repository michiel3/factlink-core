require 'spec_helper'

describe CreatedFactsController do
  render_views

  let (:user) { create :user }

  it "facts json should stay the same" do
    # not doing the whole time cop thing, since the dates in the
    # timestamped set are generated by redis (This is: Jan's guess (TM))
    FactoryGirl.reload

    facts = create_list :fact, 3, created_by: user.graph_user
    channel = create :channel, created_by: user.graph_user

    facts.each do |f|
      Interactors::Channels::AddFact.new(fact: f, channel: channel, pavlov_options: { no_current_user: true }).call
    end

    authenticate_user!(user)

    get :index, username: user.username, format: :json

    Approvals.verify(response.body, format: :json, name: 'channels#facts should keep the same content')
  end

end
