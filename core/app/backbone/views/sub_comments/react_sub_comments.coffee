ReactSubCommentsAdd = React.createClass
  getInitialState: ->
    text: ''
    phase: 'new'

  updateText: (e)->
    @setState text: e.target.value

  submit: ->
    return if @state.phase == 'submitting'
    @setState phase: 'submitting'

    model = new SubComment
      content: $.trim(@state.text)
      created_by: currentUser.toJSON()

    if model.isValid()
      @props.addToCollection.add(model)
      model.save {},
        success: =>
          @setState phase: 'new'
          @setState text: ''
        error: =>
          @props.addToCollection.remove(model)
          @setState phase: 'new'
          FactlinkApp.NotificationCenter.error 'Your comment could not be posted, please try again.'
    else
      @setState phase: 'new'
      FactlinkApp.NotificationCenter.error 'Your comment is not valid.'

  render: ->
    submit_button_classes = "button button-confirm button-small spec-submit"
    submit_button =
      if @state.phase == 'new'
        R.button className: submit_button_classes, onClick: @submit,
          Factlink.Global.t.post_subcomment
      else
        R.button className: submit_button_classes, disabled: true,
          'Posting...'

    R.div className: 'sub-comment-add comment-content spec-sub-comments-form',
      R.textarea
        className: "text_area_view",
        placeholder: 'Leave a reply'
        onChange: @updateText
        ref: 'textarea'
        value: @state.text
      submit_button


window.ReactLoadingIndicator = React.createClass
  render: ->
    R.img
      className: 'ajax-loader'
      src: Factlink.Global.ajax_loader_image

window.ReactSubCommentList = React.createBackboneClass
  getInitialState: ->
    loading: true

  componentDidMount: ->
    @model().fetch
      success: => @setState loading: false
    @setState loading: true

  render: ->
    if @model().size() == 0 && @state.loading
      ReactLoadingIndicator()
    else
      R.div className: 'sub-comments',
        @model().map (sub_comment) =>
          ReactSubComment(model: sub_comment)
        ReactSubCommentsAdd(addToCollection: @model())

window.ReactSubComments = React.createClass
  render: ->
    ReactSubCommentList model: @props.model.sub_comments()
