#= require jquery.hoverIntent

#BUG/KNOWN LIMITATION: hoverIntent supports only one handler
#per event.  This means that you certainly cannot support
#more than 1 tooltip per element, but perhaps also not more
#than one per owner.  The workaround is likely to not use
#hoverIntent (sigh), if we ever need this.


Backbone.Factlink ||= {}

class Backbone.Factlink.TooltipDefinition
  defaults = closingtimeout: 500
  counter = 0

  constructor: (options) ->
    @_options = _.defaults options, defaults

    @_uid =
    @_uidStr = 'tooltip_Uid-' + counter++
    @_open_tooltip = null

  render: ->
    @_options.$container.hoverIntent
      timeout: @_options.closingtimeout
      selector: @_options.selector
      over: @_hoverTarget true
      out: @_hoverTarget false

  close: ->
    @removeTooltip()
    delete @_open_tooltip #reuse hereafter is a bug: this causes a crash then.
    @_options.$container.off(".hoverIntent") #unfortunately, we can't do better than this.

  _openInstance: ($target) ->
    @$target = $target
    @_open_tooltip = new Tooltip @_options, @$target, => @removeTooltip()

  removeTooltip: =>
    @_options.removeTooltip @_options.$container, @$target, @_open_tooltip._$tooltip
    delete @_open_tooltip

  _hoverTarget: (target_is_hovered) -> (e) =>
    if @_open_tooltip
      setTargetHover target_is_hovered
    else if target_is_hovered
      @_openInstance $(e.currentTarget)

  setTargetHover: (target_is_hovered) ->
    @_open_tooltip.setTargetHover target_is_hovered

class Tooltip #only local!
  constructor: (@_options, @$target, @closeCallback) ->
    @_inTooltip = false
    @_inTarget = true #opened on hover over target

    @_$tooltip = @_options.makeTooltip @_options.$container, $target
    @_$tooltip.hoverIntent
      timeout: @_options.closingtimeout
      over: => @_inTooltip = true; @_check()
      out: => @_inTooltip = false; @_check()

  _check: -> @closeCallback(@_$tooltip) if !(@_inTarget || @_inTooltip)

  setTargetHover: (state) -> @_inTarget = state; @_check()

