window.ReactChangePassword = React.createClass
  displayName: 'ReactChangePassword'
  mixins: [UpdateOnSignInOrOutMixin]

  _submit: ->
    @props.model.save {},
      success: =>
        window.parent.FactlinkApp.NotificationCenter.success 'Your password has been changed!'
        @props.model.clear()
      error: =>
        window.parent.FactlinkApp.NotificationCenter.error 'Could not change your password, please try again.'
        @props.model.clear()

  render: ->
    return _span([], 'Please sign in.') unless FactlinkApp.signedIn()

    _div [],
      ReactUserTabs model: session.user(), page: 'change_password'
      _div ["edit-user-container"],
        _div ["narrow-indented-block"],
          ReactSubmittableForm {
            onSubmit: @_submit
            model: @props.model
            label: 'Change password'
          },
            ReactInput {
              model: @props.model
              label: 'Current password'
              type: 'password'
              attribute: 'current_password'
            },
              _a [href: '/users/password/new'],
                'Forgot your password?'

            ReactInput
              model: @props.model
              label: 'New password'
              type: 'password'
              attribute: 'password'

            ReactInput
              model: @props.model
              label: 'Confirm new password'
              type: 'password'
              attribute: 'password_confirmation'
