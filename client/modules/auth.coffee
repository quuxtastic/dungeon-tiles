define 'auth','server','store',(exports,server,store) ->
  exports.current_user= -> auth_data.get 'user'

  exports.login=(callback) ->
    if not auth_data.get 'key'
      try_login callback
    else
      callback

  exports.logout=(callback) ->
    server.request 'logout'
    auth_data.remove 'key'
    auth_data.remove 'user'

  login_success=(username,key) ->
    auth_data.put 'user',username
    auth_data.put 'key',key
    for f in login_callbacks
      f username,key
    login_callbacks=[]
    trying_login=false

  login_buttons=
    'Log In':(frm) ->
      args=
        username:frm.find('[name="username"]').val()
        password:frm.find('[name="password"]').val()
      server.request 'login',args,(response) ->
        if response.key?
          login_dlg.close()
          login_success
        else
          ui.error 'Login error',response.text
  login_dlg=ui.create_prompt 'Log In','Enter your login credentials',login_buttons,
    'username':'User name'
    'password':'Password'

  trying_login=false
  try_login=(callback) ->
    login_callbacks.push callback

    if not trying_login
      trying_login=true

      login_dlg.open()

  auth_data=store.session.ns 'auth'
