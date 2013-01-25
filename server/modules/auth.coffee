bcrypt=require 'bcrypt'
express=require 'express'
core=require '../core'
cookie_utils=require 'cookie'

SESSION_ID='dungeon-tiles.sid'
AUTH_USERNAME_COOKIE='auth.username'
AUTH_REDIRECT_COOKIE='auth.verify-trampoline'

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

app.get '/login',(req,res,next) ->
  error=(if not req.query.error or req.query.error=='' then '' else error)
  res.render 'login.html',{error:error}

app.post '/authenticate',(req,res,next) ->
  if not req.body.username? or not req.body.password?
    next 'Request body missing credentials'

  check_valid_credentials req.body.username,req.body.password,(err) ->
    if not err
      req.session.user=req.body.username
      res.cookie AUTH_USERNAME_COOKIE,req.session.user
      for callback in login_listeners
        callback exports.current_user req

      refer=res.cookies.get(AUTH_REDIRECT_COOKIE) ? '/'
      res.cookies.set AUTH_REDIRECT_COOKIE,null
      res.redirect(refer)
    else
      res.redirect '/login?error='+encodeURI(err)

app.get '/logout',exports.verify,(req,res,next) ->
  for callback in logout_listeners
    callback exports.current_user(req)
  req.session.destroy()
  res.cookies.set AUTH_USERNAME_COOKIE,null
  res.redirect('/login')

check_valid_session=(credentials,callback) ->
  valid=credentials? and credentials.user?
  if valid
    callback?()
  else
    callback?('You need to log in')

  return valid

exports.verify=(req,res,next) ->
  check_valid_session req.session,(err) ->
    if err
      res.cookies.set AUTH_REDIRECT_COOKIE,req.url
      res.redirect '/login?error='+encodeURI(err)
    else
      next()

exports.authenticate_websocket=(handshake,callback) ->
  # we need to manually extract the session data from the cookie
  if not handshake.headers.cookie?
    callback 'Handshake headers missing session cookie'
  else
    cookie=cookie_utils.parse handshake.headers.cookie
    handshake.sessionID=decodeURI cookie[SESSION_ID]

    app.get('session-store').get handshake.sessionID,(err,session) ->
      if err
        callback 'Invalid session ID'
      else
        handshake.session=session
        check_valid_session session,callback

exports.current_user=(req) -> users[req.session.user]
