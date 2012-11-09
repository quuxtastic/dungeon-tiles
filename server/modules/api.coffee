core=require '../core'
auth=require './auth'

exports.get=(path,callback) ->
  core.app().get '/api/'+path,auth.verify,callback
