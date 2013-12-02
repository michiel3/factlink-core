require 'acceptance_helper'

feature "adding factlinks to a fact", type: :feature do
  include Acceptance
  include Acceptance::FactHelper
  include Acceptance::CommentHelper

  background do
    @user = sign_in_user create :full_user, :confirmed
  end

  let(:factlink) { create :fact, created_by: @user.graph_user }

  scenario "initially the evidence list should be empty" do
    go_to_discussion_page_of factlink


    within_evidence_list do
      expect(all '.evidence-votable', visible: false).to be_empty
    end
  end

  scenario "after adding a piece of evidence, evidence list should contain that item" do
    go_to_discussion_page_of factlink

    supporting_factlink = backend_create_fact

    add_existing_factlink :supporting, supporting_factlink
    sleep 2
    within ".evidence-votable", visible: false do
      page.should have_content supporting_factlink.to_s
    end
  end

  scenario "we can click on evidence to go to the page of that factlink" do
    go_to_discussion_page_of factlink

    supporting_factlink = backend_create_fact

    add_existing_factlink :supporting, supporting_factlink

    find('.evidence-impact-text', text: "0") # wait until request has finished

    find('.evidence-votable span', text: supporting_factlink.to_s).click

    find('.top-fact-text', text: supporting_factlink.to_s)
  end

  scenario "we can click on evidence to go to the page of that factlink in the client" do
    go_to_discussion_page_of factlink

    supporting_factlink = backend_create_fact

    add_existing_factlink :supporting, supporting_factlink

    find('.evidence-impact-text', text: "0") # wait until request has finished

    go_to_fact_show_of factlink

    find('.evidence-votable span', text: supporting_factlink.to_s).click

    find('.top-fact-text', text: supporting_factlink.to_s)
  end

  scenario "after clicking the factwheel, the impact and percentages should update" do
    go_to_discussion_page_of factlink

    supporting_factlink = backend_create_fact

    add_existing_factlink :supporting, supporting_factlink

    within ".evidence-votable", visible: false do
      page.should have_content supporting_factlink.to_s

      find('.evidence-impact-text', text: "0")

      click_wheel_part 0, '.evidence-votable'
      sleep 2

      find('.evidence-impact-text', text: "1")
    end
  end
end
