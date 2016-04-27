require 'v1/instruments'

###
transport and parts should be pasted in from http://tonejs.github.io/MidiConvert/
masterGain can be used to prevent clipping
instrumentBuilders is a hash of track labels (the object keys in the `parts` hash) to functions that take a note and returns a function to be passed to @play()
###

parseMidi = (options={}) ->

  transport           = options.transport
  parts               = options.parts
  instrumentBuilders  = options.instrumentBuilders || {}
  masterGain          = options.masterGain || -20

  unless options.parts?
    throw new Error "Options must specify 'parts' values for parseMidi."

  ->
    # Tone.js uses a default "parts per quarter" of 48
    # BPM is specified in the transport
    if options.transport?
      @setBPM parseInt(transport.bpm) * 48
    @setMasterGain masterGain

    processedNotes = []
    for trackName, track of parts
      for noteData in track
        processedNotes.push {
          instrument: trackName
          start:      parseInt(noteData.time).beats()
          duration:   parseInt(noteData.duration).beats()
          velocity:   parseFloat(noteData.velocity)
          frequency:  Frequency.noteNumber(noteData.midiNote)
        }

    for note in processedNotes
      # Closures in a loop are tricky, but CoffeeScript provides the do keyword
      # which will push a new lexical scope to capture outside variables.
      # We *also* must bind to this, by using => intstead of ->, to ensure the
      # `do` closure is run in the scope provided by `buildTrack`.
      do (note) =>
        @after note.start, ->
          if builder = instrumentBuilders[note.instrument]
            @play builder(note)
          else
            # Be slightly more careful about the shared namespace when this is
            # apply'd to run in buildTrack().
            _o = new Oscillator(frequency: note.frequency, type: Oscillator.SQUARE)
            _e = new Envelope(decayTime: note.duration)
            @play _e.process(_o)
