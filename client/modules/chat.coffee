define 'chat','jquery','ui','socket',(exports,$,ui,socket) ->
  exports.nickname=(nick) -> channel.send 'nick',nick
  exports.say=(text) -> channel.send 'say',text
  exports.whisper=(target,text) ->
    channel.send 'whisper',
      target:target
      text:text

  ui.widget 'chat',(widget) ->
    msg_list=widget.find('#chat_messages')
    text_box=widget.find('#chat_text')
    text_box.on 'keydown',(event) ->
      if event.which==13
        channel.send 'say',text_box.val()
        text_box.clear()

    channel=socket.socket 'chat', ->
      .on 'whisper',(data) ->
        $ '<li class="chat-whisper"><i>'+data.origin+' whispers:</i> '+data.text+'</li>'
          .appendTo msg_list
      .on 'say',(data) ->
        $ '<li class="chat-say"><b>'+data.origin+':</b> '+text+'</li>'
          .appendTo msg_list
