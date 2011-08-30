module ChannelsHelper
  
  def fork_label(channel)
      return "add to my channels"
  end

  def channel_listing_for_user(channels, user)
    render :partial => "home/snippets/channels", 
	            :locals => {  :channels => channels,
	                          :user => user }
  end
  
  def channel_snippet(channel, user)
    render :partial => "home/snippets/channel_menu_item", 
	            :locals => {  :channel => channel,
	                          :user => user }
  end

  def single_channel_snippet(channel, user)
    render :partial => "home/snippets/channel_li", 
	            :locals => {  :channel => channel,
	                          :user => user }
  end
  
end
