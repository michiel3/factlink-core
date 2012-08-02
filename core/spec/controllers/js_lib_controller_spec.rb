require 'spec_helper'

describe JsLibController do
  render_views

  describe :show_template do
    it "routes to valid templates" do
      {get: "/templates/_channel_li"}.should route_to controller: 'js_lib', action: 'show_template', name: '_channel_li'
    end

    it "does not route with directory traversal" do
      {get: "/templates/../../../../etc/passwd"}.should_not be_routable
    end

    it "retrieves a valid template" do
      get :show_template, name: '_channel_li'
      response.should be_success
    end

    it "renders the indicator template when not logged in without raising errors" do
      get :show_template, name: 'indicator'
      response.should be_success
    end
  end

end
