express=require 'express'
http=require 'http'

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

  app.use express.static ''

  app.use express.errorHandler()

server.listen 8080

