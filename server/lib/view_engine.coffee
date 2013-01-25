fs=require 'fs'
path=require 'path'

exports.render=(view_path,options,callback) ->
  fs.readFile view_path,'utf8',(err,data) ->
    if err
      callback err
    else
      callback null,data.replace /\{\{(\w+)\}\}/g,(match,varname) ->
        return (if options[varname]? then options[varname] else '')

exports.__express=exports.render
