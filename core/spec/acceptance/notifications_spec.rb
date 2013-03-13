require 'acceptance_helper'

feature "notifications", type: :request do
  include Acceptance::ChannelHelper
  include Acceptance::NotificationHelper
  include Acceptance::NavigationHelper
  include Acceptance::AddToChannelModalHelper

  scenario %q{When another user follows my channel,
            I get a notification, and can click on it,
            to go to the following channel} do
    current_user = create :active_user
    other_user = create :active_user

    other_users_channel =
      backend_create_viewable_channel_for other_user
    my_channel =
      backend_create_viewable_channel_for current_user

    backend_channel_add_subchannel other_users_channel, my_channel

    sign_in_user current_user

    assert_number_of_unread_notifications 1
    open_notifications
    click_on_nth_notification 1
    assert_on_channel_page other_users_channel.title
  end


  scenario %q{When another user follows my channel,
            I get a notification, and directly follow
            back their channel from the notification} do
    current_user = create :active_user
    other_user = create :active_user

    other_users_channel =
      backend_create_viewable_channel_for other_user
    my_channel =
      backend_create_viewable_channel_for current_user

    backend_channel_add_subchannel other_users_channel, my_channel

    sign_in_user current_user

    assert_number_of_unread_notifications 1
    open_notifications

    within_nth_notification 1 do
      click_button "follow"
    end

    within_nth_notification 1 do
      find('button', text: 'following')
    end

    sleep 2 # give ajax requests some time to finish

    visit page.current_url

    open_notifications
    within_nth_notification 1 do
      find('button', text: 'following')
    end
  end
end
