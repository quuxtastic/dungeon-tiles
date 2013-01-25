path=require 'path'
fs=require 'fs'

modules={}

server=null
app=null

exports.conf=require path.join process.cwd(),'server','conf','server-conf.coffee'

exports._set_server=(in_srv) -> server=in_srv
exports._set_app=(in_app) -> app=in_app

exports.server= -> server
exports.app= -> app
