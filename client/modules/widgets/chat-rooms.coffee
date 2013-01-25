define 'widgets/chat-rooms','jquery','server','ui','util',(exports,$,srv,ui,util) ->
  exports.ui_options=
    modal:false
    can_close:false
    save_state:true
    show_in_window_list:true

  exports.initialize=(dlg,options) ->
    console.log 'Started: chat-rooms'
    room_list=dlg.find('.chat-rooms-list').menu().on 'select',(item) ->
      wnd=item.data 'chat_box_window'
      wnd.connect()
      wnd.open()
      wnd.focus()

    room_windows={}

    refresh=(callback) ->
      srv.get 'chat/list',(rooms) ->
        room_list.empty()

        for room in rooms
          if not room_windows[room]?
            ui.create_window 'chat-box',{name:room},(wnd) ->
              room_windows[room]=wnd
              wnd.connect()
              wnd.open()
          else
            wnd=room_windows[room]
            wnd.connect()
            wnd.open()

        for room,wnd in room_windows
          if room not in rooms and room_windows[room]?
            wnd=room_windows[room]
            wnd.close()
            wnd.disconnect()
            delete room_windows[room]

        for room,wnd of room_windows
          $('<li>'+room+'</li>')
            .data 'chat_box_window',wnd
            .appendTo room_list

        callback?()

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
            create_window 'chat-box',{name:name},(wnd) ->
              room_windows[name]=wnd
              wnd.connect()
              wnd.open()
            refresh -> dlg.close()

    dlg.room=(name) -> room_windows[name]
