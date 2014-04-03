module Acceptance
  module FactHelper
    def open_discussion_sidebar_for fact_id
      visit '/client/blank'
      find('.spec-discussion-sidebar-region')
      page.execute_script "clientEnvoy.showFactlink(#{fact_id})"
      find('.spec-button-interesting')
    end

    def backend_create_fact_with_long_text
      create :fact_data, displaystring: 'long'*30
    end
  end
end
