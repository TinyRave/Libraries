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
TinyRaveTimer
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
class TinyRaveTimer
  constructor: ->
    @callbackDescriptors = []
    @lastId = 1
    @time = 0 # Initialize to 0 so any callers using getTime() can correctly
              # perform offset math.

  getTime: -> @time
  setTime: (time) ->
    # Time only advances
    if time > @time || time == 0
      @time = time
      @fireCallbacks()
    time

  # Callbacks should fire in the order the timers were created.
  registerCallback: (callback, interval, isLoop=false) ->
    id = @lastId++
    @callbackDescriptors.push { id: id, callback: callback, interval: interval, registrationTime: @getTime, isLoop: isLoop }
    id

  unregisterCallback: (id) ->
    i = 0 # Manual loop since all coffeescript iterators cache array.length
    while i < @callbackDescriptors.length
      descriptor = @callbackDescriptors[i]
      if descriptor.id == id
        @callbackDescriptors.splice i, 1
        i--
      i++

  # Find next elegible timer. If a loop, re-queue after firing.
  dequeueNextDescriptor: ->
    for descriptor, i in @callbackDescriptors
      fireThreshold = descriptor.registrationTime + descriptor.interval
      if fireThreshold <= @time
        if descriptor.isLoop
          descriptor.registrationTime = fireThreshold
        else
          @callbackDescriptors.splice(i, 1)
        return descriptor

  # By design callbacks can clear timers scheduled to run in the current tick.
  # We need to iterate over the full array, from the beginning, since we don't
  # know how the state of the array has changed after firing each callback.
  fireCallbacks: ->
    while descriptor = @dequeueNextDescriptor()
      descriptor.callback.apply(undefined)

  invalidateBeatLength: ->
    for descriptor in @callbackDescriptors
      if descriptor.interval.hasBeatValue()
        descriptor.interval = descriptor.interval.beats()


# All timer DSL functions (every, until, after) are called with an instance of
# TopLevelScope or ShadowScope as `this.` Initially, we create a TopLevelScope
# with an expiration set to now() + delay. Any calls to setInterval / setTimeout
# from inside the functions will be cleared at the expiration time. The special
# case is `until`, which executes its callback in a new instance of
# ShadowScope, which is chained to the parent scope (an instance of
# TopLevelScope or ShadowScope [since `until` calls can be nested]).
#
# Doing this gets us two things:
#
# 1) An `expiration` shadow variable. When the timer methods run in an instance
#    of ShadowScope, they will reference the most-local, shadow copy of
#    @expiration. This allows us to adjust the block expiration deeper in nested
#    calls.
#
# 2) A version of `this` that will still resolve instance variables. If you
#    define any variables in blockWillRun they are accessible in timer callbacks
#    This is really handy, since you can establish your state at the start of
#    the run, modify it in the timer methods, and reference it when actually
#    pushing new instruments on to the GlobalMixer.

class TopLevelScope
  constructor: (delay) ->
    @expiration = TinyRave.getTime() + delay

  every: (delay, callback) ->
    @until(delay, callback)
    @withExpiration(
      setInterval((=> @until(delay, callback)), delay)
    )

  after: (delay, callback) ->
    @withExpiration(
      setTimeout((=> callback.apply(@)), delay)
    )

  until: (delay, callback) ->
    newScope = @createUntilScope(delay)
    callback.apply(newScope)

  #
  # Internal API:

  withExpiration: (id) ->
    setTimeout((=> clearInterval(id)), @expiration - TinyRave.timer.getTime())

  createUntilScope: (delay) ->
    # Delay cannot exceed parent (existing) scope expiration
    expiration = Math.min(TinyRave.timer.getTime() + delay, @expiration)
    # The new scope creates a shadow var expiration, so timer functions will
    # see the local scope's value and behave apporopriately in nested calls
    ShadowScope.prototype = @
    new ShadowScope(expiration)

# For expiration shadow variable
class ShadowScope
  constructor: (@expiration) ->


class BuildTrackEnvironment extends TopLevelScope
  constructor: ->
    @setBPM(120)
    @mixer = new GlobalMixer
    super(60 * 60 * 24 * 365 * 10) # 10 yrs

  # -
  setBPM: (bpm) ->
    TinyRave.setBPM(bpm)

  getBPM: ->
    TinyRave.getBPM()

  # -
  getMasterGain: ->
    @mixer.getGain()

  setMasterGain: (gain) ->
    @mixer.setGain(gain)

  # -
  play: (buildSampleClosure) ->
    length = @expiration - TinyRave.timer.getTime()
    @mixer.mixFor length, buildSampleClosure


class GlobalMixer
  constructor: ->
    @pruneInterval = 0.100
    @lastPruneAt = 0
    @mixableDescriptors = []
    @time = 0 # This assumes the mixer will start at time 0!
    @setGain(-7)

  getGain: -> @gain
  setGain: (@gain=-7.0) ->
    @multiplier = Math.pow(10, @gain / 20)

  prune: ->
    i = @mixableDescriptors.length - 1
    while (i >= 0)
      mixable = @mixableDescriptors[i]
      @mixableDescriptors.splice(i, 1) if mixable.expiration < @time
      i--
    @lastPruneAt = @time

  buildSample: (@time) ->
    @prune() if @time >= @lastPruneAt + @pruneInterval
    sample = 0
    for descriptor in @mixableDescriptors when descriptor.expiration >= @time
      sample += @multiplier * descriptor.buildSample(@time)
    if sample > 1 || sample < -1
      console.log "Warning: signal out of range. Reduce master gain to prevent clipping."
    sample

  mixFor: (duration, buildSampleClosure) ->
    console.error "Must specify duration in push() call" unless duration?
    console.error "Must specify function in push() call" unless buildSampleClosure?
    @mixableDescriptors.push {
      expiration: @time + duration,
      buildSample: buildSampleClosure
    }

# Import is a reserved keyword in coffeescript
```
var import = function(path){
  if (path.indexOf(".js" === -1)){
    path = path + ".js";
  }
  importScripts("http://tinyrave.com/lib/" + path);
}
```

#
# TinyRave Object
TinyRave = {
  setBPM: (@BPM) -> @timer.invalidateBeatLength()
  getBPM: -> @BPM
  timer: new TinyRaveTimer()
}

setInterval = (callback, delay) ->
  TinyRave.timer.registerCallback(callback, delay, true)

setTimeout = (callback, delay) ->
  TinyRave.timer.registerCallback(callback, delay, false)

# This works for setTimeout calls, too
clearInterval = (id) ->
  TinyRave.timer.unregisterCallback(id)

#
# Core Extensions

# We can treat 5.beats() as a value in seconds and recover the correct duration
# if BPM changes. Do do so, call number.beats() if number.hasValueInBeats()
Number.prototype.beats = Number.prototype.beat = ->
  valueInBeats = this.valueInBeats || this
  seconds = new Number(valueInBeats / (TinyRave.BPM / 60))
  seconds.valueInBeats = valueInBeats
  seconds

Number.prototype.hasValueInBeats = ->
  this.valueInBeats?
