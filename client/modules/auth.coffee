define 'auth','server','store','ui',(exports,server,store,ui) ->
  auth_data=store.session.ns 'auth'

  exports.current_user= -> auth_data.get 'user'

  exports.login=(callback) ->
    if not auth_data.get 'user'
      try_login callback
    else
      callback

  exports.logout=(callback) ->
    server.request 'logout'
    auth_data.remove 'key'
    auth_data.remove 'user'

  login_callbacks=[]
  login_success=(username) ->
    auth_data.put 'user',username
    for f in login_callbacks
      f username,key
    login_callbacks=[]
    trying_login=false

  trying_login=false
  try_login=(callback) ->
    login_callbacks.push callback

    if not trying_login
      trying_login=true

      ui.window 'login',(wnd) -> wnd.open()

  ui.create_window 'login',
    callback: (dlg,username,password) ->
      server.post 'login',{username:username,password:password},(response) ->
        if not response.error?
          dlg.close()
          dlg.error ''
          login_success password
        else
          dlg.error response.error
