define 'window_list','jquery',(exports,$) ->
  exports.ui_options=
    modal:false
    can_close:false
    save_state:true
    show_in_window_list:false

  exports.initialize=(dlg) ->
    window_list=dlg.find '.window-list'

    window_list.menu
      select: (event,ui) -> ui.item.focus()

    dlg.add=(wnd,title) ->
      item=$('<a href="#">'+title+'</a>').data 'wnd',wnd
      $('<li></li>')
        .append item
        .appendTo window_list

    dlg.remove=(wnd) ->
      window_list.find('li').each (item) ->
        if item.find('a').data('wnd')==wnd
          item.detach()

    return 'window_list'
