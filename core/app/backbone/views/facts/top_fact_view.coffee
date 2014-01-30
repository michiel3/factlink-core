class window.TopFactView extends Backbone.Marionette.Layout
  className: 'top-fact'

  template: 'facts/top_fact'

  events:
    'click .js-undo': -> @model.destroy()

  regions:
    deleteRegion: '.js-delete-region'
    shareRegion: '.js-share-region'
    factVoteTableRegion: '.js-fact-vote-table-region'

  templateHelpers: =>
    showDelete: @model.can_destroy()

  onRender: ->
    @deleteRegion.show @_deleteButtonView() if @model.can_destroy()
    @factVoteTableRegion.show new FactVoteTableView model: @model

    Backbone.Factlink.makeTooltipForView @,
      stayWhenHoveringTooltip: true
      hoverIntent: true
      positioning: {align: 'right', side: 'bottom'}
      selector: '.js-share'
      tooltipViewFactory: => new ShareFactView model: @model

  _deleteButtonView: ->
    deleteButtonView = new DeleteButtonView model: @model, undo: @model.justCreated()

    @listenTo deleteButtonView, 'delete', ->
      @model.destroy
        wait: true
        success: -> mp_track "Factlink: Destroy"

    deleteButtonView
