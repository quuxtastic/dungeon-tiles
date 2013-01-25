define 'store','jquery','jquery.cookie',(exports,$) ->
  class Store
    constructor: (@storage) ->

    ns: (namespace) -> new Namespace @storage,namespace

  class Namespace
    constructor: (@storage,@namespace) ->

    get: (name,def) ->
      v=@storage.getItem @namespace+name
      if def? and not v
        return def
      return v

    put: (name,value) -> @storage.setItem @namespace+name,value

    remove: (name) -> @storage.removeItem @namespace+name

    clear: -> @storage.clear()

  exports.session=new Store
    getItem:(key) -> $.cookie key
    setItem:(key,value) -> $.cookie key,value
    removeItem:(key) -> $.clearCookie key,null
    clear: ->

  exports.local=new Store window.localStorage
