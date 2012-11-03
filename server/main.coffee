express=require 'express'
http=require 'http'
fs=require 'fs'
path=require 'path'

core=require './core'

conf=JSON.parse fs.readFileSync path.join(process.cwd(),'conf/server.json'),'utf8'

conf.listen_port=process.env.PORT

app=express()
server=http.createServer app

app.configure ->
  sessionStore=new express.session.MemoryStore()
  app.set 'session-store',sessionStore

  app.use express.logger()
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    store:sessionStore
    key:'dungeon-tiles.sid'
    secret:'The Man With No Name'

  app.use app.router

  app.use express.static path.join process.cwd(),'static'

  app.use express.errorHandler()

for filename in fs.readdirSync path.join process.cwd(),'server','modules'
  obj=require path.join process.cwd(),'server','modules',filename

core.init_modules app,server,conf

server.listen conf.listen_port
