define 'chat-rooms','jquery','server','ui',(exports,$,srv,ui) ->
  exports.ui_options=
    modal:false
    can_close:false
    save_state:true
    show_in_window_list:true

  exports.initialize=(dlg,options) ->
    room_list=dlg.find('.chat-rooms-list').menu()

    room_windows={}

    refresh= ->
      srv.get_auth 'chat/list',(rooms) ->
        for room in rooms
          #

    dlg.find('.chat-add-room').button().click ->
      fields=
        'name':
          required:true
          display:'Name'
      ui.prompt 'Room name','Enter a unique name for this room',fields,false,(unused,dlg) ->
        srv.get 'chat/add_room?name='+dlg.get('name'),(response) ->
          if response.error?
            dlg.find('.prompt-errors').html resonse.error
            dlg.open()
          else
            refresh()
