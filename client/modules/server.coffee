define 'server','jquery',(exports,$) ->
  exports.request=(name,method,content_type,args=null,catch_errors=true,callback) ->
    $.ajax
      url:name
      dataType:content_type
      data:args
      type:method
      success:(response) ->
        if catch_errors and response.server_error
          require 'ui',(ui) ->
            ui.error 'Error in '+url,response.server_error
        else
          callback?(response)
      error:(xhr,text_status,err) ->
        if catch_errors
          require 'ui',(ui) ->
            ui.error 'Communication error',text_status
        else
          callback?(null,text_status)

  exports.request_auth=(name,method,content_type,args=null,catch_errors=true,callback) ->
    require 'auth',(auth) ->
      auth.login -> exports.request name,method,content_type,args,catch_errors,callback

  exports.html=(name,callback) ->
    exports.request name,'GET','text',null,true,callback

  exports.get=(name,args=null,catch_errors=true,callback) ->
    exports.request '/api/'+name,'GET','json',args,catch_errors,callback
  exports.get_auth=(name,args=null,catch_errors=true,callback) ->
    exports.request_auth '/api/'+name,'GET','json',args,catch_errors,callback

  exports.post=(name,args=null,catch_errors=true,callback) ->
    exports.request '/api/'+name,'POST','json',args,catch_errors,callback
  exports.post_auth=(name,args=null,catch_errors=true,callback) ->
    exports.request_auth '/api/'+name,'POST','json',args,catch_errors,callback
