module Acceptance
  module CommentHelper
      def open_search_factlink
        return if all('.spec-open-search-facts-link').empty?

        page.find('.spec-open-search-facts-link').click
      end

      def fill_in_comment_textarea text, original_text:''
        within '.spec-add-comment-form' do
          comment_input = find('.text_area_view')
          comment_input.click

          comment_input = find('.text_area_view')
          comment_input.value.should eq original_text
          comment_input.click
          comment_input.set text
          comment_input.value.should eq text
        end
      end

      def add_comment text
        fill_in_comment_textarea text

        within '.spec-add-comment-form' do
          click_button "Post"
        end

        wait_until_comment_has_one_vote text
      end

      def add_existing_factlink text

        open_search_factlink

        within '.spec-add-comment-form' do
          comment_input = find('.text_area_view')
          comment_input.click

          # Open search by entering something
          comment_input.set 'something'
          comment_input.set ''
          open_search_factlink

          page.find("input[type=text]").click
          page.find("input[type=text]").set(text)
          page.find(".spec-fact-search-result", text: text).click

          click_button "Post"
        end

        wait_until_comment_has_one_vote text
      end

      def wait_until_comment_has_one_vote text
        page.find('.comment-container', text: text).find('.spec-comment-vote-amount', text: 1)
      end

      def add_sub_comment(comment)
        find('.spec-sub-comments-form .text_area_view').set comment
        find('.spec-sub-comments-form .text_area_view').value.should eq comment
        find('.spec-sub-comments-form .spec-submit').click
        find('.spec-sub-comments-form .text_area_view').value.should eq ''
      end

      def assert_sub_comment_exists(comment)
        find('.spec-subcomment-content', text: comment)
      end

      def assert_comment_exists comment
        find('.spec-comment-content', text: comment)
      end

      def vote_comment direction, comment
        within('.comment-container', text: comment, visible: false) do
          find(".spec-comment-vote-#{direction}").click
        end
      end
  end
end
