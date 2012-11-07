bcrypt=require 'bcrypt'
express=require 'express'
core=require '../core'

server=core.server()
app=core.app()

users=
  'admin':
    password:'test'
    admin:true
  'testuser':
    password:'password'
    admin:false

check_valid_credentials=(username,password,callback) ->
  if not users[username]?
    callback 'Unknown user "'+username+'"'
  else if not password==users[username].password
    callback 'Bad password'
  else
    callback()

  #bcrypt.compare password,users[username].password,(err,valid) ->
  #  if err
  #    callback err
  #  if not valid
  #    callback 'Bad password'
  #  else
  #    callback()

login_listeners=[]
logout_listeners=[]
exports.on_login=(callback) ->
  login_listeners.push callback
exports.on_logout=(callback) ->
  logout_listeners.push callback

app.post '/api/login',(req,res,next) ->
  if not req.body.username? or not req.body.password?
    next 'Request body missing credentials'

  check_valid_credentials req.body.username,req.body.password,(err) ->
    if err
      next err
    else
      req.session.user=req.body.username
      for callback in login_listeners
        callback exports.current_user(req)
      res.send {}

app.get '/api/logout',exports.verify,(req,res,next) ->
  for callback in logout_listeners
    callback exports.current_user(req)
  req.session.destroy()
  res.send {}

check_valid_session=(credentials,callback) ->
  valid=credentials? and credentials.user?
  if valid
    callback?()
  else
    callback?('Session missing authentication information')

  return valid

exports.verify=(req,res,next) ->
  check_valid_session req.session,next

exports.authenticate_websocket=(handshake,callback) ->
  # we need to manually extract the session data from the cookie
  cookie=handshake.headers.cookie
  if not cookie?
    callback 'Handshake headers missing session cookie'
  else
    cookie=express.utils.parseCookie handshake,cookie
    handshake.sessionID=cookie['dungeon-tiles.sid']

    app.get('session-store').get handshake.sessionID,(err,session) ->
      if err
        callback 'Invalid session ID'
      else
        handshake.session=session
        check_valid_session session,callback

exports.current_user=(req) -> users[req.session.user]
