os = require 'os'

mouse = 3

module.exports =

  activate: (state) ->
    atom.workspace.observeTextEditors (editor) =>
      @_handleLoad editor

  deactivate: ->
    @unsubscribe()

  _handleLoad: (editor) ->
    editorBuffer = editor.displayBuffer
    editorElement = atom.views.getView editor
    editorComponent = editorElement.component

    mouseStart  = null
    mouseEnd    = null
    previousRanges = null

    resetState = =>
      mouseStart  = null
      mouseEnd    = null

    onMouseDown = (e) =>
      if mouseStart
        e.preventDefault()
        return false

      if (e.which is mouse)
        resetState()
        if e.ctrlKey
          previousRanges = editor.getSelectedBufferRanges()
        else
          previousRanges = null
        mouseStart  = _screenPositionForMouseEvent(e)
        mouseEnd    = mouseStart
        e.preventDefault()
        return false

    onMouseMove = (e) =>
      if mouseStart
        if (e.which is mouse)
          mouseEnd = _screenPositionForMouseEvent(e)
          selectBoxAroundCursors()
          e.preventDefault()
          return false
        if e.which == 0
          resetState()

    onMouseUp = (e) =>
      if (e.which is mouse)
         if mouseStart == mouseEnd
            e.preventDefault()
            e.stopPropagation()
            atom.contextMenu.showForEvent(e)
            return false
         else
            e.preventDefault()
            e.stopPropagation()
            return false
      else
         return true

    # Hijack all the mouse events when selecting
    hijackMouseEvent = (e) =>
      if mouseStart
        e.preventDefault()
        e.stopPropagation()
        return false

    onBlur = (e) =>
      resetState()

    # I had to create my own version of editorComponent.screenPositionFromMouseEvent
    # The editorBuffer one doesnt quite do what I need
    _screenPositionForMouseEvent = (e) =>
      pixelPosition    = editorComponent.pixelPositionForMouseEvent(e)
      targetTop        = pixelPosition.top
      targetLeft       = pixelPosition.left
      defaultCharWidth = editorBuffer.defaultCharWidth
      row              = Math.floor(targetTop / editorBuffer.getLineHeightInPixels())
      targetLeft       = Infinity if row > editorBuffer.getLastRow()
      row              = Math.min(row, editorBuffer.getLastRow())
      row              = Math.max(0, row)
      column           = Math.round (targetLeft) / defaultCharWidth
      return {row: row, column: column}

    # Do the actual selecting
    selectBoxAroundCursors = =>
      if mouseStart and mouseEnd
        allRanges = []
        if previousRanges
          allRanges = previousRanges
        rangesWithLength = []

        for row in [mouseStart.row..mouseEnd.row]
          # Define a range for this row from the mouseStart column number to
          # the mouseEnd column number
          range = editor.bufferRangeForScreenRange [[row, mouseStart.column], [row, mouseEnd.column]]

          allRanges.push range

        for range in allRanges
          if editor.getTextInBufferRange(range).length > 0
            rangesWithLength.push range

        # If there are ranges with text in them then only select those
        # Otherwise select all the 0 length ranges
        if rangesWithLength.length
          editor.setSelectedBufferRanges rangesWithLength
        else if allRanges.length
          editor.setSelectedBufferRanges allRanges

    # Subscribe to the various things
    editorElement.onmousedown   = onMouseDown
    editorElement.onmousemove   = onMouseMove
    editorElement.onmouseup     = onMouseUp
    editorElement.onmouseleave  = hijackMouseEvent
    editorElement.onmouseenter  = hijackMouseEvent
    editorElement.oncontextmenu = hijackMouseEvent
    editorElement.onblur        = onBlur
