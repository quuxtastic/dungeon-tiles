define 'server','jquery','ui',(exports,$,ui) ->
  exports.request=(name,method,args=null,catch_errors=true,callback) ->
    $.ajax
      url:'api/'+name
      dataType:'json'
      data:args
      type:method
      success:(response) ->
        if catch_errors and response.server_error
          ui.error 'Error in '+url,response.server_error
        else
          callback?(response)
      error:(xhr,text_status,err) ->
        if catch_errors
          ui.error 'Communication error',text_status
        else
          callback?(null,text_status)

  exports.get=(name,args=null,catch_errors=true,callback) ->
    exports.request name,'GET',args,catch_errors,callback
  exports.post=(name,args=null,catch_errors=true,callback) ->
    exports.request name,'POST',args,catch_errors,callback
