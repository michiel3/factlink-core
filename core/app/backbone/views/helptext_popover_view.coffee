class window.HelptextPopoverView extends Backbone.Marionette.Layout
  template: 'tooltips/helptext_popover'
  className: 'help-text-container'

  ui:
    arrow: '.js-arrow'

  regions:
    contentRegion: '.js-help-text-content'

  initialize: ->
    @on 'position', @onPosition, @

  onRender: ->
    @$el.addClass @options.side
    @contentRegion.show @options.contentView if @options.contentView
    @$el.toggleClass 'help-text-container-flexible', @options.flexible || false

    @updateMargins()

  alignOffsets: ->
    alignMargin = @options.alignMargin || 19

    switch @options.align
      when 'left'
        left:  alignMargin
        top:   0
      when 'top'
        left:  0
        top:   alignMargin
      when 'right'
        left: -alignMargin
        top:   0
      when 'bottom'
        left:  0
        top:  -alignMargin
      else
        left:  0
        top:   0

  updateMargins: ->
    offsets = @alignOffsets()

    if @options.side in ['left', 'right']
      @ui.arrow.css 'margin-top':   offsets.top
      @$el.css      'margin-top':  -offsets.top
    if @options.side in ['top', 'bottom']
      @ui.arrow.css 'margin-left':  offsets.left
      @$el.css      'margin-left': -offsets.left

  onPosition: (offset)->
    if @options.side in ['left', 'right']
      @ui.arrow.css 'top', offset.top - (@ui.arrow.height() / 2)

    if @options.side in ['top', 'bottom']
      @ui.arrow.css 'left', offset.left - (@ui.arrow.width() / 2)
