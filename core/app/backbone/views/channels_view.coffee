class ChannelItemView extends Backbone.Marionette.ItemView
  tagName: "li"

  template: "channels/_single_menu_item"

  initialize: () ->
    @addClassToggle('active')

    @model.bind('activate', @activeOn, this)
    @model.bind('deactivate', @activeOff, this)
    @model.bind('change',@render,this)

  onRender: () ->
    @$el.attr('id', 'channel-' + @model.id)
    @activeOn() if @model.isActive

_.extend ChannelItemView.prototype, ToggleMixin

class window.ChannelHeaderView extends Backbone.Marionette.ItemView
  tagName: "ul"
  className: "channel-listing"

  template: 'channels/list_header'

  initialize: =>
    @on 'activate', => @$('li.stream').addClass('active')

class window.ChannelListView extends Backbone.Marionette.CollectionView
  itemView: ChannelItemView
  tagName: 'ul'
  id: 'channel-listing'
  className: 'channel-listing'

class window.ChannelsView extends Backbone.Marionette.Layout
  template: 'channels/channel_list'

  regions:
    list:   '.channel-listing-container'
    header: '.channel-listing-header'

  initialEvents: -> false # stop layout from refreshing after model/collection update
                    # no longer needed in marionette 1.0

  onRender: ->
    @list.show new ChannelListView(collection: @collection)
    @header.show getTextView('moi')

  setActiveChannel: (channel)->
    @collection.setActiveChannel(channel)
