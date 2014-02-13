class window.ActivitiesGroupView extends Backbone.Marionette.CompositeView
  @new: (options)->
    new (@classForModel(options.model))(options)

  @classForModel: (model) ->
    action = model.get("action")

    specialized_group_views = [
      UserFactActivitiesGroupView,
      UsersFollowedGroupView
    ]

    for group_view in specialized_group_views
      if action in group_view.actions
        return group_view

    return UserActivitiesGroupView

  templateHelpers: ->
    user: @user?.toJSON()

  constructor: (options) ->
    options.collection = new Backbone.Collection [options.model]
    super(options)
    @user = new User @collection.first().get('user')

  actions: -> []

  appendable: (model) -> model.get('action') in @actions()

  tryAppend: (model) ->
    return false unless @appendable(model)
    @append model
    true

  append: (model) ->
    unless @lastView?.tryAppend(model)
      @collection.add model

class UserActivitiesGroupView extends ActivitiesGroupView
  className: 'activity-group'
  itemView: Backbone.View
  itemViewContainer: ".js-region-activities"

  constructor: ->
    super
    @on 'render', @makeUserTooltip

  itemViewOptions: ->
    $offsetParent: @$el

  sameUser: (model) -> @model.user().get('username') == model.user().get('username')

  appendable: (model) -> super(model) and @sameUser(model)

  buildItemView: (item, ItemView, itemViewOptions) ->
    options = _.extend({model: item}, itemViewOptions)
    @lastView = ActivityItemView.for(options)

  activityMadeRedundantBy: (newActivity, oldActivity) -> false
  newActivityIsRedundant: (newActivity) ->
    return false unless @collection.models.length > 1
    @activityMadeRedundantBy newActivity,
      @collection.models[@collection.length - 2]

  appendHtml: (collectionView, itemView, index) ->
    return if @newActivityIsRedundant(itemView.model)
    super

class UserFactActivitiesGroupView extends UserActivitiesGroupView
  template: 'activities/user_fact_activities_group'

  @actions: ["created_comment", "created_sub_comment", "believes", "disbelieves", "doubts"]
  actions: -> UserFactActivitiesGroupView.actions

  onRender: ->
    @$('.js-region-fact').html @factView().render().el

  onClose: ->
    @factView().close()

  factView: ->
    @_factView ?= new ReactView
      component: ReactFact
        model: @fact()

  fact: -> new Fact @model.get("activity").fact

  sameFact: (model) ->
    @model.get('activity').fact?.id == model.get('activity').fact?.id

  appendable: (model) -> super(model) and @sameFact(model)

  isOpinion: (activity) ->
    activity.get('action') in ['believes', 'disbelieves', 'doubts']

  isAddedArgument: (activity) ->
    activity.get('action') == "created_comment"

  activityMadeRedundantBy: (newActivity, oldActivity) ->
    @isOpinion(oldActivity) && @isOpinion(newActivity) ||
      @isAddedArgument(oldActivity) && @isAddedArgument(newActivity)

class UsersFollowedGroupView extends UserActivitiesGroupView
  template: 'activities/users_followed_group'

  @actions: ["followed_user"]
  actions: -> UsersFollowedGroupView.actions

  activityMadeRedundantBy: (newActivity, oldActivity) ->
    newActivity.get('activity').followed_user.username ==
      oldActivity.get('activity').followed_user.username
