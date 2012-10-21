define 'server','jquery','ui',(exports,$,ui) ->
  exports.request=(name,args=null,catch_errors=true,callback) ->
    $.ajax
      url:'api/'+name
      dataType:'json'
      data:args
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
