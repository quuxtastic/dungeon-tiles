define 'widgets/login',(exports) ->
  exports.ui_options=
    title:'Log In'
    modal:true
    show_in_window_list:true
    save_state:true
    can_close:false

  exports.initialize=(dlg,options) ->
    dlg.find('.login-button').button().click ->
      options.callback dlg,dlg.get('username'),dlg.get('password')

    dlg.error=(text) ->
      dlg.find('.login-error').html text

    return 'login'
