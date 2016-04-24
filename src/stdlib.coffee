# Provides a shorthand for musical notes. Usage:
# Frequency.A_4 // Defined as 440.0
F = Frequencies = class Frequency
  # MIDI Note number -> Hz value
  @noteNumber = (note) ->
    note = parseInt(note)
    (440 / 32) * Math.pow(2, (note - 9) / 12)

  @C_0                        = @noteNumber(12)
  @C_SHARP_0 = @D_FLAT_0      = @noteNumber(13)
  @D_0                        = @noteNumber(14)
  @D_SHARP_0 = @E_FLAT_0      = @noteNumber(15)
  @E_0                        = @noteNumber(16)
  @F_0                        = @noteNumber(17)
  @F_SHARP_0 = @G_FLAT_0      = @noteNumber(18)
  @G_0                        = @noteNumber(19)
  @G_SHARP_0 = @A_FLAT_0      = @noteNumber(20)
  @A_0                        = @noteNumber(21)
  @A_SHARP_0 = @B_FLAT_0      = @noteNumber(22)
  @B_0                        = @noteNumber(23)
  @C_1                        = @noteNumber(24)
  @C_SHARP_1 = @D_FLAT_1      = @noteNumber(25)
  @D_1                        = @noteNumber(26)
  @D_SHARP_1 = @E_FLAT_1      = @noteNumber(27)
  @E_1                        = @noteNumber(28)
  @F_1                        = @noteNumber(29)
  @F_SHARP_1 = @G_FLAT_1      = @noteNumber(30)
  @G_1                        = @noteNumber(31)
  @G_SHARP_1 = @A_FLAT_1      = @noteNumber(32)
  @A_1                        = @noteNumber(33)
  @A_SHARP_1 = @B_FLAT_1      = @noteNumber(34)
  @B_1                        = @noteNumber(35)
  @DEEP_C =  @C_2             = @noteNumber(36)
  @C_SHARP_2 = @D_FLAT_2      = @noteNumber(37)
  @D_2                        = @noteNumber(38)
  @D_SHARP_2 = @E_FLAT_2      = @noteNumber(39)
  @E_2                        = @noteNumber(40)
  @F_2                        = @noteNumber(41)
  @F_SHARP_2 = @G_FLAT_2      = @noteNumber(42)
  @G_2                        = @noteNumber(43)
  @G_SHARP_2 = @A_FLAT_2      = @noteNumber(44)
  @A_2                        = @noteNumber(45)
  @A_SHARP_2 = @B_FLAT_2      = @noteNumber(46)
  @B_2                        = @noteNumber(47)
  @TENOR_C = @C_3             = @noteNumber(48)
  @C_SHARP_3 = @D_FLAT_3      = @noteNumber(49)
  @D_3                        = @noteNumber(50)
  @D_SHARP_3 = @E_FLAT_3      = @noteNumber(51)
  @E_3                        = @noteNumber(52)
  @F_3                        = @noteNumber(53)
  @F_SHARP_3 = @G_FLAT_3      = @noteNumber(54)
  @G_3                        = @noteNumber(55)
  @G_SHARP_3 = @A_FLAT_3      = @noteNumber(56)
  @A_3                        = @noteNumber(57)
  @A_SHARP_3 = @B_FLAT_3      = @noteNumber(58)
  @B_3                        = @noteNumber(59)
  @MIDDLE_C = @C_4            = @noteNumber(60)
  @C_SHARP_4 = @D_FLAT_4      = @noteNumber(61)
  @D_4                        = @noteNumber(62)
  @D_SHARP_4 = @E_FLAT_4      = @noteNumber(63)
  @E_4                        = @noteNumber(64)
  @F_4                        = @noteNumber(65)
  @F_SHARP_4 = @G_FLAT_4      = @noteNumber(66)
  @G_4                        = @noteNumber(67)
  @G_SHARP_4 = @A_FLAT_4      = @noteNumber(68)
  @A440 = @A_4                = @noteNumber(69)
  @A_SHARP_4 = @B_FLAT_4      = @noteNumber(70)
  @B_4                        = @noteNumber(71)
  @C_5                        = @noteNumber(72)
  @C_SHARP_5 = @D_FLAT_5      = @noteNumber(73)
  @D_5                        = @noteNumber(74)
  @D_SHARP_5 = @E_FLAT_5      = @noteNumber(75)
  @E_5                        = @noteNumber(76)
  @F_5                        = @noteNumber(77)
  @F_SHARP_5 = @G_FLAT_5      = @noteNumber(78)
  @G_5                        = @noteNumber(79)
  @G_SHARP_5 = @A_FLAT_5      = @noteNumber(80)
  @A_5                        = @noteNumber(81)
  @A_SHARP_5 = @B_FLAT_5      = @noteNumber(82)
  @B_5                        = @noteNumber(83)
  @SOPRANO_C = @HIGH_C = @C_6 = @noteNumber(84)
  @C_SHARP_6 = @D_FLAT_6      = @noteNumber(85)
  @D_6                        = @noteNumber(86)
  @D_SHARP_6 = @E_FLAT_6      = @noteNumber(87)
  @E_6                        = @noteNumber(88)
  @F_6                        = @noteNumber(89)
  @F_SHARP_6 = @G_FLAT_6      = @noteNumber(90)
  @G_6                        = @noteNumber(91)
  @G_SHARP_6 = @A_FLAT_6      = @noteNumber(92)
  @A_6                        = @noteNumber(93)
  @A_SHARP_6 = @B_FLAT_6      = @noteNumber(94)
  @B_6                        = @noteNumber(95)
  @DOUBLE_HIGH_C = @C_7       = @noteNumber(96)
  @C_SHARP_7 = @D_FLAT_7      = @noteNumber(97)
  @D_7                        = @noteNumber(98)
  @D_SHARP_7 = @E_FLAT_7      = @noteNumber(99)
  @E_7                        = @noteNumber(100)
  @F_7                        = @noteNumber(101)
  @F_SHARP_7 = @G_FLAT_7      = @noteNumber(102)
  @G_7                        = @noteNumber(103)
  @G_SHARP_7 = @A_FLAT_7      = @noteNumber(104)
  @A_7                        = @noteNumber(105)
  @A_SHARP_7 = @B_FLAT_7      = @noteNumber(106)
  @B_7                        = @noteNumber(107)
  @C_8                        = @noteNumber(108)
  @C_SHARP_8 = @D_FLAT_8      = @noteNumber(109)
  @D_8                        = @noteNumber(110)
  @D_SHARP_8 = @E_FLAT_8      = @noteNumber(111)
  @E_8                        = @noteNumber(112)
  @F_8                        = @noteNumber(113)
  @F_SHARP_8 = @G_FLAT_8      = @noteNumber(114)
  @G_8                        = @noteNumber(115)
  @G_SHARP_8 = @A_FLAT_8      = @noteNumber(116)
  @A_8                        = @noteNumber(117)
  @A_SHARP_8 = @B_FLAT_8      = @noteNumber(118)
  @B_8                        = @noteNumber(119)


###
TinyRaveTimer
--------------------------
The TinyRave library provides a custom sample accurate implementation of
setInterval / setTimeout / clearTimeout. Any specified callbacks will preempt
audio rendering allowing you to modify your environment with sample-level
time resolution.

It's recommended you use the DSL provided in buildTrack(), which simplifies the
process of creating short-lived loops by managing the registration and
unregistration of callbacks for you.

See `@every()`, `@after()` and `@until()` methods here:
https://emcmanus.gitbooks.io/tinyrave-libraries/content/timers.html

The timer is optimized to handle 1000's of callbacks. (Useful for tracks that
front-load the scheduling of notes, like when using the MIDI adapter.)
###
class TinyRaveTimer
  constructor: ->
    @callbackDescriptors = []
    @lastId = 1
    @time = 0 # Initialize to 0 so any callers using getTime() can correctly
              # perform offset math.

    # This is an optimization that allows us to skip most calls to
    # fireCallbacks(). Maintain the lowest time threshold of our descriptors and
    # sleep until that time is reached.
    @nextThreshold = 0

  getTime: ->
    @time

  setTime: (time) ->
    # Time only advances
    if time > @time || time == 0
      @time = time
      if @time >= @nextThreshold
        @fireCallbacks()
        @updateThreshold() # Descriptors change their registration time when isLoop = true
    else
      throw new Error "Time invalid."
    time

  # Callbacks should fire in the order the timers were created.
  registerCallback: (callback, interval, isLoop=false) ->
    id = @lastId++
    @callbackDescriptors.push { id: id, callback: callback, interval: interval, registrationTime: @time, isLoop: isLoop }
    @invalidateThreshold()
    id

  unregisterCallback: (id) ->
    for descriptor, i in @callbackDescriptors
      if descriptor.id == id
        @callbackDescriptors.splice i, 1
        @invalidateThreshold()
        break

  # Find next elegible timer. If a loop, re-queue after firing.
  dequeueNextDescriptor: ->
    for descriptor, i in @callbackDescriptors
      fireThreshold = descriptor.registrationTime + descriptor.interval
      if @time >= fireThreshold
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

  invalidateThreshold: ->
    @nextThreshold = 0

  updateThreshold: ->
    @nextThreshold = Number.POSITIVE_INFINITY
    for callback in @callbackDescriptors
      @nextThreshold = Math.min( @nextThreshold, callback.registrationTime + callback.interval )

  invalidateBeatLength: ->
    for descriptor in @callbackDescriptors
      if descriptor.interval.hasValueInBeats()
        descriptor.interval = descriptor.interval.beats()
    @invalidateThreshold()


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
#    @expiration. This allows us to adjust the block expiration in nested
#    calls.
#
# 2) A version of `this` that will still resolve instance variables. If you
#    define any variables using `this` they will be accessible in other timer
#    callbacks.

class TopLevelScope
  constructor: (duration) ->
    @expiration = TinyRave.timer.getTime() + duration

  every: (delay, callback) ->
    callback.displayName ||= "Every Block"
    @until(delay, callback)
    @withExpiration(
      setInterval((=> @until(delay, callback)), delay)
    )

  after: (delay, callback) ->
    callback.displayName ||= "After Block"
    @withExpiration(
      setTimeout((=> callback.apply(@)), delay)
    )

  until: (delay, callback) ->
    callback.displayName ||= "Until Block"
    newScope = @createUntilScope(delay)
    callback.apply(newScope)

    # You can chain until() calls and they'll run sequentially
    class Chain
      constructor: (@reference, @delay) ->
      until: (_delay, _callback) =>
        @reference.after(@delay, =>
          @reference.until(_delay, _callback)
        )
        new Chain(@reference, @delay + _delay)
    new Chain(@, delay)

  #
  # Internal API:

  withExpiration: (id) ->
    expirationCallback = => clearInterval(id)
    setTimeout(expirationCallback, @expiration - TinyRave.timer.getTime())

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


# buildTrack() provides an instance of BuildTrackEnvironment as `this`. Since it
# extends TopLevelScope, you also get the `every` / `after` / `until` functions.
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
  getMixer: ->
    @mixer

  # -
  getMasterGain: ->
    @mixer.getGain()

  setMasterGain: (gain) ->
    @mixer.setGain(gain)

  # -
  play: (buildSampleClosure) ->
    duration = buildSampleClosure.duration || @expiration - TinyRave.timer.getTime()
    @mixer.mixFor duration, buildSampleClosure


# GlobalMixer is a Mixer instance that exists for the life of the track when
# the track defines a `buildTrack` function. This mixer instance maintains
# an array of all sound generating functions, and every 100ms iterates the array
# to remove any functions that have stopped generating audio (as determined by
# the function's `duration` property). It's strongly recommended that any
# functions passed into mixFor provide a duration, since this allows us to
# optimize the mixer. Note: if you use the @play method of `buildTrack` we can
# do a reasonable job inferring a function's duration from the current scope.
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
      @mixableDescriptors.splice(i, 1) if mixable.expiresAt < @time
      i--
    @lastPruneAt = @time

  buildSample: (@time) ->
    @prune() if @time >= @lastPruneAt + @pruneInterval
    sample = 0
    for descriptor in @mixableDescriptors when descriptor.expiresAt >= @time
      sample += @multiplier * descriptor.buildSample(@time - descriptor.createdAt, @time)
    sample

  mixFor: (duration, buildSampleClosure) ->
    console.error "Must specify duration in push() call" unless duration?
    console.error "Must specify function in push() call" unless buildSampleClosure?
    @mixableDescriptors.push {
      createdAt: @time
      expiresAt: @time + duration,
      buildSample: buildSampleClosure
    }

#
# TinyRave Namespace
TinyRave = {
  timer: new TinyRaveTimer()

  setBPM: (@BPM) ->
    @timer.invalidateBeatLength()

  getBPM: ->
    @BPM

  initializeBuildTrack: ->
    # Called when the adapter detects buildTrack but no buildSample
    environment = new BuildTrackEnvironment
    mixer = environment.getMixer()
    buildTrack.apply(environment)
    self.buildSample = (time) ->
      mixer.buildSample(time)
}


# Sample-accurate replacements for setInterval / setTimeout / clearInterval

setInterval = (callback, delay) ->
  TinyRave.timer.registerCallback(callback, delay, true)

setTimeout = (callback, delay) ->
  TinyRave.timer.registerCallback(callback, delay, false)

# Accepts any ID returned by setInterval or setTimeout.
clearInterval = (id) ->
  TinyRave.timer.unregisterCallback(id)


# Core Extensions

# We can treat 5.beats() as a value in seconds and recover the correct duration
# if BPM changes. After `setBPM()`, call `number.beats()` if
# `number.hasValueInBeats()`. See `invalidateBeatLength()` implementation for
# usage.
Number.prototype.beats = Number.prototype.beat = ->
  valueInBeats = this.valueInBeats || this
  seconds = new Number(valueInBeats / (TinyRave.BPM / 60))
  seconds.valueInBeats = valueInBeats
  seconds

# Whether this number instance was ever generated as the result of a call to
# beat or beats().
Number.prototype.hasValueInBeats = ->
  this.valueInBeats?
