class window.NDPEvidenceCollection extends Backbone.Factlink.Collection
  model: OpinionatersEvidence

  default_fetch_data:
    take: 7

  initialize: (models, options) ->
    @on 'change', @sort, @
    @fact = options.fact

    @_wheel = @fact.getFactWheel()
    @_wheel.on 'sync', =>
      @reset []
      @fetch()

  comparator: (item) -> - item.get('impact')

  url: ->
    "/facts/#{@fact.id}/interactors"

  fetch: (options={}) ->
    super _.defaults options, @default_fetch_data
