class SubCommentView extends Backbone.Marionette.ItemView
  className: 'evidence-sub-comment'

  template:
    text: """
      <img class="evidence-sub-comments-avatar" src="{{ creator.avatar_url_32 }}" height="32" width="32">
      <div class="evidence-sub-comment-author">
        <strong>
          <a href="/{{ creator.username }}" rel="backbone">{{ creator.username }}</a>
        </strong>
        ( <img src="{{global.brain_image}}"> <span class="evidence-sub-comment-authority">{{ creator.authority }}</span> )
      </div>
      <div class="evidence-sub-comment-content">{{content}}</div>
    """

  templateHelpers: => creator: @model.creator().toJSON()

  initialize: -> @bindTo @model, 'change', @render, @

class SubCommentsListView extends Backbone.Marionette.CollectionView
  className: 'evidence-sub-comments-list'
  itemView: SubCommentView

class SubCommentsAddView extends Backbone.Marionette.Layout
  className: 'evidence-sub-comments-form'

  template:
    text: """
        <div class="js-alert js-alert-error alert alert-error hide">
          Your comment could not be posted, please try again.
          <a class="close" href="#" data-dismiss="alert">x</a>
        </div>

        <img class="evidence-sub-comments-avatar" src="{{ current_user.avatar_url_32 }}" height="32" width="32">
        <div class="js-region-textarea evidence-sub-comments-textarea-container"></div>

        <!-- I don't like this container either, but it was necessary after a weird bug where display: inline-block;
        didn't work on the comment when setting the form to active using Javascript.. -->
        <div class="evidence-sub-comments-button-container">
          <button class="evidence-sub-comments-button btn btn-primary pull-right js-submit">Comment</button>
        </div>
    """

  events:
    'click .js-submit': 'submit'

  regions:
    textareaRegion: '.js-region-textarea'

  templateHelpers: => current_user: currentUser.toJSON()

  onRender: ->
    @textareaRegion.show @textAreaView()
    @toggleForm false

  inputFocus: -> @toggleForm true
  inputBlur: -> @toggleForm false if @text().length <= 0

  toggleForm: (active) ->
    @$el.toggleClass 'evidence-sub-comments-form-active', active

  submit: ->
    @addModel new SubComment
      content: @text()
      created_by: currentUser

  addModelError: -> @alertError()
  addModelSuccess: (model) ->
    @textModel().set 'text', ''
    @alertHide()

  text: -> @textModel().get('text')
  textModel: -> @_textModel ?= new Backbone.Model text: ''
  textAreaView: ->
    textAreaView = new Backbone.Factlink.TextAreaView
      model: @textModel()
      placeholder: 'Comment..'

    @bindTo textAreaView, 'return', @submit, @
    @bindTo textAreaView, 'focus', @inputFocus, @
    @bindTo textAreaView, 'blur', @inputBlur, @
    textAreaView

_.extend SubCommentsAddView.prototype,
  Backbone.Factlink.AddModelToCollectionMixin, Backbone.Factlink.AlertMixin

class window.SubCommentsView extends Backbone.Marionette.Layout
  className: 'evidence-sub-comments'

  template:
    text: """
      <div class="evidence-sub-comments-link"><a class="js-sub-comments-link"></a></div>
      <div class="js-sub-comments-list-container evidence-sub-comments-list-container hide">
        <div class="evidence-sub-comments-arrow"></div>
        <div class="js-region-sub-comments-list"></div>
        <div class="js-region-sub-comments-form"></div>
      </div>
    """

  regions:
    subCommentsListRegion: '.js-region-sub-comments-list'
    subCommentsFormRegion: '.js-region-sub-comments-form'

  events:
    'click .js-sub-comments-link': 'toggleList'

  onRender: ->
    @updateLink()
    # Bind to model change event here when returning a comment count

  toggleList: -> if @listOpen then @closeList() else @openList()

  openList: ->
    @listOpen = true
    @$('.js-sub-comments-list-container').removeClass('hide')

    subComments = new SubComments([], parentModel: @model)
    subComments.fetch update: true # only fires 'add' and 'remove' events

    @bindTo subComments, 'add', => @model.set 'can_destroy?', false
    @bindTo subComments, 'remove', => @model.fetch if subComments.length <= 0

    @subCommentsFormRegion.show new SubCommentsAddView addToCollection: subComments
    @subCommentsListRegion.show new SubCommentsListView collection: subComments

  closeList: ->
    @listOpen = false
    @$('.js-sub-comments-list-container').addClass('hide')
    @subCommentsFormRegion.close()
    @subCommentsListRegion.close()

  updateLink: ->
    @$(".js-sub-comments-link").text "Comments" # Add comment count here
