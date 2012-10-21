express=require 'express'
http=require 'http'
socket_io=require 'socket.io'
fs=require 'fs'
path=require 'path'

conf=JSON.parse fs.readFileSync path.join(process.cwd(),'conf/server.json'),'utf8'

app=express()
server=http.createServer app

app.configure ->
  app.use express.logger()
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    key:'dungeon-tiles.sid'
    secret:'The Man With No Name'

  app.use app.router

  app.use express.static 'static'

  app.use express.errorHandler()

for filename in fs.readdirSync path.join process.cwd(),'modules'
  obj=require path.join process.cwd(),'modules',name
  obj.initialize app,server,conf[path.basename(filename)]

server.listen conf.listen_port
