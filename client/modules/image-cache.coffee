define 'image-cache','jquery',(exports,$) ->
  exports.load_url=(url,cross_origin_mode,callback) ->
    if cache[url]?
      callback cache[url]
    else
      img=new Image()
      img.onload= ->
        cache[url]=img
        callback img
      if cross_origin_mode
        img.crossOrigin=cross_origin_mode
      img.src=url

  exports.load_embed=(base64,callback) ->
    exports.load_url 'data:image/gif;base64,'+base64,null,callback

  cache={}
