FactlinkApp.clientCloseDiscussionModalInitializer = () ->
  FactlinkApp.vent.on 'close_discussion_modal', ->
    mp_track "Discussion Modal: Close (Button)"
    clientCommunicator?.annotatedSiteEnvoy.closeModal_noAction();
