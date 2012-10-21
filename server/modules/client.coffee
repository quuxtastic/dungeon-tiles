path=require 'path'
fs=require 'fs'
proc=require 'child_process'

init_modules=[]
exports.register=(name) ->
  init_modules.push name

exports.initialize=(app,server,options) ->
  src_path=path.join process.cwd(),'client/modules'
  out_path=path.join process.cwd(),'var/src'

  app.get 'api/load/init',(req,res,next) ->
    res.set 'Content-Type','text/javascript'
    res.write "(function() {define('init',"+init_modules.join(',')+");})();\n"

  app.get 'api/load/:name',(req,res,next) ->
    compiled=path.join out_path,req.name+'.js'
    source=path.join src_path,req.name+'.coffee'

    fs.stat source,(err,src_stats) ->
      if err
        next err
        return
      fs.stat compiled,(err,comp_stats) ->
        if err or src_stats.mtime>comp_stats.mtime
          proc.exec 'coffee -co '+compiled+' '+source,(err,stdout,stderr) ->
            if err
              next err
              return

            res.set 'Content-Type','text/javascript'
            res.sendfile compiled
        else
          res.set 'Content-Type','text/javascript'
          res.sendfile compiled
