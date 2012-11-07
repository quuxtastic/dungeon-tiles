define 'ui','jquery','store','util','server',(exports,$,store,util,srv) ->
  windows={}

  class Window
    constructor: (@_module,mixin_options) ->
      opts=util.merge @_module.ui_options,mixin_options
      @_dlg=$('<div id="window+'+util.uid()+'"></div>')
        .html(@_module._html)
        .dialog
          autoOpen:false
          title:opts.title
          modal:opts.modal
          draggable:not opts.fixed
          resizable:not opts.fixed
          closeOnEscape:opts.can_close
          dialogClass:(if opts.can_close then null else 'no-close')
          width:'auto'
          height:'auto'
          position:'center'

      if opts.show_in_window_list
        @_dlg.on 'close', -> exports.window('window_list').remove this
        @_dlg.on 'open', -> exports.window('window_list').add this,opts.title

      if opts.save_state
        prefs=store.local.ns 'ui.prefs.window.'+@_module.name
        @_dlg.dialog 'option','height',prefs.get('h','auto')
        @_dlg.dialog 'option','width',prefs.get('w','auto')
        @_dlg.dialog 'option','position',prefs.get('pos','center')
        @_dlg.on 'dragStop',(event,ui) -> prefs.put('pos',ui.position)
        @_dlg.on 'resizeStop',(event,ui) ->
          prefs.put 'pos',ui.position
          prefs.put 'w',ui.size.width
          prefs.put 'h',ui.size.height

      @_name=@_module.initialize this,opts
      windows[name]=this

    name: -> @_name

    get: (name) -> @_dlg.find('[name="'+name+'"]').val()
    set: (name,value) -> @_dlg.find('[name="'+name+'"]').val value

    find: (selector) -> @_dlg.find selector

    open: -> @_dlg.dialog 'open'
    close: -> @_dlg.dialog 'close'

    focus: -> @_dlg.dialog 'moveToTop'

    title: (new_title) -> @_dlg.dialog 'option','title',new_title

    buttons: (btnmap) ->
      buttonset=@_dlg.parent().find('.ui-dialog-buttonset')
      for display_text,click_callback of btnmap
        id='btn'+util.uid()
        btn=$ '<span class="ui-button-text dynamic-button" id="'+id+'">'+display_text+'</span>'
        buttonset.append btn
        btn.button().click -> click_callback this

    button: (name,callback) -> @buttons {name:callback}

    on: (event,callback) ->
      @_dlg.on event,(event,ui) ->
        callback event,ui,this

  widget_cache={}

  on_create={}
  exports.create_window=(widget_name,mixin_options={},callback=null) ->
    if widget_cache[widget_name]?
      wnd=new Window widget_cache[widget_name],mixin_options
      callback?(wnd)
      if on_create[wnd.name()]?
        for f in on_create[wnd.name()]
          f wnd
    else
      require 'widgets/'+widget_name,(widget) ->
        srv.html '/widgets/'+widget_name+'.html',(html) ->
          widget._html=html
          widget_cache[widget_name]=widget
          wnd=new Window widget,mixin_options
          callback?(wnd)
          if on_create[wnd.name()]?
            for f in on_create[wnd.name()]
              f wnd

  exports.window=(name,callback) ->
    if windows[name]
      callback windows[name]
    else
      if not on_create[name]?
        on_create[name]=[]
      on_create[name].push callback

  exports.message=(title,message,icon_type,close_callback) ->
    opts=
      title:title
      icon:icon_type
      message:message
      on_close:close_callback
    exports.create_window 'message-dialog',opts

  exports.error=(title,message,close_callback) ->
    exports.message title,message,'ui-icon-alert',close_callback

  exports.prompt=(title,message,fields,can_cancel=true,callback) ->
    opts=
      title:title
      message:message
      fields:fields
      callback:callback
      can_cancel:can_cancel
    exports.create_window 'form-dialog',opts

  $ ->
    exports.create_window 'window_list'
