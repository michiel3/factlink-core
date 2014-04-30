ReactFactlinkFeedSelection = React.createClass
  displayName: 'ReactFeedSelection'
  mixins: [UpdateOnSignInOrOutMixin]

  getInitialState: ->
    feedChoice: 'global'
    feeds:
      global: new GlobalFeedActivities
      personal: new PersonalFeedActivities

  _handleFeedChoiceChange: (e) ->
    if(e.target.checked)
      @setState
        feedChoice: e.target.value

  render: ->
    _div [],
      if currentSession.signedIn()
        _div ['feed-selection-row'],
          _input [ 'radio-toggle-button', type: 'radio', name: 'FeedChoice', value: 'global', id: 'FeedChoice_Global', onChange: @_handleFeedChoiceChange, checked: @state.feedChoice=='global'  ]
          _label [ htmlFor: 'FeedChoice_Global' ],
            'Global'

          _input [ 'radio-toggle-button', type: 'radio', name: 'FeedChoice', value: 'personal', id: 'FeedChoice_Personal', onChange: @_handleFeedChoiceChange, checked: @state.feedChoice=='personal' ]
          _label [ htmlFor: 'FeedChoice_Personal' ],
            'Personal'

          _div ['feed-selection-install-extension-button'],
            ReactInstallExtensionOrBookmarklet()

      ReactFeedActivitiesAutoLoading
        model: @state.feeds[@state.feedChoice]
        key: @state.feedChoice

ReactKennislandFeedSelection = React.createClass
  displayName: 'ReactFeedSelection'
  mixins: [UpdateOnSignInOrOutMixin]

  getInitialState: ->
    feedGroupId: 'global'
    show_create_challenge: false

  _toggle_create_challenge: ->
    @setState show_create_challenge: !@state.show_create_challenge

  addActivity: (activity) ->
    @_currentFeed().unshift activity

  _currentFeed: ->
    if @state.feedGroupId == 'global'
      @_globalActivities ?= new DiscussionsFeedActivities
    else
      @_globalActivities ?= {}
      @_globalActivities[@state.feedGroupId] ?= new GroupActivities [], group_id: @state.feedGroupId

  _groupButtons: ->
    return [] unless currentSession.signedIn()

    currentSession.user().get('groups').map (group) =>
      [
        _input [
          'radio-toggle-button'
          type: 'radio'
          id: "FeedChoice_Group_#{group.id}"
          checked: @state.feedGroupId == group.id
          onChange: => @setState feedGroupId: group.id, show_create_challenge: false
        ]
        _label [htmlFor: "FeedChoice_Group_#{group.id}"],
          group.groupname
      ]

  render: ->
    _div [],
      _div ['feed-selection-row'],
        _input [
          'radio-toggle-button'
          type: 'radio'
          id: 'FeedChoice_Global'
          checked: @state.feedGroupId == 'global'
          onChange: => @setState feedGroupId: 'global', show_create_challenge: false
        ]
        _label [htmlFor: 'FeedChoice_Global'],
          'Public'

        @_groupButtons()...

      (if currentSession.signedIn()
        [
          _div ['feed-selection-row'],
            _button ['button-success feed-selection-install-extension-button', onClick: @_toggle_create_challenge],
              (if !@state.show_create_challenge then "Create challenge" else "Cancel")

          if @state.show_create_challenge
            ReactCreateChallenge
              onActivityCreated: @addActivity
              groupId: @state.feedGroupId
              key: 'create_challenge_' + @state.feedGroupId
        ]
      else [])...

      ReactFeedActivitiesAutoLoading
        model: @_currentFeed()
        key: 'feed_' + @state.feedGroupId

if window.is_kennisland
  window.ReactFeedSelection = ReactKennislandFeedSelection
else
  window.ReactFeedSelection = ReactFactlinkFeedSelection
