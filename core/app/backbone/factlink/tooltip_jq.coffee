#= require jquery.hoverIntent

#BUG/KNOWN LIMITATION: hoverIntent supports only one handler
#per event.  This means that you certainly cannot support
#more than 1 tooltip per element, but perhaps also not more
#than one per owner.  The workaround is likely to not use
#hoverIntent (sigh), if we ever need this.


Backbone.Factlink ||= {}
defaults =
  closingtimeout: 500
  #$el: owner
  #selector: what to hover over
  #makeTooltip: $el, $target -> $tooltip
  #removeTooltip: $el, $target, $tooltip ->

ttCounter = 0

#returns an object with a close method which when called
#removes all open tooltips
Backbone.Factlink.TooltipJQ = (options) ->
  uid = ttCounter++
  uidStr = 'tooltipUid-' + uid
  instCounter = 0
  instances = {}

  $el = options.$el
  _.defaults options, defaults

  openInstance = ($target) ->
    instId = 'tt' + instCounter++
    inTooltip = false
    inTarget = true

    $tooltip = options.makeTooltip $el, $target
    $tooltip.hoverIntent
      timeout: options.closingtimeout
      over: -> inTooltip = true; check()
      out: -> inTooltip = false; check()

    check = -> remove() if !(inTarget || inTooltip)
    remove = ->
      delete instances[instId]
      options.removeTooltip $el, $target, $tooltip
      $target.removeData(uidStr)

    instances[instId] =
      remove: remove
      setTargetHover: (state) -> inTarget = state; check()

    $target.data(uidStr, instId)

  hoverTarget = (inTarget) -> (e) ->
    $target = $(e.currentTarget)
    ttActions = instances[$target.data(uidStr)]
    if ttActions
      ttActions.setTargetHover inTarget
    else if inTarget
      openInstance $target

  $el.hoverIntent
    timeout: options.closingtimeout
    selector: options.selector
    over: hoverTarget true
    out: hoverTarget false

  close: -> for id, ttActions of instances
    ttActions.remove()

