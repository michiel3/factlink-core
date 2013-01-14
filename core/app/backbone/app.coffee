class FactlinkAppClass extends Backbone.Marionette.Application
  startAsSite: ->
    @startSiteRegions()
    @addInitializer @automaticLogoutInitializer
    @addInitializer @notificationsInitializer

    @addInitializer (options)->
      new ProfileRouter controller: new ProfileController # first, as then it doesn't match index pages such as "/m" using "/:username"
      new ChannelsRouter controller: new ChannelsController
      new ConversationsRouter controller: new ConversationsController
      # the choose-channels in the tour uses the startAsSite
      new TourRouter controller: new TourController

    @start()

  startAsTour: ->
    @addInitializer (options)->
      new TourRouter controller: new TourController

    @start()

  startAsClient: ->
    @startClientRegions()
    @addInitializer (options)->
      new ClientRouter controller: new ClientController

    @start()

window.FactlinkApp = new FactlinkAppClass
