class EmptyFactRelationsView extends Backbone.Marionette.ItemView
  template: "fact_relations/_fact_relations_empty"
  tagName: 'li'
  templateHelpers: =>
    past_action: if (@options.type == 'weakening') then 'weakened' else 'supported'


class window.FactRelationsView extends Backbone.Marionette.CompositeView
  tagName: "div"
  className: "page evidence-list fact-relations-container"
  template: "fact_relations/fact_relations"

  itemViewContainer: "ul.evidence-listing"

  itemView: FactRelationView
  itemViewOptions: => type: @type

  emptyView: EmptyFactRelationsView

  initialize: (options) ->
    @type = @collection.type
    @collection.bind 'add', this.potentialHighlight, this

    @initializeSearchView()

  initializeSearchView: ->
    @factRelationSearchView = new FactRelationSearchView
      factRelations: @collection
      type: @type

  highlightFactRelation: (model) ->
    view = @children[model.cid]
    @$(this.itemViewContainer).scrollTo view.el, 800
    view.highlight()

  addChildView: (item, collection, options) ->
    res = super(item, collection, options)
    @highlightFactRelation(item) if options.highlight
    return res

  onRender: -> @$el.prepend @factRelationSearchView.render().el

  fetch: ->
    unless @_fetched
      @_fetched = true
      @collection.reset()
      @collection.fetch()
