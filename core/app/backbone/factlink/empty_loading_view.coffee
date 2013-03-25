Backbone.Factlink ||= {}

class Backbone.Factlink.LoadingView extends Backbone.Marionette.ItemView
  template: '<img class="ajax-loader" src="{{global.ajax_loader_image}}">'

class Backbone.Factlink.EmptyLoadingView extends Backbone.Marionette.Layout
  template: '<div class="js-region-empty"></div><div class="js-region-loading"></div>'
  emptyView: null
  loadingView: Backbone.Factlink.LoadingView

  regions:
    emptyRegion: '.js-region-empty'
    loadingRegion: '.js-region-loading'

  initialize: ->
    @emptyView = @options.emptyView if @options.emptyView?
    @bindTo @collection, 'before:fetch reset', @render, @

  onRender: ->
    @showViews()

    if @collection.loading
      @$('.js-region-loading').show()
      @$('.js-region-empty').hide()
    else
      @$('.js-region-loading').hide()
      @$('.js-region-empty').show()

  showViews: ->
    unless @viewsShown
      @viewsShown = true
      @emptyRegion.show   new @emptyView(@options)   if @emptyView?
      @loadingRegion.show new @loadingView(@options) if @loadingView?
