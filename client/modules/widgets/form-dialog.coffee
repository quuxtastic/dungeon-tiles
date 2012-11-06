define 'prompt-dialog','jquery',(exports,$) ->
  exports.ui_options=
    can_close:false
    modal:true
    show_in_window_list:false

  validate=(dlg,callback) ->
    errors=[]
    dlg.find('input').each (item) ->
      val=item.val()
      properties=item.data 'properties'

      if not val? or val==''
        if properties.required
          errors.push properties.display+' is required'
      else
        if properties.type=='int'
          n=parseInt val
          if isNaN n
            errors.push properties.display+' is not an integer'
          else
            if properties.max?
              if n>properties.max
                errors.push properties.display+' is greater than maximum '+properties.max
            if properties.min?
              if n<properties.min
                errors.push properties.display+' is less than minimum '+properties.min
        if properties.type=='float'
          n=parseFloat val
          if isNaN n
            errors.push properties.display+' is not a decimal'
          else
            if properties.max?
              if n>properties.max
                errors.push properties.display+' is greater than maximum '+properties.max
            if properties.min?
              if n<properties.min
                errors.push properties.display+' is less than minimum '+properties.min
        else if properties.maxlen?
          if val.length>properties.maxlen
            errors.push properties.display+' must be less than '+properties.maxlen+' characters'

    callback errors

  exports.initialize=(dlg,options) ->
    dlg.find('.dlg-message').html options.message
    dlg.button 'OK', ->
      error_list=dlg.find '.prompt-errors'
      error_list.html ''

      validate dlg,(errors) ->
        if errors.length>0
          for error in errors
            error_list.append '<p>'+error+'</p>'
        else
          dlg.close()
          options.callback true,dlg

    if options.can_cancel
      dlg.close()
      dlg.button 'Cancel', -> callback false,dlg

    fieldset=dlg.find 'fieldset'
    for field_name,properties of options.fields
      $('<label>'+properties.display+'</label>')
        .attr 'for',field_name
        .appendTo fieldset

      $('<input type="text" name="'+field_name+'"/>')
        .addClass 'text ui-widget-content ui-corner-all'
        .data 'properties',properties
        .appendTo fieldset

    dlg.open()

    return options.title
