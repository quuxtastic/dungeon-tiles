define 'ui','jquery','local-storage',(exports,$,localstorage) ->
  exports.create_window=(name,title,content,buttons) ->
    if not buttons
      buttons={}
    prefs=localstorage.ns 'ui.prefs.window.'+name
    w=$ '<div id="window_'+name+'"></div>'
      .attr 'title',title
      .append content
      .dialog
        closeOnEscape:false
        dialogClass:'no-close'
        height:prefs.get 'h','auto'
        width:prefs.get 'w','auto'
        position:[prefs.get('x',0),prefs.get('y',0)]
      .on 'dragStop',(event,ui) ->
        prefs.put 'x',ui.position.x
        prefs.put 'y',ui.position.y
      .on 'resizeStop',(event,ui) ->
        prefs.put 'x',ui.position.x
        prefs.put 'y',ui.position.y
        prefs.put 'w',ui.size.width
        prefs.put 'h',ui.size.height
      .on 'close', ->
        window_list_menu.option title,null
      .on 'open', ->
        window_list_menu.option title,w
    windows[name]=w
    return w

  exports.get_window=(name) -> windows[name]

  exports.windows= ->
    out=[]
    for k of windows
      out.push[k]

  windows={}
  window_list_menu=null

  $ ->
    window_list_menu=$('<ul></ul>').menu()
    exports.create_window 'window-list','Windows',window_list_menu
