path=require 'path'

modules={}

global.mod_define=(obj,deps...,body) ->
  name=path.basename obj.__filename,'.coffee'
  modules[name]=
    obj:obj.exports
    init:body
    deps:[deps...]
    initialized:false
    name:name

init_module=(data,app,server,conf) ->
  if not data.initialized
    dep_objs=[load_module(modules[dep],app,server,conf) for dep in data.deps]

    data.init app,server,conf[name],dep_objs...
    data.initialized=true

  return data.obj

exports.init_modules=(app,server,conf) ->
  for name,module_data of modules
    init_module module_data,app,server,conf
