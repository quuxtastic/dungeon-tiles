window.require=(dependencies...,body) ->
  for dep in dependencies
    load_dep dep

  iid=null
  count=0
  ready_interval= ->
    my_deps=[]
    for dep in dependencies
      if modules[dep]?
        my_deps.push modules[dep]
      else
        if count++>CONF.core.require_max_cycles
          console.error 'ERROR: Timed out waiting for dependencies: '+dependencies.toString()
        return

    clearInterval iid
    body?(my_deps...)
  iid=setInterval ready_interval,CONF.core.require_ready_check_interval

window.define=(name,dependencies...,body) ->
  require dependencies...,(deps...) ->
    exports={}
    body?(exports,deps...)

    if module[name]?
      console.log 'WARNING: Duplicate define() for '+name
    modules[name]=exports

modules={}

load_script=(url,callback) ->
  tag=document.createElement 'script'
  tag.type='text/javascript'
  tag.charset='utf-8'
  tag.async=true
  tag.src=url
  tag.defer=true
  onload=(evt) ->
    if evt.type=='load'
      onload.fired=true
      evt.srcElement.removeEventListener 'load',onload,false
      callback?(evt)
  tag.addEventListener 'load',onload,false

  document.getElementsByTagName('head')[0].appendChild tag

  ontimeout= ->
    if not onload.fired
      console.error 'WARNING: Failed to load asset "'+url+'"'
      tag.removeEventListener 'load',onload,false
      callback?(null)
  window.setTimeout ontimeout,CONF.core.asset_load_timeout

do_once={}
load_dep=(name,callback) ->
  if do_once[name]?
    return
  do_once[name]=true

  if CONF.core.overrides[name]?
    load_recursive=(ind) ->
      load_script CONF.core.overrides[name].asset[ind],(evt) ->
        if evt?
          modules[name]=CONF.core.overrides[name].resolve()
          callback?(name)
        else if ind+1<CONF.core.overrides[name].asset.length
          load_recursive ++ind
    load_recursive 0
  else
    load_script '/api/load/'+name, -> callback?(name)


  #if name=='jquery'
    #url='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'
    #load_script url,(evt) ->
      #if evt?
        #window.jQuery.holdReady true
        #modules['jquery']=window.jQuery
        #load_script '/js/jquery-ui-1.9.0.custom.min.js'
      #else
        #load_script '/js/jquery-1.8.2.min.js', ->
          #window.jQuery.holdReady true
          #modules['jquery']=window.jQuery
          #load_script 'js/jquery-ui-1.9.0.custom.min.js'
#
  #else if name=='socket.io'
    #load_script '/socket.io/socket.io.js', ->
      #modules['socket.io']=window.io
#
  #else if name=='jquery.cookie'
    #require 'jquery', ->
      #load_script '/js/jquery.cookie.js',->
        #modules['jquery.cookie']=modules['jquery']
#
  #else
    #load_script '/api/load/'+name, ->
      #callback?(name)

require 'jquery','ui',CONF.init...,($) ->
  $.holdReady false
