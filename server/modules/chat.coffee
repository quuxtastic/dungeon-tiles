socket=require './socket'
client=require './client'
auth=require './auth'
core=require '../core'

app=core.app()
server=core.server()

class Room
  constructor: (@room_name,do_auth=true) ->
    @authorized_members=[]
    @current_members={}
    @admin_user=null

    find_user_by_nick=(nick) ->
      for username,conn of @current_members
        if conn.get('nick')==nick
          return username

    parse_msg=(text) ->
      return text

    @my_socket=socket.channel 'chat/'+@room_name,
      authorize: (handshake,callback) ->
        if do_auth
          if handshake.session.user in @authorized_members
            callback()
          else
            callback handshake.session.user+' is not a member of this room'
        else
          callback()

      connect: (conn) ->
        conn.set 'nick',conn.session.user
        @broadcast conn.get('nick')+' has joined'
        @current_members[conn.session.user]=conn

        if not @admin_user?
          @set_admin_user conn.session.user

        conn.on 'say',(text) ->
          @broadcast conn.get('nick'),parse_msg text

        conn.on 'whisper',(data) ->
          @current_members[(find_user_by_nick data.target)].send 'whisper',
            origin:data.target
            text:parse_msg data.text

        conn.on 'nick',(nick) ->
          @broadcast conn.get('nick')+' changed nick to '+nick
          conn.set('nick',nick)

        conn.on 'kick',(nick) ->
          if @admin_user==conn.session.user
            @ban_nick nick

        conn.on 'invite',(username) ->
          if @admin_user==conn.session.user
            @invite username

        conn.on 'setadmin',(username) ->
          if @admin_user==conn.session.user
            @set_admin_user username

        conn.on 'list', ->
          conn.send 'whisper',
            origin:'server'
            text:'Current users are '+(@nicks().join ',')

        conn.on 'close', ->
          if @admin_user==conn.session.user
            @close()

      disconnect: (conn) ->
        delete @current_members[conn.session.user]

        @broadcast conn.get('nick')+' has left'

        if @admin_user==conn.session.user
          @admin_user=null
          for username,conn of @current_members
            if conn?
              set_admin_user username
              return

  invite: (username) ->
    @authorized_members.push username

  ban_user: (username) ->
    @authorized_members.remove username
    if @current_members[username]?
      @broadcast @current_members[username].get('nick')+' has been kicked'
      @current_members[username].close()
      delete @current_members[username]

  ban_nick: (nick) -> @ban_user find_user_by_nick nick

  set_admin_user: (username) ->
    if @current_members[username]?
      @admin_user=username
      @broadcast @current_members[username].get('nick')+' is the room admin'

  set_admin_nick: (nick) -> @set_admin_user find_user_by_nick nick

  broadcast: (origin='server',text) ->
    @my_socket.send 'say',
      origin:origin
      text:text

  send_user: (origin='server',username,text) ->
    conn=current_members[username]
    if conn?
      conn.send 'say',
        origin:origin
        text:text

  send_nick: (origin='server',nick,text) ->
    send_user origin,(find_user_by_nick nick),text

  close: ->
    @broadcast 'Closing room...'
    @my_socket.close()

  users: -> [username for username,conn of current_members]
  admin: -> @admin_user
  name: -> @room_name
  nicks: -> [conn.get('nick') for username,conn of current_members]

rooms={}

exports.create_room=(name,authorized_users=[]) ->
  if rooms[name]?
    return null

  room=new Room name,(authorized_users.length>0)
  for username in authorized_users
    room.invite username
  rooms[name]=room
  return room

exports.remove_room=(name) ->
  rooms[name].close()
  delete rooms[name]

exports.room=(name) -> rooms[room]

exports.rooms= -> [name for name,room of rooms]

exports.create_room 'global'

auth.on_login (user) ->
  exports.create_room 'private/'+user.name,[user.name]

auth.on_logout (user) ->
  exports.remove_room 'private/'+user.name

app.get '/api/chat/add_room',auth.verify,(req,res,next) ->
  if exports.create_room req.query.name,[auth.current_user(req).name]
    res.send 200
  else
    next 'Room '+req.query.name+' already exists'

app.get '/api/chat/remove_room',auth.verify,(req,res,next) ->
  room=rooms[req.query.name]
  if not room?
    next 'Unknown room '+req.query.name

  if auth.current_user(req).name==room.admin()
    exports.remove_room req.query.name
    res.send 200
  else
    next 'You are not the administrator of room '+req.query.name

app.get '/api/chat/list',auth.verify,(req,res,next) ->
  res.send exports.rooms

client.register 'chat'
