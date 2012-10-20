define 'screen','jquery',(exports,$) ->
  exports.screen=(name,container,x,y,w,h) ->
    s=new Screen container,x,y,w,h
    screens[name]=s
    return s

  exports.get_screen=(name) -> screens[name]

  Screen=(container,x,y,w,h) ->
    Layer=(name,z) ->
      @name= -> name
      @z_index= -> z

      @move=(mode) ->
        if mode=='front'
          tmp=layers[layers.length-1]
          layers[layers.length-1]=this
          layers[z]=tmp
        else if mode=='back'
          tmp=layers[0]
          layers[0]=this
          layers[z]=tmp
        else
          n=Math.max mode,layers.length-z
          tmp=layers[n]
          layers[n]=this
          layers[z]=tmp
        re_order()

      @remove= ->
        _canvas.remove()
        remove_layer z

      @context= -> ctx

      @_set_pos=(new_pos) ->
        z=new_pos
        canvas.css 'z-index',z

      @_element= -> canvas

      canvas=$ '<canvas id="canvas_layer_'+name+'"></canvas>'
        .attr 'width',w
        .attr 'height',h
        .css 'position','absolute'
        .css 'left',x+'px'
        .css 'top',y+'px'
        .css 'z-index',z
        .appendTo container
      ctx=canvas.getContext '2d'

    @layer=(name,pos,ref_layer) ->
      if pos=='front'
        layers.push new Layer name,layers.length
      else if pos=='back'
        layers.splice 0,0,new Layer name,0
      else if pos=='before'
        layers.splice offset,0,new Layer name,get(ref_layer).z_index()
      else if pos=='after'
        layers.splice offset+1,0,new Layer name,get(ref_layer).z_index()+1

      re_order()

      return new_layer

    @front= -> layers[layers.length-1]
    @back= -> layers[0]

    @get=(name) ->
      for layer in layers
        if layer.name()==name
          return layer
      return null

    @move=(dx,dy) ->
      for layer in layers
        layer._element().css 'left',x+'px'
        layer._element().css 'top',y+'px'

    @resize=(new_w,new_h) ->
      for layer in layers
        layer._element().attr 'width',new_w
        layer._element().attr 'height',new_h

    layers=[]

    # used internally by Layer
    remove_layer=(pos) ->
      delete layers[pos]
      layers.splice pos,1
      re_order()

    re_order= ->
      cur_z=0
      for layer in layers
        layer._set_pos cur_z++

  screens={}

