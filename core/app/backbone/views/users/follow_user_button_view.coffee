class window.FollowUserButtonView extends ActionButtonView
  className: 'user-follow-user-button'

  initialize: ->
    @listenTo @model, 'click:unchecked', @userFollow
    @listenTo @model, 'click:checked', @userUnfollow

    @listenTo currentUser, 'follow_action', @updateStateModel
    @updateStateModel()

    currentUser.following.fetchIfUnloaded()
    @whenFactlinkCollectionFetched currentUser.following, -> @model.set loaded: true

  templateHelpers: =>
    unchecked_label:         Factlink.Global.t.follow_user.capitalize()
    checked_hovered_label:   Factlink.Global.t.unfollow.capitalize()
    checked_unhovered_label: Factlink.Global.t.following.capitalize()

  updateStateModel: ->
    @model.set 'checked', @options.user.followed_by_me()

  userFollow: ->
    @options.user.follow()
    mp_track 'User: Followed',
      followed: following_username

  userUnfollow: ->
    @options.user.unfollow()
    mp_track 'User: Unfollowed',
      unfollowed: following_username
