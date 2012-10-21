define 'socket','socket.io',(exports,io) ->
  exports.socket=(namespace,callback) -> new Socket namespace,callback

  Socket=(namespace,create_callback) ->
    @send=(msg,data) -> socket.send msg,data
    @on=(msg,callback) -> socket.on msg,callback

    socket=io.connect location.protocol+'//'+location.hostname+'/'+namespace
    socket.on 'error',(err) ->
      create_callback null,err
    socket.on 'connect', ->
      create_callback this

