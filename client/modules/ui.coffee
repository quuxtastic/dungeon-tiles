define 'ui','jquery','store','util',(exports,$,store,util) ->
  class Window
    constructor: (@_root) ->

    get: (name) -> @_root.find('[name="'+name+'"]').val()
    set: (name,value) -> @_root.find('[name="'+name+'"]').val value

    find: (selector) -> @_root.find selector

    show: -> @_root.show()
    hide: -> @_root.hide()





  exports.add_widget=(name,html) -> widgets[name]=html

  exports.create_window=(title,content,options) ->
    prefs=store.local.ns 'ui.prefs.window.'+name
    w=$('<div id="window_'+name+'"></div>')
      .attr('title',title)
      .append(content)
      .dialog
        autoOpen:false
        modal:options.modal
        draggable:not options.fixed
        resizable:not options.fixed
        closeOnEscape:options.can_close
        dialogClass:if options.can_close then '' else 'no-close'
        buttons:if options.buttons then options.buttons else {}

    if options.has_list_entry
      w
        .on('close', ->
          window_list_menu.option title,null)
        .on('open', ->
          window_list_menu.option title,$(this))

      windows[options.name]=w

    if options.save_state
      w.option('height',prefs.get('h','auto'))
        .option('width',prefs.get('w','auto'))
        .option('position',prefs.get('pos','center'))
        .on('dragStop',(event,ui) ->
          prefs.put 'pos',ui.position)
        .on('resizeStop',(event,ui) ->
          prefs.put 'pos',ui.position
          prefs.put 'w',ui.size.width
          prefs.put 'h',ui.size.height)

    return w

  exports.get_window=(name) -> windows[name]

  exports.windows= -> (k for k of windows)

  exports.create_message=(title,message,icon_type) ->
    exports.widget 'message_dlg',{'icon':icon_type},(widget) ->
      widget.append message
      exports.create_window title,widget,
        modal:true
        can_close:false
        buttons:
          'OK': -> $(this).dialog 'close'

  exports.error=(title,message) ->
    exports.create_message title,message,'ui-icon-alert'

  exports.info=(title,message) ->
    exports.create_message title,message,'ui-icon-info'

  exports.create_prompt=(title,message,buttons,fields) ->
    fieldset=$ '<fieldset></fieldset>'
    for k,v of fields
      $('<label>'+v+'</label>')
        .attr('for',k)
        .appendTo(fieldset)
      $('<input type="text" name="'+k+'" id="'+k+'"/>')
        .class('text')
        .class('ui-widget-content')
        .class('ui-corner-all')

    exports.widget 'form_dlg',(widget) ->
      widget.find('fieldset').append fieldset
      exports.create_window title,widget,
        modal:true
        can_close:false
        buttons:buttons

  exports.widget=(name,arg_map=null,callback) ->
    if widgets[name]
      callback $('<div></div>')
        .html(util.format widgets[name],arg_map)
    else
      require 'widget/'+name,(obj) ->
        widgets[name]=obj.html
        callback $('<div></div>')
          .html(util.format obj.html,arg_map)

  windows={}
  window_list_menu=null

  widgets={}

  $ ->
    window_list_menu=$('<ul></ul>').menu
      select:(event,ui) -> ui.item.dialog 'focus'
    exports.create_window 'Window List',window_list_menu,
      name:'window-list'
      modal:false,
      can_close:false,
      save_state:true
