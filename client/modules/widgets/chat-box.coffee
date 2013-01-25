define 'widgets/chat-box','jquery','socket',(exports,$,socket) ->
  exports.ui_options=
    modal:false
    can_close:true
    save_state:true
    show_in_window_list:true

  exports.initialize=(dlg,options) ->
    chat_messages=dlg.find '.chat-message-list'
    chat_input=dlg.find '.chat-input'

    channel=null

    dlg.connect= ->
      if not channel?
        channel=socket.socket 'chat/'+options.name,(conn) ->
          conn.on 'say',(data) ->
            $('<li><b>'+data.origin+'</b>: '+data.text+'</li>')
              .appendTo chat_messages
          conn.on 'whisper',(data) ->
            $('<li><i>'+data.origin+': '+data.text+'</i></li>')
              .appendTo chat_messages

    dlg.disconnect= ->
      if channel?
        channel.close()
        channel=null

    dlg.say=(text) ->
      if text? and text!=''
        cmd='say'
        if text.charAt(0)=='\\'
          endInd=text.indexOf ' '
          cmd=text.substr 1,endInd
          text=text.substr endInd

        channel.send cmd,text

    chat_input.keyup (event) ->
      if event.which==13
        dlg.say chat_input.val()
    dlg.find('.chat-send-button').button().click ->
      dlg.say chat_input.val()

    return options.name
