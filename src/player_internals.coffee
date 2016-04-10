SAMPLE_RATE = 44100
AUDIO_BUFFER_SIZE = 2048
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
    @worker.onerror = @_workerError
    @worker.onmessage = @_workerMessage

    if window.yieldWorker
      window.yieldWorker(@worker)

  pop: ->
    @worker.postMessage(["generate"])
    if @_buffer?
      buffer = @_buffer
      @_buffer = null
      buffer
    else
      console.log("Dropped an audio frame. If you don't see any other error messages you may be processing too much data. This is normal when system audio is initializing.");
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

  _workerError: (error) =>
    console.log "Worker Error: #{error.message}. Line #{error.lineno}"
    console.log error
    error.preventDefault()


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
    @_audioSource = globalAudioContext.createScriptProcessor(AUDIO_BUFFER_SIZE, 0, 2)
    @_audioSource.onaudioprocess = (event) =>
      volume = 0.2
      left  = event.outputBuffer.getChannelData(0)
      right = event.outputBuffer.getChannelData(1)
      nextBuffer = @_worker.pop()
      for i in [0...left.length]
        # Clip! – TODO add warning when sample > 1 || sample < -1
        left[i]  = Math.min(Math.max(volume * nextBuffer[ i*2 ], -1), 1)
        right[i] = Math.min(Math.max(volume * nextBuffer[ i*2+1 ], -1), 1)
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
      @_audioAnalyser.fftSize = 2048
      bufferLength = @_audioAnalyser.fftSize;
      dataArray = new Uint8Array(bufferLength)

      canvasCtx = el.getContext('2d')
      canvasCtx.clearRect(0, 0, WIDTH, HEIGHT)

      draw = =>

        drawVisual = requestAnimationFrame(draw)

        @_audioAnalyser.getByteTimeDomainData(dataArray)

        canvasCtx.fillStyle = BG_COLOR
        canvasCtx.fillRect(0, 0, WIDTH, HEIGHT)

        canvasCtx.lineWidth = 1
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
      @_worker.pop()
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
