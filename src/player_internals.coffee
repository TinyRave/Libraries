SAMPLE_RATE = 44100
AUDIO_BUFFER_SIZE = 4096
STD_LIBRARY = 'importScripts("http://tinyrave.com/lib/v1/adapter.js", "http://tinyrave.com/lib/v1/stdlib.js");'

# Unlock audio context for mobile safari
@globalAudioContext ||= new (window.AudioContext || window.webkitAudioContext)()
@audioContextUnlocked = false
window.addEventListener('touchend', (
  =>
    unless @audioContextUnlocked
      buffer = @globalAudioContext.createBuffer(1, 1, 22050)
      source = @globalAudioContext.createBufferSource()
      source.buffer = buffer

      source.connect(@globalAudioContext.destination)
      source.noteOn(0)
    @audioContextUnlocked = true
), false)


# Given some source code, this will make an effort to have 1 frame of
# audio available for the AudioContext.
class @AudioWorker
  constructor: (source) ->
    blob = new Blob([source])

    @worker = new Worker(URL.createObjectURL(blob))
    @worker.onmessage = @_workerMessage
    @workerInitialized = false # Have we received our first frame

    if window.yieldWorker
      # Allows us to add a native error handler in Atom
      window.yieldWorker(@worker)

  requestFrame: ->
    @worker.postMessage(["generate"])

  pop: ->
    # Here's the sequence of events:
    # 1. Start system audio
    # 2. Start web worker, request first audio frame
    # 3. Feed blank frames to system audio while waiting for worker to produce
    #    audio.
    # 4. After generating its first frame we expect the worker to keep up with
    #    realtime demands. Show a warning if it can't.
    # 5. There's an extra principle here to not spin the worker clock so never
    #    queue multiple "generate" requests when we only need one frame.

    buffer = @_buffer
    @_buffer = null

    if buffer
      @workerInitialized = true
      @requestFrame()
    else
      if @workerInitialized
        console.log("Not producing audio fast enough.")
        # If on iOS kill the audio context. There's a bug where returning a single
        # frame of 0's puts the system audio in an unusable / muted state. I
        # haven't looked into it thoroughly. This is a temporary workaround to
        # reduce the severity of the bug.
        # http://stackoverflow.com/questions/9038625/detect-if-device-is-ios
        if navigator && window
          if /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
            window.player.pause()

      buffer = new Float64Array(AUDIO_BUFFER_SIZE * 2)
      buffer.fill 0

    buffer

  terminate: ->
    @worker.terminate()

  _workerMessage: (message) =>
    switch message.data[0]
      when "buffer"
        @_buffer = message.data[1]
      when "log"
        console.log message.data[1]
      else
        console.log "Worker message received. Arguments:"
        console.log message.data


class @AudioWrapper
  setTrackByURL: (url) ->
    $.ajax(url: url).done (data) =>
      @setTrackSource(data["source"], data["duration"]) if data["source"]
      @play()

  setTrackSource: (compiledSource, duration) ->
    unless duration?
      console.error "Must specify duration"
      return
    duration = parseFloat(duration)
    # Disconnect source. Terminate existing worker.
    # Create worker.
    try @_audioSource.disconnect()
    try @_audioAnalyser.disconnect()
    @_elapsedTime = 0
    @_nextCalled = false
    @_worker.terminate() if @_worker
    @_worker = new AudioWorker(STD_LIBRARY + compiledSource)
    @_worker.requestFrame()
    @_audioSource = globalAudioContext.createScriptProcessor(AUDIO_BUFFER_SIZE, 0, 2)
    @_audioSource.onaudioprocess = (event) =>
      left  = event.outputBuffer.getChannelData(0)
      right = event.outputBuffer.getChannelData(1)
      nextBuffer = @_worker.pop()
      for i in [0...left.length]
        left[i]  = nextBuffer[ i*2 ]
        right[i] = nextBuffer[ i*2+1 ]
      @_elapsedTime += AUDIO_BUFFER_SIZE / SAMPLE_RATE
      if @_elapsedTime > duration
        @guardedNext()
    @_audioAnalyser = globalAudioContext.createAnalyser()

  guardedNext: ->
    window.player.next() unless @_nextCalled
    @_nextCalled = true

  play: ->
    if @_audioSource?
      @_audioSource.connect(@_audioAnalyser)
      @_audioAnalyser.connect(globalAudioContext.destination)
      @visualize()

  visualize: ->
    # From https://github.com/mdn/voice-change-o-matic/blob/gh-pages/scripts/app.js#L128-L205
    el = document.getElementById('audio_visualizer')
    if el?
      WIDTH = parseInt(el.getAttribute('width'))
      HEIGHT = parseInt(el.getAttribute('height'))
      BG_COLOR = el.getAttribute('data-bg-color')
      LINE_COLOR = el.getAttribute('data-line-color')
      @_audioAnalyser.fftSize = AUDIO_BUFFER_SIZE;
      bufferLength = @_audioAnalyser.fftSize;
      dataArray = new Uint8Array(bufferLength)

      canvasCtx = el.getContext('2d')
      canvasCtx.clearRect(0, 0, WIDTH, HEIGHT)

      draw = =>
        drawVisual = requestAnimationFrame(draw)
        @_audioAnalyser.getByteTimeDomainData(dataArray)

        showClipWarning = false
        for i in [0...bufferLength]
          loudness = dataArray[i]
          if loudness == 255.0 || loudness == 0
            showClipWarning = true
            break

        canvasCtx.fillStyle = BG_COLOR
        canvasCtx.fillRect(0, 0, WIDTH, HEIGHT)

        canvasCtx.lineWidth = 1
        if showClipWarning
          # Red line!
          canvasCtx.strokeStyle = "rgb(255, 0, 0)"
        else
          canvasCtx.strokeStyle = LINE_COLOR

        canvasCtx.beginPath()

        sliceWidth = WIDTH * 1.0 / bufferLength
        x = 0

        for i in [0...bufferLength]
          v = dataArray[i] / 128.0
          y = v * HEIGHT/2
          if i == 0
            canvasCtx.moveTo(x, y)
          else
            canvasCtx.lineTo(x, y);
          x += sliceWidth

        canvasCtx.lineTo(WIDTH, HEIGHT/2)
        canvasCtx.stroke()

      draw()

  pause: ->
    try @_audioSource.disconnect()

  stop: ->
    try @_audioSource.disconnect()

  getElapsedTime: ->
    @_elapsedTime

  adjustTime: (sec) ->
    framesPerSec = 1 / (AUDIO_BUFFER_SIZE / SAMPLE_RATE)
    for i in [0..(framesPerSec * sec)]
      @_worker.requestFrame()
      @_elapsedTime += AUDIO_BUFFER_SIZE / SAMPLE_RATE

class @EditorBuilder
  constructor: (@editorElement) ->
    @keyboard = @editorElement.data('keyboard')
    @editor = editor = ace.edit("editor")

    switch @keyboard
      when 'vim'
        editor.setKeyboardHandler("ace/keyboard/vim")
      when 'emacs'
        editor.setKeyboardHandler("ace/keyboard/emacs")

    editor.getSession().setUseSoftTabs(true)
    editor.getSession().setTabSize(2)
    editor.$blockScrolling = Infinity # Disable deprecation warning
    editor.renderer.setShowGutter(false)
    editor.setShowPrintMargin(false)
    editor.focus()

    @_addListeners()
    @_configureCommands()

  setLanguage: (@language) ->
    @language.toLowerCase()
    switch @language
      when 'coffeescript'
        @editor.getSession().setMode("ace/mode/coffee")
      when 'javascript'
        @editor.getSession().setMode("ace/mode/javascript")

  getLanguage: -> @language

  updateContent: (data) ->
    @editorElement.removeClass('unloaded')
    @editor.setValue data, -1
    @editor.focus()

  getEditor: ->
    @editor

  getEditorElement: ->
    @editorElement

  _addListeners: ->
    @editor.on "blur", =>
      @editorElement.addClass('blur')
    @editor.on "focus", =>
      @editorElement.removeClass('blur')

  _configureCommands: ->
    @editor.commands.removeCommand("gotoline")

    @editor.commands.addCommand({
      name: 'Run'
      bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'}
      readOnly: true
      exec: (editor) ->
        window.playEditorContents();
    })

    @editor.commands.addCommand({
      name: 'Stop'
      bindKey: {win: 'Ctrl-.',  mac: 'Command-.'}
      readOnly: true
      exec: (editor) ->
        window.player.pause();
    })
