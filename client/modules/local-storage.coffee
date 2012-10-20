define 'local-storage',(exports) ->
  exports.ns(namespace)= ->
    @put=(name,value) -> localStorage.setItem namespace+name,value
    @get=(name,def) ->
      v=localStorage.getItem namespace+name
      if def? and not v
        return def
      return v
    @remove=(name) -> localStorage.removeItem namespace+name

    @clear= -> localStorage.clear()
