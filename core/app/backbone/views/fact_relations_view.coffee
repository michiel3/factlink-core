class window.FactRelationsView extends Backbone.Marionette.CompositeView
  tagName: "div"
  className: "page evidence-list fact-relations-container"
  template: "fact_relations/fact_relations"

  itemViewContainer: "ul.evidence-listing"

  itemView: FactRelationView
  itemViewOptions: => type: @options.type

  initialize: (options) ->
    @initializeSearchView()
    @collection.bind 'add', this.potentialHighlight, this

  initializeSearchView: ->
    @factRelationSearchView = new FactRelationSearchView
      factRelations: @collection
      type: @options.type

  highlightFactRelation: (model) ->
    view = @children[model.cid]
    @$(this.itemViewContainer).scrollTo view.el, 800
    view.highlight()

  addChildView: (item, collection, options) ->
    res = super(item, collection, options)
    @highlightFactRelation(item) if options.highlight
    return res

  onRender: -> @$el.prepend @factRelationSearchView.render().el

  hide: -> @$el.hide()
  show: -> @$el.show()

  showAndFetch: ->
    @fetch() unless @_fetched
    @show()

  fetch: ->
    @_fetched = true
    @collection.reset()
    @collection.fetch()

  showEmptyView: -> @$(".no-evidence-message").show()
  closeEmptyView: -> @$(".no-evidence-message").hide()
