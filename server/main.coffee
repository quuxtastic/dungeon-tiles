express=require 'express'
http=require 'http'
fs=require 'fs'
path=require 'path'
cookies=require 'cookies'

core=require './core'

app=express()
server=http.createServer app

core._set_server server
core._set_app app

app.configure ->
  sessionStore=new express.session.MemoryStore()
  app.set 'session-store',sessionStore

  app.set 'views',path.join process.cwd(),'server','views'
  app.engine '.html',require('./lib/view_engine').render

  app.use express.logger
    immediate:true
    format:'dev'
  app.use express.cookieParser()
  app.use express.session
    store:sessionStore
    key:'dungeon-tiles.sid'
    secret:'The Man With No Name'
  app.use express.bodyParser()

  app.use cookies.express()

  app.use app.router

  app.use express.static path.join process.cwd(),'static'

  express.errorHandler.title='dungeon-tiles'
  app.use express.errorHandler()

for filename in fs.readdirSync path.join process.cwd(),'server','modules'
  require path.join process.cwd(),'server','modules',filename

server.listen core.conf.server.port
