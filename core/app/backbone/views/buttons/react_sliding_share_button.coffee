ReactCommentFacebookShare = React.createBackboneClass
  displayName: 'ReactCommentFacebookShare'

  render: ->
    _span [
      onClick: @_share
    ],
      _i ["icon-facebook"]

  _description: ->
    left_quote = "\u201C"
    right_quote = "\u201D"

    left_quote + @model().textContent() + right_quote

  _share: ->
    FB.ui
      method: 'feed'
      link: @model().collection.fact.sharingUrl()
      description: @_description()


ReactCommentTwitterShare = React.createBackboneClass
  displayName: 'ReactCommentTwitterShare'

  _link: ->
    url = encodeURIComponent @model().collection.fact.sharingUrl()
    text = encodeURIComponent @model().textContent()

    "https://twitter.com/intent/tweet?url=#{url}&text=#{text}&related=factlink"

  render: ->
    _a [
      href: @_link()
    ],
      _i ["icon-twitter"]

  componentDidMount: ->
    return if Factlink.Global.environment == 'test' # Twitter not loaded in tests

    twttr.widgets.load()


window.ReactSlidingShareButton = React.createBackboneClass
  displayName: 'ReactSlidingShareButton'

  getInitialState: ->
    opened: false

  _toggleButton: -> @setState opened: !@state.opened

  render: ->
    delete_button =
      _span [],
        ReactCommentFacebookShare
          model: @model()
        ReactCommentTwitterShare
          model: @model()

    ReactSlidingButton {slidingChildren: delete_button, opened: @state.opened, right: true},
      _a [onClick: @_toggleButton],
        'Share'
