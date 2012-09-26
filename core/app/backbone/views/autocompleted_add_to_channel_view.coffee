#TODO: check if this hide-input class thingy has some importance

updateWindowHeight = ->  window.updateHeight() if window.updateHeight

class window.AutoCompletedAddToChannelView extends Backbone.Marionette.Layout
  tagName: "div"
  className: "add-to-channel"
  events:
    "keydown input.typeahead": "parseKeyDown"
    "keyup input.typeahead": "autoComplete"
    "focus input.typeahead": "onFocusInput"
    "click div.fake-input": "focusInput"
    "click div.auto_complete": "addCurrentlySelectedChannel"
    "click div.fake-input a": "addCurrentlySelectedChannel"
    "blur input.typeahead": "blurInput"
    "click .show-input-button": "showInput"
    "mouseenter .auto_complete>div": "selectAddNew"
    "mouseleave .auto_complete>div": "deActivateAddNew"

  regions:
    'added_channels': 'div.added_channels_container'
    'auto_completes': 'div.auto_complete_container'

  activeChannelKey: -> @_activeChannelKey

  setActiveChannelKey: (value) -> @_activeChannelKey = value

  template: "channels/_auto_completed_add_to_channel"

  initialize: ->
    @vent = new Backbone.Marionette.EventAggregator()
    @collection = new OwnChannelCollection()
    @_added_channels_view = new AutoCompletedAddedChannelsView(
      collection: @collection
      mainView: this
    )
    @_auto_completes_view = new AutoCompletesView(
      mainView: this
      alreadyAdded: @collection
    )

  onRender: ->
    @$(".auto_complete ul").preventScrollPropagation()

    @added_channels.show(@_added_channels_view)
    @auto_completes.show(@_auto_completes_view)

    updateWindowHeight()

  parseKeyDown: (e) ->
    @_proceed = false
    switch e.keyCode
      when 13 then @addCurrentlySelectedChannel e
      when 40
        @_auto_completes_view.moveSelectionDown e
        e.preventDefault()
      when 38
        @_auto_completes_view.moveSelectionUp
        e.preventDefault()
      when 27 then @completelyDisappear()
      else @_proceed = true

  showInput: -> @$el.removeClass("hide-input").find(".fake-input input").focus()

  focusInput: -> @$("input.typeahead").focus()
  onFocusInput: -> @$el.addClass "focus"
  blurInput: -> @$el.removeClass "focus"

  deActivateCurrent: ->
    @_auto_completes_view.deActivateCurrent()
    @deActivateAddNew()

  setActiveAutoComplete: (key, scroll) ->
    @_auto_completes_view.setActiveAutoComplete key, scroll

  selectAddNew: ->
    return false  unless @isAddNewVisible()
    @deActivateAutoCompleteView()  if typeof @activeChannelKey() is "number"
    @activateAddNew()

  activateAddNew: -> @$(".auto_complete>div").addClass "active"
  deActivateAddNew: -> @$(".auto_complete>div").removeClass "active"
  isAddNewActive: -> @$(".auto_complete>div").hasClass "active"

  activateAutoCompleteView: (view) ->
    @setActiveAutoComplete @_auto_completes_view.list.indexOf(view)

  deActivateAutoCompleteView: ->
    activeview = @_auto_completes_view.list[@activeChannelKey()]
    activeview.trigger "deactivate"  if activeview isnt `undefined`
    @setActiveChannelKey `undefined`

  addCurrentlySelectedChannel: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @disable()
    if 0 <= @activeChannelKey() < @_auto_completes_view.list.length
      selected = @_auto_completes_view.list[@activeChannelKey()].model
      @$("input.typeahead").val selected.get("title")
      if selected.get("user_channel")
        @addNewChannel selected.get("user_channel")
        return
    @createNewChannel e

  isDupe: (title) -> @collection.where(title: title).length > 0

  completelyDisappear: ->
    @enable()
    @clearInput()

  createNewChannel: (e) ->
    title = @$("input.typeahead").val()
    title = $.trim(title)
    dupe = false
    if (title.length < 1) or (@isDupe(title))
      @completelyDisappear()
      return
    to_create_user_channels = @_auto_completes_view.collection.filter((item) ->
      item.get("title") is title and item.get("user_channel")
    )
    if to_create_user_channels.length > 0
      @addNewChannel to_create_user_channels[0].get("user_channel")
      return
    $.ajax(
      url: "/" + currentUser.get("username") + "/channels"
      data:
        title: title

      type: "POST"
    ).done _.bind(@addNewChannel, this)
    e.preventDefault()

  addNewChannel: (channel) ->
    channel = new Channel(channel)
    currentUser.channels.add channel
    @vent.trigger "addChannel", channel
    @collection.add channel
    @completelyDisappear()

  clearInput: ->
    @$("input.typeahead").val ""
    @$el.addClass "hide-input"  if @collection.length

  disable: ->
    @$el.addClass("disabled").find("input.typeahead").prop "disabled", true
    @$(".btn").addClass "disabled"

  enable: ->
    @$el.removeClass("disabled").find("input.typeahead").prop "disabled", false
    @$(".btn").removeClass "disabled"


  updateText: ->
    value = @$el.find("input.typeahead").val()
    if value.length
      @$el.addClass "has-text"
      @$(".search").text value
    else
      @$el.removeClass "has-text"

  autoComplete: _.debounce(->
    searchValue = @$("input.typeahead").val()
    @updateText()

    return  if @_lastKnownSearchValue is searchValue or not @_proceed

    @_lastKnownSearchValue = searchValue
    @setActiveChannelKey `undefined`


    @clearAutoComplete()

    return if searchValue.length < 1


    @_auto_completes_view.search_collection.setSearch searchValue
    @_auto_completes_view.search_collection.fetch success: =>
      @setActiveAutoComplete 0, false
      updateWindowHeight()
  , 300)

  hideAddNew: -> @$el.addClass "hide-add-new"
  showAddNew: -> @$el.removeClass "hide-add-new"
  isAddNewVisible: -> not @$el.hasClass("hide-add-new")

  clearAutoComplete: ->
    @_auto_completes_view.closeList()
    @_auto_completes_view.search_collection.reset []
    @$(".auto_complete").addClass "empty"
    @deActivateAddNew()
    @showAddNew()