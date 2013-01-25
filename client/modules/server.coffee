define 'server','jquery',(exports,$) ->
  exports.request=(name,method,content_type,args=null,callback) ->
    $.ajax
      url:name
      dataType:content_type
      data:args
      type:method
      success:(response) ->
        if exports.catch_api_errors and response.error
          log.error 'API error %s(%s)\n%s',url,args,response.error
          require 'ui',(ui) ->
            ui.error 'Error','Error calling %s(%s)<br><br>%s',url,args,response.error

        callback?(response.error,response)

      error:(xhr,text_status,err) ->
        if exports.catch_transport_errors
          log.error 'Ajax error %s(%s)\n%s: %s',url,args,text_status,err
          require 'ui',(ui) ->
            ui.error 'Communication error','%s(%s) returned %s<br><br>%s',url,args,text_status,err

        callback?(err)

  exports.html=(name,args=null,callback) ->
    exports.request name,'GET','text',args,callback

  exports.get=(name,args=null,callback) ->
    exports.request '/api/'+name,'GET','json',args,callback
  exports.post=(name,args=null,callback) ->
    exports.request '/api/'+name,'POST','json',args,callback

  exports.catch_transport_errors=true
  exports.catch_api_errors=true
