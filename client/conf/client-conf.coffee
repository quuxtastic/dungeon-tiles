window.CONF=

  core:
    require_ready_check_interval:10
    exports.asset_load_timeout:10000
    exports.require_max_cycles:1000

    overrides:
      'jquery':
        asset:[
          'https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js',
          '/js/jquery-1.8.2.min.js'
          ]
        resolve: ->
          window.jQuery.holdReady true
          return window.jQuery
      'socket.io':
        asset:['/socket.io/socket.io.js']
        resolve: -> window.io
      'jquery.cookie':
        asset:['/js/jquery.cookie.js']
        resolve: -> window.jQuery
      'jquery.ui':
        asset:['/js/jquery-ui-1.9.0.custom.min.js']
        resolve: -> window.jQuery
