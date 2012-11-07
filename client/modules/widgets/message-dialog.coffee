define 'widgets/message-dialog',(exports) ->
  exports.ui_options=
    modal:true
    can_close:false
    show_in_window_list:false
    save_state:false

  exports.initialize=(dlg,options) ->
    dlg.find('.ui-icon').addClass options.icon
    dlg.find('.dlg-message').html options.message
    if options.on_close?
      dlg.on 'close', -> options.on_close dlg
    dlg.button 'OK', -> dlg.close()

    dlg.open()

    return options.title
