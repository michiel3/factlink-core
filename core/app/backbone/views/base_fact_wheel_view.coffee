class window.BaseFactWheelView extends Backbone.Marionette.ItemView
  className: "wheel"
  defaults:
    respondsToMouse: true
    showsTooltips: true

    radius: 16
    minimalVisiblePercentage: 15

    defaultStroke:
      opacity: 0.2

    hoverStroke:
      opacity: 0.5

    userOpinionStroke:
      opacity: 1.0

    opinionStyles:
      believe:
        groupname: Factlink.Global.t.fact_believe_opinion?.titleize()
        color: "#98d100"
      doubt:
        groupname: Factlink.Global.t.fact_doubt_opinion?.titleize()
        color: "#36a9e1"
      disbelieve:
        groupname: Factlink.Global.t.fact_disbelieve_opinion?.titleize()
        color: "#e94e1b"

  template: "facts/fact_wheel"

  initialize: (options) ->
    @options = $.extend(true, {}, BaseFactWheelView.prototype.defaults, @defaults, options)
    @opinionTypeRaphaels = {}

  defaultStrokeWidth: ->
    3/5 * @defaults.radius

  hoverStrokeWidth: ->
    @defaultStrokeWidth() + 2

  maxStrokeWidth: -> Math.max(@defaultStrokeWidth(), @hoverStrokeWidth())

  onRender: ->
    @renderRaphael()
    @randomActions()

  render: ->
    if @already_rendered
      @reRender()
    else
      super()
      @already_rendered = true
    @

  renderRaphael: ->
    @$canvasEl = $('<div></div>')
    @$canvasEl.addClass 'fact-wheel-responding-to-mouse' if @options.respondsToMouse

    @$('.raphael_container').html(@$canvasEl)
    @canvas = Raphael @$canvasEl[0], @boxSize(), @boxSize()
    @bindCustomRaphaelAttributes()

  boxSize: -> @options.radius * 2 + @maxStrokeWidth()

  randomActions: ->
    offset = 0
    @calculateDisplayablePercentages()
    for key, opinionType of @model.get('opinion_types')
      @createOrAnimateArc opinionType, offset
      offset += opinionType.displayPercentage
    @bindTooltips()

  reRender: ->
    @$('.authority').text(@model.get('authority'))
    for type, opinionType of @model.get('opinion_types')
      chosen = opinionType.is_user_opinion
      @$(".js-opinion-#{type}").attr
        checked:  if chosen then 'checked' else false
    @randomActions()

  createOrAnimateArc: (opinionType, percentageOffset) ->
    opacity = (if opinionType.is_user_opinion then @options.userOpinionStroke.opacity else @options.defaultStroke.opacity)

    # Our custom Raphael arc attribute
    arc = [opinionType.displayPercentage, percentageOffset, @options.radius]
    if @opinionTypeRaphaels[opinionType.type]
      @animateExistingArc opinionType, arc, opacity
    else
      @createArc opinionType, arc, opacity

  createArc: (opinionType, arc, opacity) ->
    # Create a path in the global Raphael canvas and store it in opinionTypeRaphaels
    path = @canvas.path().attr
      # Our custom arc attribute
      arc: arc
      stroke: @options.opinionStyles[opinionType.type].color
      "stroke-width": @defaultStrokeWidth()
      opacity: opacity

    # Bind Mouse Events on the path
    if @options.respondsToMouse || @options.showsTooltips
      path.mouseover _.bind(@mouseoverOpinionType, this, path, opinionType)
      path.mouseout _.bind(@mouseoutOpinionType, this, path, opinionType)
      path.click _.bind(@clickOpinionType, this, opinionType)

    @opinionTypeRaphaels[opinionType.type] = path

  animateExistingArc: (opinionType, arc, opacity) ->
    # Retrieve the existing Raphael path belonging to this opinionType
    @opinionTypeRaphaels[opinionType.type].animate(
      # Our custom arc attribute
      arc: arc
      opacity: opacity
    , 200, "<>")

  # This method also commits the calculated percentages to the model, maybe return instead?
  calculateDisplayablePercentages: ->
    too_much = 0
    large_ones = 0

    for key, opinionType of @model.get('opinion_types')
      percentage = opinionType.percentage
      if percentage < @options.minimalVisiblePercentage
        too_much += @options.minimalVisiblePercentage - percentage
      else large_ones += percentage  if percentage > 40

    for key, opinionType of @model.get('opinion_types')
      percentage = opinionType.percentage
      if percentage < @options.minimalVisiblePercentage
        percentage = @options.minimalVisiblePercentage
      else percentage = percentage - ((percentage / large_ones) * too_much)  if percentage > 40
      opinionType.displayPercentage = percentage

  bindCustomRaphaelAttributes: ->
    polarToRegular = (origin, radius, angle)->
      x: origin[0] + radius * Math.cos(angle),
      y: origin[1] - radius * Math.sin(angle)

    @canvas.customAttributes.arc = (percentage, percentageOffset, radius) =>
      padding = 32/@options.radius
      percentage = percentage - padding

      startAngle = percentageOffset * 2 * Math.PI / 100
      endAngle = (percentageOffset + percentage) * 2 * Math.PI / 100

      origin = [@boxSize() / 2, @boxSize() / 2]

      start = polarToRegular(origin, radius, startAngle)
      end = polarToRegular(origin, radius, endAngle)

      direction = if percentage > 50 then 1 else 0
      path: [["M", start.x, start.y], ["A", radius, radius, 0, direction, 0, end.x, end.y]]

  mouseoverOpinionType: (path, opinionType) ->
    destinationOpacity = @options.hoverStroke.opacity
    destinationOpacity = @options.userOpinionStroke.opacity  if opinionType.is_user_opinion
    path.animate(
      "stroke-width": @hoverStrokeWidth()
      opacity: destinationOpacity
    , 200, "<>")

  mouseoutOpinionType: (path, opinionType) ->
    destinationOpacity = @options.defaultStroke.opacity
    destinationOpacity = @options.userOpinionStroke.opacity  if opinionType.is_user_opinion
    path.animate(
      "stroke-width": @defaultStrokeWidth()
      opacity: destinationOpacity
    , 200, "<>")

  clickOpinionType: ->

  bindTooltips: ->
    if @options.showsTooltips
      @$("div.tooltip").remove()
      @$(".authority").tooltip title: "This number represents the amount of thinking " + "spent by people on this Factlink"

      # Create tooltips for each opinionType (believe, disbelieve etc)
      for key, opinionType of @model.get('opinion_types')
        raphaelObject = @opinionTypeRaphaels[opinionType.type]
        $(raphaelObject.node).tooltip
          title: @options.opinionStyles[opinionType.type].groupname + ": " + opinionType.percentage + "%"
          placement: "left"

  updateTo: (authority, opinionTypes) ->
    @model.set "authority", authority
    if _.isArray(opinionTypes)
      tempObject = {}
      _.each opinionTypes, (opinionType) ->
        tempObject[opinionType.type] = opinionType

      opinionTypes = tempObject
    for key, opinionType of @model.get('opinion_types')
      newOpinionType = opinionTypes[opinionType.type]
      opinionType.percentage = newOpinionType.percentage
      opinionType.is_user_opinion = newOpinionType.is_user_opinion

    @reRender()

  toggleActiveOpinionType: (opinionType) ->
    oldAuthority = @model.get("authority")
    updateObj = {}
    _.each @model.get('opinion_types'), (oldOpinionType) ->
      updateObj[oldOpinionType.type] = _.clone(oldOpinionType)
      unless opinionType.is_user_opinion
        updateObj[oldOpinionType.type].is_user_opinion = false
      if oldOpinionType == opinionType
        updateObj[oldOpinionType.type].is_user_opinion = !opinionType.is_user_opinion

    @updateTo oldAuthority, updateObj
