define 'chat-rooms','jquery','server','ui','util',(exports,$,srv,ui,util) ->
  exports.ui_options=
    modal:false
    can_close:false
    save_state:true
    show_in_window_list:true

  exports.initialize=(dlg,options) ->
    room_list=dlg.find('.chat-rooms-list').menu().on 'select',(item) ->
      wnd=item.data 'chat_box_window'
      wnd.open()
      wnd.focus()

    room_windows={}

    refresh= ->
      srv.get_auth 'chat/list',(rooms) ->
        room_list.clear()

        for room in rooms
          if not room_windows[room]?
            ui.create_window 'chat-box',{name:room},(wnd) ->
              room_windows[room]=wnd
              wnd.open()
          else
            room_windows[room].open()

        for room,wnd in room_windows
          if room not in rooms and room_windows[room]?
            room_windows[room].close()
            delete room_windows[room]

        for room,wnd of room_windows
          $('<li>'+room+'</li>')
            .data 'chat_box_window',wnd
            .appendTo room_list

    util.interval 1000,refresh

    dlg.find('.chat-add-room').button().click ->
      fields=
        'name':
          required:true
          display:'Name'
      ui.prompt 'Room name','Enter a unique name for this room',fields,false,(unused,dlg) ->
        name=dlg.get('name')
        srv.get 'chat/add_room?name='+name,(response) ->
          if response.error?
            dlg.find('.prompt-errors').html resonse.error
          else
            dlg.close()
            create_window 'chat-box',{name:name},(wnd) ->
              room_windows[name]=wnd
            refresh()
