define 'chat','jquery','ui',(exports,$,ui) ->
  console.log 'started: chat'
  $ ->
    ui.create_window 'chat-rooms',(wnd) ->
      exports.room=(name) -> wnd.room name
