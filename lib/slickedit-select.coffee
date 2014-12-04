{Subscriber} = require 'emissary'
os = require 'os'

mouse = 3

module.exports =

  activate: (state) ->
    @subscribe atom.workspaceView.eachEditorView (editorView) =>
      @_handleLoad editorView

  deactivate: ->
    @unsubscribe()

  _handleLoad: (editorView) ->
    editor     = editorView.getEditor()

    mouseStart  = null
    mouseEnd    = null
    columnWidth = null

    resetState = =>
      mouseStart  = null
      mouseEnd    = null
      columnWidth = null

    onMouseDown = (e) =>
      if mouseStart
        e.preventDefault()
        return false
      if (e.which is mouse)
        resetState()
        columnWidth = calculateMonoSpacedCharacterWidth()
        mouseStart  = overflowableScreenPositionFromMouseEvent(e)
        mouseEnd    = mouseStart
        e.preventDefault()
        return false

    onMouseMove = (e) =>
      if mouseStart
        if (e.which is mouse)
          mouseEnd = overflowableScreenPositionFromMouseEvent(e)
          selectBoxAroundCursors()
          e.preventDefault()
          return false
        if e.which == 0
          resetState()

    onMouseUp = (e) =>
      if (e.which is mouse)
         if mouseStart == mouseEnd
           e.preventDefault()
           atom.contextMenu.showForEvent(e)
           return false
         else
           e.preventDefault()
           return false

    # Hijack all the mouse events when selecting
    hijackMouseEvent = (e) =>
      if mouseStart
        e.preventDefault()
        return false

    onFocusOut = (e) =>
      resetState()

    # Create a span with an x in it and measure its width then remove it
    calculateMonoSpacedCharacterWidth = =>
      span = document.createElement 'span'
      span.appendChild document.createTextNode('x')
      editorView.scrollView.append span
      size = span.offsetWidth
      span.remove()
      return size

    # I had to create my own version of editorView.screenPositionFromMouseEvent
    # The editorView one doesnt quite do what I need
    overflowableScreenPositionFromMouseEvent = (e) =>
      { pageX, pageY }  = e
      offset            = editorView.scrollView.offset()
      editorRelativeTop = pageY - offset.top + editorView.scrollTop()
      row               = Math.floor editorRelativeTop / editorView.lineHeight
      column            = Math.round (pageX - offset.left) / columnWidth
      return {row: row, column: column}

    # Do the actual selecting
    selectBoxAroundCursors = =>
      if mouseStart and mouseEnd
        allRanges = []
        rangesWithLength = []

        for row in [mouseStart.row..mouseEnd.row]
          # Define a range for this row from the mouseStart column number to
          # the mouseEnd column number
          range = editor.bufferRangeForScreenRange [[row, mouseStart.column], [row, mouseEnd.column]]

          allRanges.push range
          if editor.getTextInBufferRange(range).length > 0
            rangesWithLength.push range

        # If there are ranges with text in them then only select those
        # Otherwise select all the 0 length ranges
        if rangesWithLength.length
          editor.setSelectedBufferRanges rangesWithLength
        else
          editor.setSelectedBufferRanges allRanges

    # Subscribe to the various things
    @subscribe editorView, 'mousedown',   onMouseDown
    @subscribe editorView, 'mousemove',   onMouseMove
    @subscribe editorView, 'mouseup',     onMouseUp
    @subscribe editorView, 'mouseleave',  hijackMouseEvent
    @subscribe editorView, 'mouseenter',  hijackMouseEvent
    @subscribe editorView, 'contextmenu', hijackMouseEvent
    @subscribe editorView, 'focusout',    onFocusOut

Subscriber.extend module.exports
