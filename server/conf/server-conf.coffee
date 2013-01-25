path=require 'path'

exports.server=
  port:process.env.PORT
  var_path:path.join process.cwd(),'var'

exports.compiler=
  src_path:path.join process.cwd(),'client','modules'
  client_conf_path:path.join process.cwd(),'client','conf','client-conf.coffee'
  debug:on
