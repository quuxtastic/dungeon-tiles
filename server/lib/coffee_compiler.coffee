path=require 'path'
fs=require 'fs'
proc=require 'child_process'
conf=require('../core').conf
coffee=require 'coffee-script'

exports.compile=(names...,callback) ->
  for name in names
    module_name=path.basename name
    module_subpath=path.dirname name

    src=path.join conf.compiler.src_path,'modules',module_subpath,module_name+'.coffee'

    try
      #src_js="""
      #  (function() {
      #    var CONF={};
      #    (function(exports) {
      #      """+coffee.compile(conf.compiler.client_conf_path,{bare:yes})+"""
      #    }).call(this,CONF);
      #    """+coffee.compile(src,{bare:yes})+"""
      #  }).call(this);
      #"""
      src_js=coffee.compile src

      callback null,src_js
    catch err
      callback err
