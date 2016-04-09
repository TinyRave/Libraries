F = class Frequency
  # Based on http://www.phy.mtu.edu/~suits/notefreqs.html
  @C_0                        = 16.35
  @C_SHARP_0 = @D_FLAT_0      = 17.32
  @D_0                        = 18.35
  @D_SHARP_0 = @E_FLAT_0      = 19.45
  @E_0                        = 20.60
  @F_0                        = 21.83
  @F_SHARP_0 = @G_FLAT_0      = 23.12
  @G_0                        = 24.50
  @G_SHARP_0 = @A_FLAT_0      = 25.96
  @A_0                        = 27.50
  @A_SHARP_0 = @B_FLAT_0      = 29.14
  @B_0                        = 30.87
  @C_1                        = 32.70
  @C_SHARP_1 = @D_FLAT_1      = 34.65
  @D_1                        = 36.71
  @D_SHARP_1 = @E_FLAT_1      = 38.89
  @E_1                        = 41.20
  @F_1                        = 43.65
  @F_SHARP_1 = @G_FLAT_1      = 46.25
  @G_1                        = 49.00
  @G_SHARP_1 = @A_FLAT_1      = 51.91
  @A_1                        = 55.00
  @A_SHARP_1 = @B_FLAT_1      = 58.27
  @B_1                        = 61.74
  @DEEP_C =  @C_2             = 65.41
  @C_SHARP_2 = @D_FLAT_2      = 69.30
  @D_2                        = 73.42
  @D_SHARP_2 = @E_FLAT_2      = 77.78
  @E_2                        = 82.41
  @F_2                        = 87.31
  @F_SHARP_2 = @G_FLAT_2      = 92.50
  @G_2                        = 98.00
  @G_SHARP_2 = @A_FLAT_2      = 103.83
  @A_2                        = 110.00
  @A_SHARP_2 = @B_FLAT_2      = 116.54
  @B_2                        = 123.47
  @TENOR_C = @C_3             = 130.81
  @C_SHARP_3 = @D_FLAT_3      = 138.59
  @D_3                        = 146.83
  @D_SHARP_3 = @E_FLAT_3      = 155.56
  @E_3                        = 164.81
  @F_3                        = 174.61
  @F_SHARP_3 = @G_FLAT_3      = 185.00
  @G_3                        = 196.00
  @G_SHARP_3 = @A_FLAT_3      = 207.65
  @A_3                        = 220.00
  @A_SHARP_3 = @B_FLAT_3      = 233.08
  @B_3                        = 246.94
  @MIDDLE_C = @C_4            = 261.63
  @C_SHARP_4 = @D_FLAT_4      = 277.18
  @D_4                        = 293.66
  @D_SHARP_4 = @E_FLAT_4      = 311.13
  @E_4                        = 329.63
  @F_4                        = 349.23
  @F_SHARP_4 = @G_FLAT_4      = 369.99
  @G_4                        = 392.00
  @G_SHARP_4 = @A_FLAT_4      = 415.30
  @A440 = @A_4                = 440.00
  @A_SHARP_4 = @B_FLAT_4      = 466.16
  @B_4                        = 493.88
  @C_5                        = 523.25
  @C_SHARP_5 = @D_FLAT_5      = 554.37
  @D_5                        = 587.33
  @D_SHARP_5 = @E_FLAT_5      = 622.25
  @E_5                        = 659.25
  @F_5                        = 698.46
  @F_SHARP_5 = @G_FLAT_5      = 739.99
  @G_5                        = 783.99
  @G_SHARP_5 = @A_FLAT_5      = 830.61
  @A_5                        = 880.00
  @A_SHARP_5 = @B_FLAT_5      = 932.33
  @B_5                        = 987.77
  @SOPRANO_C = @HIGH_C = @C_6 = 1046.50
  @C_SHARP_6 = @D_FLAT_6      = 1108.73
  @D_6                        = 1174.66
  @D_SHARP_6 = @E_FLAT_6      = 1244.51
  @E_6                        = 1318.51
  @F_6                        = 1396.91
  @F_SHARP_6 = @G_FLAT_6      = 1479.98
  @G_6                        = 1567.98
  @G_SHARP_6 = @A_FLAT_6      = 1661.22
  @A_6                        = 1760.00
  @A_SHARP_6 = @B_FLAT_6      = 1864.66
  @B_6                        = 1975.53
  @DOUBLE_HIGH_C = @C_7       = 2093.00
  @C_SHARP_7 = @D_FLAT_7      = 2217.46
  @D_7                        = 2349.32
  @D_SHARP_7 = @E_FLAT_7      = 2489.02
  @E_7                        = 2737.02
  @F_7                        = 2793.83
  @F_SHARP_7 = @G_FLAT_7      = 2959.97
  @G_7                        = 3135.97
  @G_SHARP_7 = @A_FLAT_7      = 3322.44
  @A_7                        = 3520.00
  @A_SHARP_7 = @B_FLAT_7      = 3729.31
  @B_7                        = 3951.07
  @C_8                        = 4186.01
  @C_SHARP_8 = @D_FLAT_8      = 4434.92
  @D_8                        = 4698.63
  @D_SHARP_8 = @E_FLAT_8      = 4988.03
  @E_8                        = 5284.04
  @F_8                        = 5588.65
  @F_SHARP_8 = @G_FLAT_8      = 5919.91
  @G_8                        = 6281.93
  @G_SHARP_8 = @A_FLAT_8      = 6644.88
  @A_8                        = 8040.00
  @A_SHARP_8 = @B_FLAT_8      = 8458.62
  @B_8                        = 8902.13


###
TinyRaveScheduler
--------------------------
The TinyRave library provides a custom sample accurate implementation of
setInterval / setTimeout / clearTimeout. Any specified callbacks will preempt
audio rendering allowing you to modify your environment with sample-level
time resolution.

It's recommended you use the DSL provided in TinyRave.createBlock, which
simplifies the process of creating short-lived loops by managing the
registration and unregistration of callbacks for you.

(See TinyRave.createBlock, and the `@every()` / `@after()` methods in `run()`.)
###
class TinyRaveScheduler
  @createBlock: (duration, methods) ->
    { duration: duration, methods: methods }

  constructor: ->
    # timer
    @callbackDescriptors = []
    @lastId = 1
    @time = 0 # Last time fireCallbacks ran. Initialize to 0 so any callers
              # using getTime() can correctly perform offset math.
    # scheduler
    @blocks = []

  #
  # Timer methods

  # Make sure you call setTime(time) before we render any samples in main()
  getTime: -> @time # The last time threshold considered
  setTime: (time) ->
    # Time only advances
    if time > @time || time == 0
      @time = time
      @fireCallbacks()
    time

  dequeueNextDescriptor: ->
    for descriptor, i in @callbackDescriptors
      fireThreshold = descriptor.registrationTime + descriptor.interval
      if fireThreshold <= @time
        if descriptor.isLoop
          descriptor.registrationTime = fireThreshold
        else
          @callbackDescriptors.splice(i, 1)
        return descriptor

  fireCallbacks: ->
    # By design! We want to allow a callback to modify other callbacks queued
    # to fire in the current pass. To accomodate this we use the following algo:
    #  1) Iterate array from beginning
    #  2) If valid callback found; fire
    #  3) Repeat from 1 until no eligible callbacks are found
    # We need to iterate over the full array, from the beginning, since we don't
    # know how the state of the array has changed since firing the callback.
    while descriptor = @dequeueNextDescriptor()
      descriptor.callback.apply(undefined)

  # Callbacks should fire in a logical order. So if we for example
  #   registerCallback myCallback1, 0.1
  #   registerCallback myCallback2, 0.1, 0, true
  #   registerCallback myCallback3, 0.1
  # then we should fire, in order: myCallback1, myCallback2, myCallback3
  registerCallback: (callback, interval, registrationTime=0, isLoop=false) ->
    id = @lastId++
    @callbackDescriptors.push { id: id, callback: callback, interval: interval, registrationTime: registrationTime, isLoop: isLoop }
    id

  unregisterCallback: (id) ->
    i = 0 # Manual loop since all coffeescript iterators cache array.length
    while i < @callbackDescriptors.length
      descriptor = @callbackDescriptors[i]
      if descriptor.id == id
        @callbackDescriptors.splice i, 1
        i--
      i++

  #
  # Block scheduler methods
  getBlockQueueLength: ->
    length = 0
    length += block.duration for block in @blocks
    length

  push: (blocks...) ->
    for block in blocks
      console.warn "Push all blocks before the first call to buildSample. (Feel free to email me if you need this fixed.)" if @time > 0
      delay = @getBlockQueueLength()
      @blocks.push(block)
      TinyRave.setTimeout((=> @shiftBlock()), delay)

  shiftBlock: ->
    block = @blocks.shift()
    console.error "In shiftBlock(). No block left to shift." unless block?
    blockScope = new BlockScope block.duration
    block.methods.blockWillStart?.apply(blockScope)
    teardown = ->
      blockScope.blockWillEnd()
      block.methods.blockDidEnd?.apply(blockScope)
    TinyRave.setTimeout teardown, block.duration
    # We want to queue the teardown before any every/after calls. It seems most
    # natural to run all timers UP TO but not including block.duration. E.g., in
    # a block of length 12, with an every of 4, you want execution on 0 4 8 but
    # not 12. (12 is the down beat of the next block.)
    block.methods.run.apply(blockScope)


class BlockScope
  constructor: (@duration) ->
    @timerIds = []
  getDuration: -> @duration
  every: (delay, callback) ->
    callback.apply(@) # Fire first iteration immediately
    id = TinyRave.setInterval((=> callback.apply(@)), delay)
    @timerIds.push id
  after: (delay, callback) ->
    id = TinyRave.setTimeout((=> callback.apply(@)), delay)
    @timerIds.push id
  blockWillEnd: ->
    for id in @timerIds
      TinyRave.clearInterval id

#
# TinyRave Object
TinyRave = {}

TinyRave.scheduler = new TinyRaveScheduler()
TinyRave.createBlock = TinyRaveScheduler.createBlock

TinyRave.logOnce = (message) ->
  unless message in TinyRave.logOnceMessages
    console.log message
    TinyRave.logOnceMessages.push message
TinyRave.logOnceMessages = []

TinyRave.setBPM = (bpm) ->
  TinyRave.BPM = bpm

TinyRave.setInterval = (callback, delay) ->
  TinyRave.scheduler.registerCallback(callback, delay, TinyRave.scheduler.getTime(), true)

TinyRave.setTimeout = (callback, delay) ->
  TinyRave.scheduler.registerCallback(callback, delay, TinyRave.scheduler.getTime(), false)

TinyRave.clearInterval = (id) ->
  # This can work for setTimeout calls, too, unlike native setTimeout.
  TinyRave.scheduler.unregisterCallback(id)
  undefined

#
# Core Extensions
Number.prototype.beat = Number.prototype.beats = ->
  console.error "You must call TinyRave.setBPM(yourBPM) before calling Number.beat()" unless TinyRave.BPM?
  bps = TinyRave.BPM / 60
  this / bps
