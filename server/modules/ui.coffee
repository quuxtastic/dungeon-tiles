core=require '../core'
auth=require './auth'
api=require './api'

core.app().get '/',auth.verify,(req,res,next) ->
  res.render 'index.html'

api.get 'view/*',(req,res,next) ->
  path=req.params[0]
  res.render req.params[0]+'.html',req.query
