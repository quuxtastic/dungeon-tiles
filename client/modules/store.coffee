define 'store',(exports) ->
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

  exports.session=new Store window.sessionStorage
  exports.local=new Store window.localStorage
