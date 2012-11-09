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

app.get '/api/load/init',(req,res,next) ->
  res.set 'Content-Type','text/javascript'
  res.send "define('init','"+init_modules.join("','")+"',null);\n"

app.get '/api/load/*',(req,res,next) ->
  name=path.basename req.params[0]
  subpath=path.dirname req.params[0]

  src_dir=path.join process.cwd(),'client/modules',subpath
  out_dir=path.join process.cwd(),'var/src',subpath
  mkdirp.sync out_dir

  compiled=path.join out_dir,name+'.js'
  source=path.join src_dir,name+'.coffee'

  fs.stat source,(err,src_stats) ->
    if err
      next err
      return
    fs.stat compiled,(err,comp_stats) ->
      if err or src_stats.mtime>comp_stats.mtime
        proc.exec 'coffee -co '+out_dir+' '+source,(err,stdout,stderr) ->
          if err
            next err
            return

          res.set 'Content-Type','text/javascript'
          res.sendfile compiled
      else
        res.set 'Content-Type','text/javascript'
        res.sendfile compiled
