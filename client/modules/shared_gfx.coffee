define 'shared_gfx','jquery','websocket',(exports,$,io) ->
  exports.create_context=(name,canvas) ->
    new SharedContext name,canvas.getContext '2d'

  SharedContext=(name,ctx) ->
    @sync= -> updates.flush()

    @live=(mode) -> do_live_updates=mode

    @brush=(id) -> brushes[id]

    @create_brush=(args...) ->
      brush=new Brush args...
      brushes[brush.id()]=brush
      return brush

    @begin_path= ->
      ctx.beginPath()
      updates.push
        m:BEGIN_PATH

    @end_outline= ->
      ctx.stroke()
      updates.push
        m:END_OUTLINE

    @end_fill= ->
      ctx.fill()
      updates.push
        m:END_FILL

    @line_to=(x,y) ->
      ctx.lineTo x,y
      updates.push
        m:LINE_TO
        x:x
        y:y

    @line_close= ->
      ctx.closePath()
      updates.push
        m:LINE_CLOSE

    @move_to=(x,y) ->
      ctx.moveTo x,y
      updates.push
        m:MOVE_TO
        x:x
        y:y

    @rect=(x,y,w,h,mode) ->
      if mode=='fill'
        ctx.fillRect x,y,w,h
      else if mode=='outline'
        ctx.strokeRect x,y,w,h
      else if mode=='clear'
        ctx.clearRect x,y,w,h
      updates.push
        m:RECT
        x:x
        y:y
        w:w
        h:h
        mode:mode

    @blit=(img,x,y,sw,sh,dx,dy,dw,dh) ->
      ctx.drawImage img,x,y,sw,sh,dx,dy,dw,dh
      updates.push
        m:BLIT
        x:x
        y:y
        sw:sw
        sh:sh
        dx:dx
        dy:dy
        dw:dw
        dh:dh
        img:img

    updates= ->
      @push=(obj) ->
        buf.push obj
        if do_live_updates
          flush()

      @flush= ->
        for u in updates
          s=JSON.stringify u
          write_int s.length
          write_string s

      write_string=(s) ->
        chars_left=s.length
        while chars_left>0
          n=Math.max chars_left,MAX_UPDATE_SIZE
          socket.write s.substr 0,n
          s.splice 0,n
          chars_left-=n

      write_int=(n) ->
        #

    brush_counter=0
    Brush=(fill,outline,alpha,width,cap,join,miter) ->
      id=brush_counter++
      @uid= -> id
      @apply= ->
        ctx.fillStyle=fill
        ctx.strokeStyle=outline
        ctx.globalAlpha=alpha
        ctx.lineWidth=width
        ctx.lineCap=cap
        ctx.lineJoin=join
        ctx.miterLimit=miter

        updates.push
          m:APPLY_BRUSH
          id:id

      updates.push
        m:ADD_BRUSH
        id:id
        fill:fill
        outline:outline
        alpha:alpha
        width:width
        cap:cap
        join:join
        miter:miter

    brushes={}
    brushes[0]=new Brush 0,'black','black',1,

