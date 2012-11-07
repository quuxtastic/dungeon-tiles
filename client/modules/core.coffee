window.require=(dependencies...,body) ->
  for dep in dependencies
    load_dep dep

  iid=null
  ready_interval= ->
    my_deps=[]
    for dep in dependencies
      if modules[dep]?
        my_deps.push modules[dep]
      else
        return

    clearInterval iid
    body?(my_deps...)
  iid=setInterval ready_interval,100

window.define=(name,dependencies...,body) ->
  console.log name+' dependencies:'
  console.dir [dependencies...]
  require dependencies...,(deps...) ->
    exports={}
    body?(exports,deps...)

    modules[name]=exports

modules={}

load_script=(url,callback) ->
  tag=document.createElement 'script'
  tag.type='text/javascript'
  tag.charset='utf-8'
  tag.async=true
  tag.src=url
  onload=(evt) ->
    if evt.type=='load'
      onload.fired=true
      evt.srcElement.removeEventListener 'load',onload,false
      callback?(evt)
  tag.addEventListener 'load',onload,false

  document.getElementsByTagName('head')[0].appendChild tag

  ontimeout= ->
    if not onload.fired
      console.log 'Failed to load '+url
      tag.removeEventListener 'load',onload,false
      callback?(null)
  window.setTimeout ontimeout,1000

do_once={}
load_dep=(name,callback) ->
  if do_once[name]?
    return
  do_once[name]=true

  if name=='jquery'
    url='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'
    load_script url,(evt) ->
      if evt?
        window.jQuery.holdReady true
        modules['jquery']=window.jQuery
        load_script 'js/jquery-ui-1.9.0.custom.min.js'
      else
        load_script 'js/jquery-1.8.2.min.js', ->
          window.jQuery.holdReady true
          modules['jquery']=window.jQuery
          load_script 'js/jquery-ui-1.9.0.custom.min.js'

  else if name=='socket.io'
    load_script '/socket.io/socket.io.js', ->
      modules['websocket']=window.io

  else
    load_script 'api/load/'+name, ->
      callback?(name)

require 'jquery','ui','init',($) ->
  $.holdReady false
