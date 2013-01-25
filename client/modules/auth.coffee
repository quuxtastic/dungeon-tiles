define 'auth','server','store',(exports,server,store,ui) ->
  auth_data=store.session.ns 'auth'

  exports.current_user= -> auth_data.get 'username'
