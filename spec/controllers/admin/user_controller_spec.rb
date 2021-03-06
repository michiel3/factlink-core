require 'spec_helper'

describe Admin::UsersController do
  render_views

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      username: "test_user",
      full_name: "Test User",
      email: "test@mail.nl",
      password: "test123",
      password_confirmation: "test123"
    }
  end

  let (:user)  {create :user, :admin }

  before do
    should_check_admin_ability

    @user1 = create :user
    @user2 = create :user
  end

  describe "GET index" do
    it "should render the index" do
      authenticate_user!(user)
      should_check_can :index, User
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do

      authenticate_user!(user)
      should_check_can :show, @user1

      get :show, {:id => @user1.id}
      response.should be_success
      assigns(:user).should eq(@user1)
    end
  end
end
