class window.AutoCompleteFactRelationsView extends AutoCompleteSearchView
  className: "auto-complete auto-complete-fact-relations"

  events:
    "click .js-post": "addNew"
    'click .js-switch-to-factlink': 'switchCheckboxClicked'

  regions:
    'search_list': 'div.auto-complete-search-list-container'
    'text_input': 'div.js-auto-complete-input-view-container'

  template: 'fact_relations/auto_complete'

  ui:
    submit: '.js-post'

  initialize: (options) ->
    @initializeChildViews
      filter_on: 'id'
      search_list_view: (options) => new AutoCompleteSearchFactRelationsView _.extend {}, options,
        recent_collection: @recentCollection()
      search_collection: new FactRelationSearchResults [],
        fact_id: options.fact_id
        recent_collection: @recentCollection()
      filtered_search_collection: new FilteredFactRelationSearchResults
      placeholder: @placeholder(options.type)

    @listenTo @_text_input_view, 'focus', @focus
    @listenTo @model, 'change', @queryChanges

  recentCollection: ->
    unless @_recent_collection?
      @_recent_collection = new RecentlyViewedFacts
      @_recent_collection.fetch()
    @_recent_collection

  placeholder: (type) ->
    if type == "supporting"
      "The Factlink above is true because:"
    else
      "The Factlink above is false because:"

  addCurrent: ->
    selected_fact_attributes = @_search_list_view.currentActiveModel().attributes

    if selected_fact_attributes?
      @addSelected(selected_fact_attributes)
    else
      @addNew()

  addNew: ->
    text = @model.get('text')

    fact = new Fact
      displaystring: text
      opinion: 'believes'
      fact_wheel: (new Wheel).toJSON()

    @createFactRelation new FactRelation
      displaystring: text
      from_fact: fact.toJSON()
      created_by: currentUser.toJSON()

  switchCheckboxClicked: (e) ->
    @$el.removeClass 'active'
    @trigger 'switch_to_comment_view', @model.get('text')
    e.preventDefault()
    e.stopPropagation()

    mp_track "Evidence: Switching to comment"

  addSelected: (selected_fact_attributes)->
    @createFactRelation new FactRelation
      evidence_id: selected_fact_attributes.id
      from_fact: selected_fact_attributes
      created_by: currentUser.toJSON()

  createFactRelation: (fact_relation) ->
    return if @submitting
    @disableSubmit()
    @trigger 'createFactRelation', fact_relation, => @enableSubmit()

  setQuery: (text) -> @model.set text: text

  focus: ->
    mp_track "Evidence: Search focus"

  reset: ->
    @setQuery ''

  queryChanges: ->
    unless @query_has_changed
      @query_has_changed = true
      mp_track "Evidence: Started searching"

  enableSubmit: ->
    @submitting = false
    @ui.submit.prop('disabled',false).text('Post Factlink')

  disableSubmit: ->
    @submitting = true
    @ui.submit.prop('disabled',true ).text('Posting...')
