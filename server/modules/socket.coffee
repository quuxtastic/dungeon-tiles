socket_io=require 'socket.io'

mod_define module,'auth',(app,server,options,auth) ->
  io=socket_io.listen server
  io.configure ->
    io.set 'authorization',(handshake,accept_callback) ->
      auth.authenticate_websocket handshake,(err) ->
        if err
          accept_callback err,false
        else
          accept_callback null,true

  class Channel
    constructor: (namespace,options) ->
      @channel=(io.of '/'+namespace)
        .on 'connection',(socket) ->
          @connection=socket
          options.connect this
      if options.authorize?
        @channel.authorization (handshake,accept_callback) ->
          options.authorize handshake,(err) ->
            if err
              accept_callback err,false
            else
              accept_callback null,true
      if options.disconnect?
        .on 'disconnect', ->
          @connection=null
          options.disconnect this

    on: (msg,callback) -> @channel.on msg,callback
    send: (msg,data) -> @channel.emit msg,data
    broadcast: (msg,data) -> @connection.emit msg,data

    set: (name,value) -> @connection.set name,value
    get: (name) -> @connection.get name

  exports.channel=(namespace,options) -> new Channel namespace,options
