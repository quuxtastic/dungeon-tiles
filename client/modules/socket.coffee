define 'socket','socket.io',(exports,io) ->
  class Socket
    constructor: (namespace,create_callback) ->
      @socket=io.connect location.protocol+'//'+location.hostname+'/'+namespace
      @socket.on 'error',(err) ->
        create_callback null,err
      @socket.on 'connect', ->
        create_callback, @this

    send: (msg,data) -> @socket.send msg,data
    on: (msg,callback) -> @socket.on msg,callback

  exports.socket=(namespace,callback) -> new Socket namespace,callback
