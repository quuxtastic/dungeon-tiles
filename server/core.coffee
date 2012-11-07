path=require 'path'
fs=require 'fs'

modules={}

server=null
app=null

conf=JSON.parse fs.readFileSync path.join(process.cwd(),'conf/server.json'),'utf8'
if not conf.server? or not conf.server.port?
  if not conf.server
    conf.server={}
  conf.server.port=process.env.PORT

exports._set_server=(in_srv) -> server=in_srv
exports._set_app=(in_app) -> app=in_app

exports.server= -> server
exports.app= -> app

exports.conf=(ns) -> conf[ns]

#global.mod_define=(obj,deps...,body) ->
  #name=path.basename obj.filename,'.coffee'
  #console.log name
  #modules[name]=
    #obj:obj
    #exports:null
    #init:body
    #deps:[deps...]
    #initialized:false
    #name:name

#init_module=(data,app,server,conf) ->
  #if not data.initialized
    #dep_objs=[init_module(modules[dep],app,server,conf) for dep in data.deps]
#
    #data.init app,server,conf[data.name],dep_objs...
    #data.initialized=true
#
  #console.log data.obj.exports
#
  #return data.obj
#
#exports.init_modules=(app,server,conf) ->
  #for name,module_data of modules
    #init_module module_data,app,server,conf
