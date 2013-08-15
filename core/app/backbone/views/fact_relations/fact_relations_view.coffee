class EvidenceEmptyView extends Backbone.Marionette.ItemView
  template: "fact_relations/fact_relations_empty"

  templateHelpers: =>
    past_action:
      switch @options.type
        when 'weakening' then 'weakened'
        when 'supporting' then 'supported'

class EvidenceEmptyLoadingView extends Backbone.Factlink.EmptyLoadingView
  className: "no-evidence-listing"
  tagName: 'li'
  emptyView: EvidenceEmptyView

class EvidenceListView extends Backbone.Marionette.CollectionView
  tagName: 'ul'
  className: 'fact-relation-listing'

  itemView: Backbone.View
  itemViewOptions: => type: @options.type, collection: @collection
  emptyView: EvidenceEmptyLoadingView

  addChildView: (item, collection, options) ->
    result = super(item, collection, options)
    @highlightFactRelation(item) if options.highlight
    result

  highlightFactRelation: (model) ->
    view = @children.findByModel(model)
    @$el.scrollTo view.el, 800
    view.highlight()

  itemViewForModel: (model) ->
    if model.get('evidence_type') == 'FactRelation'
      FactRelationEvidenceView
    else if model.get('evidence_type') == 'Comment'
      CommentEvidenceView
    else
      console.error "This evidence type is not supported: #{model.get('evidence_type')}"
      Backbone.View

  itemViewFor: (item, itemView) ->
    if itemView == @emptyView
      itemView
    else
      @itemViewForModel(item)

  buildItemView: (item, itemView, options) ->
    super item, @itemViewFor(item, itemView), options


class window.FactRelationsView extends Backbone.Marionette.Layout
  className: "tab-content"
  template: "fact_relations/fact_relations"

  regions:
    interactingUserRegion: '.js-interacting-users-region'
    factRelationsRegion: '.js-fact-relations-region'
    factRelationSearchRegion: '.js-fact-relation-search-region'

  onRender: ->
    @$el.addClass @model.type()

    @interactingUserRegion.show new InteractingUsersNamesView
      collection: @model.getInteractorsEvidence().opinionaters()

    if @model.type() == 'supporting' or @model.type() == 'weakening'
      @factRelationsRegion.show new EvidenceListView
        collection: @model.evidence()
        type: @model.evidence().type

      @model.evidence()?.fetch()

      if Factlink.Global.signed_in
        @factRelationSearchRegion.show new AddEvidenceFormView
          collection: @model.evidence()
          fact_id: @model.fact().id
          type: @model.type()
    else
      @hideRegion @factRelationSearchRegion
      @hideRegion @factRelationsRegion

  hideRegion: (region)-> @$(region.el).hide()
