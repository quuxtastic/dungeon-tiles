path=require 'path'
fs=require 'fs'
proc=require 'child_process'
mkdirp=require 'mkdirp'
cache=require '../lib/cache'
core=require '../core'
compiler=require '../lib/coffee_compiler'
app=core.app()
server=core.server()

init_modules=[]
exports.register=(name) ->
  init_modules.push name

app.get '/api/load/conf',(req,res,next) ->
  send_source 'conf/client-conf.coffee',res,next

app.get '/api/load/*',(req,res,next) ->
  send_source req.params[0],res,next

send_source=(name,res,next) ->
  res.set 'Content-Type','text/javascript'

  cache.sendfile res,next,path.join('src',name),(callback)->
    compiler.compile name,callback
