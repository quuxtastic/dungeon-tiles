define 'store',(exports) ->
  exports.session=new Store window.SessionStorage
  exports.local=new Store window.localStorage

  Store=(storage) ->
    @ns(namespace)= ->
      @put=(name,value) -> storage.setItem namespace+name,value
      @get=(name,def) ->
        v=storage.getItem namespace+name
        if def? and not v
          return def
        return v
      @remove=(name) -> storage.removeItem namespace+name

      @clear= -> storage.clear()
