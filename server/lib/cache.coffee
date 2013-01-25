fs=require 'fs'
path=require 'path'
conf=require('../core').conf

CACHE=path.join conf.server.var_path,'cache'

require('mkdirp').sync CACHE

exports.get=(key,callback) -> fs.readFile path.join(CACHE,key),'utf8',callback

exports.put=(key,value,callback) -> fs.writeFile path.join(CACHE,key),value,'utf8',callback

exports.remove=(key,callback) ->  fs.unlink path.join(CACHE,key),callback

exports.send=(res,next,key,on_miss) ->
  fs.exists path.join(CACHE,key),(exists) ->
    if exists
      fs.sendfile path.join CACHE,key
    else
      on_miss (err,data) ->
        if err
          next err
        else
          res.send data
          fs.writeFile path.join(CACHE,key),value,'utf8'

exports.sendfile=(res,next,file_path,encoding='utf8',on_miss) ->
  fs.stat file_path,(err,source_stats) ->
    if err
      next err
    else
      fs.stat path.join(CACHE,file_path),(err,cached_stats) ->
        if err or cached_stats.mtime<source_stats.mtime
          on_miss (err,data) ->
            if err
              next err
            else
              fs.writeFile path.join(CACHE,file_path),data,encoding
              res.send data
        else
          res.sendfile path.join(CACHE,file_path)
