io=require 'socket.io'
auth=require 'auth'

exports.initialize=(app,server,options) ->
  io.configure ->
    io.set 'authorization',(handshake,callback) ->
      if handshake.headers.session
        [err_text,success]=auth.verify_request handshake
        callback err_text,success
      else
        callback 'Missing session header',false
  io.listen server
