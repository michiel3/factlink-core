class window.InteractingUsersView extends Backbone.Marionette.Layout

  className: 'ndp-interacting-users'
  template: 'interacting_users/box'

  regions:
    interactingUsersRegion: '.js-region-interacting-users-names'
    interactingUsersAvatarRegion: '.js-region-interacting-users-avatars'

  onRender: ->
    opinionaters = @model.opinionaters()

    @interactingUsersRegion.show new InteractingUsersNamesView
      collection: opinionaters

    @interactingUsersAvatarRegion.show new NDPInteractingUsersAvatarsView
      collection: opinionaters