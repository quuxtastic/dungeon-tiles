define 'util',(exports) ->
  exports.delay=(ms,callback) ->
    setTimeout ms,callback (new_ms=ms,new_callback=callback) ->
      exports.delay new_ms,new_callback

  exports.timeout=(ms,callback) ->
    tid=setTimeout ms, ->
      callback
    return -> clearTimeout tid

  exports.interval=(ms,callback) ->
    id=setInterval ms,callback id
    return id

  exports.stop_interval=(id) ->
    clearInterval id

  exports.strf=(s,args...) ->
    cur_arg=0
    s.replace /%(\w)/g,(match,type) ->
      arg=args[cur_arg++] ? 'undefined'
      return arg.toString()

  uid_counter=0
  exports.uid= -> uid_counter++

  exports.merge=(sources...) ->
    out={}
    for obj in sources
      for k,v of obj
        if obj.hasOwnProperty k
          out[k]=v

    return out

  exports.copy=(src,dest) ->
    for k,v of src
      if src.hasOwnProperty k
        dest[k]=v
