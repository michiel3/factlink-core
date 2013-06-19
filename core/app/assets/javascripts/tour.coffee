class FirstFactlinkFactView extends Backbone.Marionette.ItemView
  templateHelpers: ->
    next_tourstep_path: window.next_tourstep_path
  template: 'tooltips/first_factlink_fact'

class window.InteractiveTour extends Backbone.View
  _.extend @prototype, Backbone.Factlink.TooltipMixin

  helpTextDelay: 560

  detectSelecting: ->
    if FACTLINK.getSelectionInfo().text.length > 0
      @state.select_text()

  detectDeselecting: ->
    if FACTLINK.getSelectionInfo().text.length <= 0
      @state.deselect_text()

  bindLibraryLoad: ->
    $(window).on 'factlink.libraryLoaded', => @onLibraryLoaded()

  onLibraryLoaded: ->
    FACTLINK.hideDimmer()

    @detectDeselectingInterval = window.setInterval (=> @detectDeselecting()), 200 unless @detectDeselectingInterval?

    $('.create-your-first-factlink-content').on 'mouseup', =>
      @detectSelecting()
      @detectDeselecting()

    FACTLINK.on 'modalOpened', =>
      @state.open_modal()

    FACTLINK.on 'modalClosed', =>
      @state.close_modal()

    FACTLINK.on 'factlinkAdded', =>
      @state.create_factlink()

  renderExtensionButton: ->
    @extensionButton = new ExtensionButtonMimic()
    $('.js-extension-button-region').append(@extensionButton.render().el)

  initialize: ->
    @isClosed = false # Hack to fake Marionette behaviour. Used in TooltipMixin.

    @renderExtensionButton()

    @bindLibraryLoad()

    @createStateMachine()

  close: ->
    window.clearInterval @detectDeselectingInterval

  createStateMachine: ->
    @state = StateMachine.create
      initial: 'started'
      events: [
        { name: 'select_text',     from: ['started',
                                          'text_selected'],                      to: 'text_selected' }
        { name: 'select_text',     from: ['factlink_created',
                                          'factlink_created_and_text_selected'], to: 'factlink_created_and_text_selected' }
        { name: 'deselect_text',   from:  'started',                             to: 'started' }
        { name: 'deselect_text',   from:  'factlink_created',                    to: 'factlink_created' }
        { name: 'deselect_text',   from:  'text_selected',                       to: 'started' }
        { name: 'deselect_text',   from:  'factlink_created_and_text_selected',  to: 'factlink_created' }
        { name: 'open_modal',      from:  'text_selected',                       to: 'modal_opened' }
        { name: 'open_modal',      from:  ['factlink_created',
                                           'factlink_created_and_text_selected'],to: 'factlink_created_and_modal_opened' }
        { name: 'close_modal',     from:  'modal_opened',                        to: 'started' }
        { name: 'close_modal',     from:  'factlink_created_and_modal_opened',   to: 'factlink_created' }
        { name: 'create_factlink', from: ['modal_opened',
                                          'factlink_created_and_modal_opened'],  to: 'factlink_created' }
      ]
      callbacks:
        onstarted: =>
          @tooltipAdd '.create-your-first-factlink-content > p:first',
            side: 'left'
            align: 'top'
            contentTemplate: 'tooltips/lets_create'

        onleavestarted: =>
          @tooltipRemove '.create-your-first-factlink-content > p:first'
          @state.transition()

        ontext_selected: =>
          @tooltipAdd '#extension-button',
            side: 'left'
            align: 'top'
            alignMargin: 60
            contentTemplate: 'tooltips/extension_button'

        onleavetext_selected: =>
          @tooltipRemove '#extension-button',
          @state.transition()

        onfactlink_created: =>
          @extensionButton.increaseCount()

          Backbone.Factlink.asyncChecking @factlinkFirstExists, @addFactlinkFirstTooltip, @

        onleavefactlink_created: =>
          @tooltipRemove '.factlink.fl-first'
          @state.transition()

  factlinkFirstExists: ->
    @$('.factlink.fl-first').length > 0

  addFactlinkFirstTooltip: ->
    view = new FirstFactlinkFactView
    @tooltipAdd '.factlink.fl-first',
      side: 'left'
      align: 'top'
      margin: 10
      contentView: new FirstFactlinkFactView
