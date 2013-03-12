class window.InteractiveTour extends Backbone.View
  helpTextDelay: 560

  bindLibraryLoad: ->
    $(window).on 'factlink.libraryLoaded', ->
      FACTLINK.hideDimmer()

      $('#create-your-first-factlink').on 'mouseup', ->
        if FACTLINK.getSelectionInfo().text.length > 0
          tour.state.select_text()
        else
          tour.state.deselect_text()

      FACTLINK.on 'modalOpened', ->
        tour.state.open_modal()

      FACTLINK.on 'modalClosed', ->
        tour.state.close_modal()

      FACTLINK.on 'factlinkAdded', ->
        tour.state.create_factlink()

  renderExtensionButton: ->
    @extensionButton = new ExtensionButtonMimic()
    $('.js-extension-button-region').append(@extensionButton.render().el)

  initialize: ->
    @isClosed = false # Hack to fake Marionette behaviour. Used in TooltipMixin.

    @renderExtensionButton()

    @bindLibraryLoad()

    @createStateMachine()

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
          view = new TooltipView( template: { text: "<p>With Factlink you can select any statement, on any website. Let's try that on this example page.</p><p>Select any statement on the right to start creating your Factlink.</p>" } )
          @tooltipAdd '#create-your-first-factlink > p:first',
            "Let's create a Factlink!",
            "",
            { side: 'left', align: 'top', contentView: view }

        onleavestarted: =>
          @tooltipRemove '#create-your-first-factlink > p:first'
          @state.transition()

        ontext_selected: =>
          view = new TooltipView( template: { text: "<p>Now click the Factlink button to create your Factlink.</p><p>This button will always appear here when the Factlink Extension is installed.</p>" } )
          @tooltipAdd '#extension-button',
            "That was easy!",
            "",
            { side: 'left', align: 'top', alignMargin: 60, contentView: view }

        onleavetext_selected: =>
          @tooltipRemove '#extension-button',
          @state.transition()

        onfactlink_created: =>
          @extensionButton.increaseCount()
          view = new TooltipView(template: 'tooltips/first_factlink_created')
          @tooltipAdd '#create-your-first-factlink',
            "Your first Factlink is a fact!",
            '',
            { side: 'left', align: 'top', contentView: view }

        onleavefactlink_created: =>
          @tooltipRemove '#create-your-first-factlink'
          @state.transition()


_.extend window.InteractiveTour.prototype, Backbone.Factlink.TooltipMixin

$ ->
  if $('body').hasClass 'action_create_your_first_factlink'
    window.tour = new InteractiveTour(el: $('.right-column'))
