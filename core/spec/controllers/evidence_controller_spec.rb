require 'spec_helper'

describe EvidenceController do
  include Devise::TestHelpers
  render_views

  # TODO factor out, because each controller needs this
  def authenticate_user!
    @user = FactoryGirl.create(:user)
    request.env['warden'] = mock(Warden, :authenticate => @user, :authenticate! => @user)
  end
  
  let (:user) {FactoryGirl.create(:user)}

  let (:f1) {FactoryGirl.create(:fact)}
  let (:f2) {FactoryGirl.create(:fact)}
  let (:f3) {FactoryGirl.create(:fact)}
  
  before do
    f1.add_evidence(:supporting, f2, user)
  end

  describe :index do
    it "should show" do
      get 'index', :fact_id => f1.id, :format => 'json'
      response.should be_succes
    end
    
    it "should show the correct evidence" do
      get 'index', :fact_id => f1.id, :format => 'json'
      parsed_content = JSON.parse(response.body)
      parsed_content[0]["id"].should == f2.id
    end
  end

end