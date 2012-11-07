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
