class window.Channel extends Backbone.Model
  initialize: (opts) ->
    @on "activate", @setActive
    @on "deactivate", @setNotActive

  setActive: ->
    @isActive = true

  setNotActive: ->
    @isActive = false

  user: ->
    new User(@get("created_by"))

  subchannels: ->
    if @cachedSubchannels
      @cachedSubchannels
    else
      @cachedSubchannels = new SubchannelList(channel: this)
      @cachedSubchannels.fetch()
      @cachedSubchannels

  relatedChannels: ->
    if @cachedRelatedChannels
      @cachedRelatedChannels
    else
      @cachedRelatedChannels = new RelatedChannels [], forChannel: this
      @cachedRelatedChannels.fetch()
      @cachedRelatedChannels



  getOwnContainingChannels: ->
    containingChannels = @get("containing_channel_ids")
    ret = []
    currentUser.channels.each (ch) ->
      ret.push ch  if _.indexOf(containingChannels, ch.id) isnt -1

    ret

  url: ->
    if @collection
      Backbone.Model::url.apply this, arguments
    else
      "/" + @getUsername() + "/channels/" + @get("id")

  getUsername: ->
    @get("created_by")?.username ? @get("username")