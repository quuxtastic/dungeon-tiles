path=require 'path'
fs=require 'fs'
proc=require 'child_process'
mkdirp=require 'mkdirp'
core=require '../core'
app=core.app()
server=core.server()

init_modules=[]
exports.register=(name) ->
  init_modules.push name

src_path=path.join process.cwd(),'client/modules'
out_path=path.join process.cwd(),'var/src'
mkdirp.sync out_path

app.get '/api/load/init',(req,res,next) ->
  res.set 'Content-Type','text/javascript'
  res.send "(function() {define('init',\""+init_modules.join('\",\"')+"\");})();\n"

app.get '/api/load/*',(req,res,next) ->
  subpath=req.params[0]
  subpath_repl=subpath.replace '/','_'

  compiled=path.join out_path,subpath_repl+'.js'
  source=path.join src_path,subpath+'.coffee'

  fs.stat source,(err,src_stats) ->
    if err
      next err
      return
    fs.stat compiled,(err,comp_stats) ->
      if err or src_stats.mtime>comp_stats.mtime
        proc.exec 'coffee -co '+out_path+' '+source,(err,stdout,stderr) ->
          if err
            next err
            return

          res.set 'Content-Type','text/javascript'
          res.sendfile compiled
      else
        res.set 'Content-Type','text/javascript'
        res.sendfile compiled
