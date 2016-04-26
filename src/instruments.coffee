###
Oscillator Class
--------------------------------------------------------------------------------
The Oscillator class provides a basic sound wave. You can play the resulting
sound directly, or, more likely, process the sound with another class in the
library, such as Filter, Envelope, or Mixer.

Constants
Oscillator.SINE       Wave type. Smooth sine waveform.
Oscillator.SQUARE     Wave type. Square waveform.
Oscillator.SAWTOOTH   Wave type. Sawtooth waveform.
Oscillator.TRIANGLE   Wave type. Triangle waveform.
Oscillator.NOISE      Wave type. Random samples between -1 and 1.

Wave types: https://en.wikipedia.org/wiki/Waveform

Arguments
 type:         Optional. Default Oscillator.SINE. The type of sound wave to
               generate. Accepted values: Oscillator.SINE,
               Oscillator.TRIANGLE, Oscillator.SQUARE, Oscillator.NOISE,
               Oscillator.SAWTOOTH.
 frequency:    Optional. Default 440. Number, or a function that takes a time
               parameter and returns a frequency. The time argument specifies
               how long the oscillator has been running.
 amplitude:    Optional. Default 1. Number, or a function that takes a time
               parameter and returns an amplitude multiplier. *Not* in
               dB's. the time argument specifies how long the oscillator has
               been running.
 phase:        Optional. Default 0. Number, or a function that takes a time
               parameter and returns a phase shift. the time argument
               specifies how long the oscillator has been running. This is an
               advanced parameter and can probably be ignored in most cases.

Returns
An instance-like closure that wraps the values passed at instantiation. This
follows the `(time) -> sample` convention for use in play() and buildSample().

Usage 1 (JS) - Basic wave (build sample version)
 require('v1/instruments');
 var oscillator = new Oscillator({frequency: Frequency.A_3});
 var buildSample = function(time){
   return oscillator(time);
 }

Usage 2 (JS) - Basic triangle wave (build track version)
 require('v1/instruments');
 var oscillator = new Oscillator({frequency: Frequency.A_3, type: Oscillator.TRIANGLE});
 var buildTrack = function(){
   this.play(oscillator);
 }

Usage 3 (JS) - Basic square wave, with amplitude
 require('v1/instruments');
 var oscillator = new Oscillator({frequency: Frequency.A_3, type: Oscillator.SQUARE, amplitude: 0.7});
 var envelope = new Envelope();
 var buildTrack = function(){
   this.play(envelope.process(oscillator));
 }

Usage 4 (JS) - Vibrato
 require('v1/instruments');
 var phaseModulation = function(time){ return 0.1 * Math.sin(TWO_PI * time * 5); }
 var oscillator = new Oscillator({frequency: Frequency.A_3, phase: phaseModulation});
 var buildTrack = function(){
   this.play(oscillator);
 }

Usage 5 (JS) - Hi Hat
 require('v1/instruments');
 var oscillator = new Oscillator({frequency: Frequency.A_3, type: Oscillator.NOISE});
 var filter = new Filter({type: Filter.HIGH_PASS, frequency: 10000});
 var envelope = new Envelope();
 var buildTrack = function(){
   this.play(envelope.process(filter.process(oscillator)));
 }
###

class Oscillator
  # Types
  @SINE           = 0
  @SQUARE         = 1
  @SAWTOOTH       = 2
  @TRIANGLE       = 3
  @NOISE          = 4

  constructor: (options={}) ->
    @frequency = options.frequency || 440
    @phase = options.phase || 0
    @amplitude = options.amplitude || 1

    @numericPhase     = @phase unless Function.isFunction(@phase)
    @numericFrequency = @frequency unless Function.isFunction(@frequency)
    @numericAmplitude = @amplitude unless Function.isFunction(@amplitude)

    @oscillatorFunction = switch (options.type || Oscillator.SINE)
      when Oscillator.SQUARE
        @square
      when Oscillator.SAWTOOTH
        @sawtooth
      when Oscillator.TRIANGLE
        @triangle
      when Oscillator.NOISE
        @noise
      else
        @sine

    # Represents start time
    @startTime = -1

    # The closure to be returned at the end of this call
    generator = (time) =>
      # Using localTime makes it easier to anticipate the interference of
      # multiple oscillators
      @startTime = time if @startTime == -1
      localTime = time - @startTime

      _phase = if @numericPhase? then @numericPhase else @phase(localTime)
      _frequency = if @numericFrequency? then @numericFrequency else @frequency(localTime)
      _amplitude = if @numericAmplitude? then @numericAmplitude else @amplitude(localTime)

      _amplitude * @oscillatorFunction((_frequency * localTime) + _phase)

    generator.displayName = "Oscillator Sound Generator"

    generator.getFrequency = => @frequency
    generator.setFrequency = (frequency) =>
      @frequency = frequency
      if Function.isFunction(@frequency)
        @numericFrequency = undefined
      else
        @numericFrequency = @frequency

    generator.getPhase = => @phase
    generator.setPhase = (phase) =>
      @phase = phase
      if Function.isFunction(@phase)
        @numericPhase = undefined
      else
        @numericPhase = @phase

    generator.getAmplitude = => @amplitude
    generator.setAmplitude = (amplitude) =>
      @amplitude = amplitude
      if Function.isFunction(@amplitude)
        @numericAmplitude = undefined
      else
        @numericAmplitude = @amplitude

    # Explicit return necessary in constructor
    return generator

  sine: (value) ->
    # Smooth wave intersecting (0, 0), (0.25, 1), (0.5, 0), (0.75, -1), (1, 0)
    Math.sin(2 * Math.PI * value)

  sawtooth: (value) ->
    # Line from (-.5,-1) to (0.5, 1)
    progress = (value + 0.5) % 1
    2 * progress - 1

  triangle: (value) ->
    # Linear change from (0, -1) to (0.5, 1) to (1, -1)
    progress = value % 1
    if progress < 0.5
      4 * progress - 1
    else
      -4 * progress + 3

  square: (value) ->
    # -1 for the first half of a cycle; 1 for the second half
    progress = value % 1
    if progress < 0.5
      1
    else
      -1

  noise: (value) ->
    Math.random() * 2 - 1


###
Envelope Class
--------------------------------------------------------------------------------
Shapes the sound wave passed into process().

Constants
  Envelope.AD     Attack / Decay envelope. Only the attackTime and decayTime
                  parameters are used.

                  AD Envelope - Amplitude:
                    /\         1
                   /  \
                  /    \       0

                  |-|          Attack phase
                     |-|       Decay phase

  Envelope.ADSR   Attack Decay Sustain Release envelope. All parameters are
                  used.

                  ADSR Envelope - Amplitude:
                    /\         1
                   /  \____    sustainLevel
                  /        \   0

                  |-|          Attack phase
                    |-|        Decay phase
                      |---|    Sustain phase
                          |-|  Release phase

Arguments
  type:           Optional. Default Envelope.AD. Accepted values: Envelope.AD,
                  Envelope.ADSR.
  attackTime:     Optional. Default 0.03. Value in seconds.
  decayTime:      Optional. Default 1.0. Value in seconds.
  sustainTime:    Optional. Default 0. Value in seconds. Ignored unless envelope
                  type is Envelope.ADSR.
  releaseTime:    Optional. Default 0. Value in seconds. Ignored unless envelope
                  type is Envelope.ADSR.
  sustainLevel:   Optional. Default 0. Value in seconds. Ignored unless envelope
                  type is Envelope.ADSR.

Returns
An object with a process() method, ready to accept an oscillator or other sound
generator to be shaped.

Usage 1 (JS)
require('v1/instruments');
var o = new Oscillator;
var e = new Envelope;
var processor = e.process(o);
var buildSample = function(time) {
  return processor(time);
}

Usage 2 (JS)
require('v1/instruments');
var o = new Oscillator;
var e = new Envelope;
var buildTrack = function() {
  this.play(e.process(o));
}

Usage 3 (JS)
require('v1/instruments');
var o = new Oscillator;
var e = new Envelope({type: Envelope.ADSR, sustainTime: 1, releaseTime: 1, sustainLevel: 0.5});
var buildTrack = function() {
  this.play(e.process(o));
}

###
class Envelope
  # AD Envelope Type
  #
  # Amplitude:
  #   /\         1
  #  /  \
  # /    \       0
  # |-|          Attack
  #    |-|       Decay
  @AD   = 0

  # ADSR Envelope Type
  #
  # Amplitude:
  #   /\         1
  #  /  \____    sustainLevel
  # /        \   0
  # |-|          Attack
  #   |-|        Decay
  #     |---|    Sustain
  #         |-|  Release
  @ADSR = 1

  constructor: (options={}) ->
    options.sustainLevel  ?= 0.3
    options.type          ?= Envelope.AD

    if options.type == Envelope.AD
      options.attackTime  ?= 0.03
      options.decayTime   ?= 1
      options.sustainTime = 0
      options.releaseTime = 0
      options.sustainLevel = 0

    unless options.attackTime? && options.decayTime? && options.sustainTime? && options.releaseTime?
      throw new Error "Options must specify 'attackTime', 'decayTime', 'sustainTime' and 'releaseTime' values for ADSR envelope type."

    @type         = options.type
    @sustainLevel = options.sustainLevel
    @attackTime   = options.attackTime
    @decayTime    = options.decayTime
    @sustainTime  = options.sustainTime
    @releaseTime  = options.releaseTime
    @totalTime    = options.attackTime + options.decayTime + options.sustainTime + options.releaseTime

  getMultiplier: (localTime) ->
    if localTime <= @attackTime
      # Attack
      localTime / @attackTime
    else if localTime <= @attackTime + @decayTime
      # Plot a line between (attackTime, 1) and (attackTime + decayTime, sustainLevel)
      # y = mx+b (remember m is slope, b is y intercept)
      # m = (y2 - y1) / (x2 - x1)
      m = (@sustainLevel - 1) / ((@attackTime + @decayTime) - @attackTime)
      # plug in point (attackTime, 1) to find b:
      # 1 = m(attackTime) + b
      # 1 - m(attackTime) = b
      b = 1 - m * @attackTime
      # and solve, given x = localTime
      m * localTime + b
    else if localTime <= @attackTime + @decayTime + @sustainTime
      # Sustain
      @sustainLevel
    else if localTime <= @totalTime
      # Plot a line between (attackTime + decayTime + sustainTime, sustainLevel) and (totalTime, 0)
      # y = mx+b (remember m is slope, b is y intercept)
      # m = (y2 - y1) / (x2 - x1)
      m = (0 - @sustainLevel) / (@totalTime - (@attackTime + @decayTime + @sustainTime))
      # plug in point (totalTime, 0) to find b:
      # 0 = m(totalTime) + b
      # 0 - m(totalTime) = b
      b = 0 - m * @totalTime
      # and solve, given x = localTime
      m * localTime + b
    else
      0

  realProcess: (time, inputSample) ->
    @startTime ?= time
    localTime = time - @startTime
    inputSample * @getMultiplier(localTime)

  ###
  process()
  ---------

  Arguments
  A single instance of Oscillator, or the returned value from another process()
  call.

  Returns
  An object that can be passed into play(), used in buildSample(), or passed
  into another object's process() method. More precisely, process() returns a
  closure in the format of `(time) -> sample`.

  Usage 1
  someOscillator = new Oscillator
  envelope.process(someOscillator)

  Usage 2
  someOscillator1 = new Oscillator
  someOscillator2 = new Oscillator
  envelope.process(mixer.process(someOscillator1, someOscillator2))

  ###
  process: (child) ->
    unless arguments.length == 1
      throw new Error "#{@constructor.name}.process() only accepts a single argument."
    unless Function.isFunction(child)
      throw new Error "#{@constructor.name}.process() requires a sound generator but did not receive any."
    f = (time) => @realProcess(time, child(time))
    f.duration = @attackTime + @decayTime + @sustainTime + @releaseTime
    f


###
Mixer Class
--------------------------------------------------------------------------------
A mixer primarily does two things: adjust the volume of a signal, and add
multiple signals together into one.

Most process() methods allow only a single argument. If you'd like to process
multiple signals, you can combine them first using this class.

Constants
  None

Arguments
  gain:     Gain amount in dB. Optional. Default -7.0. Float value.

Returns
An object with a process() method, ready to accept multiple oscillators, or any
results of calls to other process() methods.

Usage 1 (JS)
var oscillator1 = new Oscillator();
var oscillator2 = new Oscillator({frequency: Frequency.A_4});
var mixer = new Mixer({ gain: -5.0 });
var processor = mixer.process(oscillator1, oscillator2);
var buildSample = function(time){
  return processor(time);
}

Usage 2 (JS)
var oscillator1 = new Oscillator();
var oscillator2 = new Oscillator({frequency: Frequency.A_4});
var envelope = new Envelope();
var mixer = new Mixer({ gain: -5.0 });
var processor = envelope.process(mixer.process(oscillator1, oscillator2));
var buildTrack = function(){
  this.play(processor);
}

###
class Mixer
  constructor: (options={}) ->
    # Calculate amplitude multiplier given perceived dB gain.
    # http://www.sengpielaudio.com/calculator-loudness.htm
    @setGain(options.gain || -7.0)

  getGain: -> @gain
  setGain: (@gain=-7.0) ->
    @multiplier = Math.pow(10, @gain / 20)

  ###
  process()
  ---------

  Arguments
  Multiple instances of Oscillator, or the returned values from other process()
  calls.

  Returns
  An object that can be passed into play(), used in buildSample(), or passed
  into another object's process() method. More precisely, process() returns a
  closure in the format of `(time) -> sample`.

  Usage 1
  someOscillator = new Oscillator
  envelope.process(someOscillator)

  Usage 2
  someOscillator1 = new Oscillator
  someOscillator2 = new Oscillator
  envelope.process(mixer.process(someOscillator1, someOscillator2))
  ###
  process: (nestedProcessors...) ->
    f = (time, globalTime) =>
      sample = 0
      for processor in nestedProcessors when (!processor.duration? || time <= processor.duration)
        sample += @multiplier * processor(time, globalTime)
      sample

    # Find longest child duration or leave empty if ANY child runs indefinitely
    duration = -1
    for processor in nestedProcessors
      if processor.duration?
        duration = Math.max(duration, processor.duration)
      else
        duration = -1
        break

    f.duration = duration if duration > 0
    f


###
Filter Class
--------------------------------------------------------------------------------
Utility class to attenuate the different frequency components of a signal.

For example white noise (e.g.: (t) -> Math.random() * 2 - 1), contains a wide
range of frequencies. By filtering this noise you can shape the resulting sound.
This is best understood through experimentation.

This class implements a Biquad filter, a workhorse for general-purpose filter
use.

Filters are complex; it's not always intuitive how a parameter value will affect
the resulting frequency response. It may be helpful to use a frequency response
calculator, like this one, which is really nice:
http://www.earlevel.com/main/2013/10/13/biquad-calculator-v2/

Constants
  Filter.LOW_PASS:                  Filter type. Let low frequencies through.
  Filter.HIGH_PASS:                 Filter type. Let high frequencies through.
  Filter.BAND_PASS_CONSTANT_SKIRT:  Filter type. Let a range of frequencies
                                    through. Optionally uses the band width
                                    parameter (`filter.setBW(width)`).
  Filter.BAND_PASS_CONSTANT_PEAK:   Filter type. Let a range of frequencies
                                    through. Optionally uses the band width
                                    parameter (`filter.setBW(width)`).
  Filter.NOTCH:                     Filter type. Remove a narrow range of
                                    frequencies.
  Filter.ALL_PASS:                  Filter type. Let all frequencies through.
  Filter.PEAKING_EQ:                Filter type. Boost frequencies around a
                                    specific value. Optionally uses the
                                    setDbGain value.
  Filter.LOW_SHELF:                 Filter type. Boost low-frequency sounds.
                                    Optionally uses the setDbGain value.
  Filter.HIGH_SHELF:                Filter type. Boost high-frequency sounds.
                                    Optionally uses the setDbGain value.

Arguments
  type:       Optional. Default Filter.LOW_PASS. Accepts any filter type.
  frequency:  Optional. Default 300. A value in Hz specifying the midpoint or
              cutoff frequency of the filter.

Returns
An object with a process() method, ready to accept multiple oscillators, or any
results of calls to other process() methods.

Usage 1 (JS):
  require('v1/instruments');
  var oscillator = new Oscillator({type: Oscillator.SQUARE, frequency: 55})
  var filter = new Filter();
  var processor = filter.process(oscillator);
  var buildSample = function(time){
    return processor(time);
  }

Usage 2 (JS):
  require('v1/instruments');
  var oscillator = new Oscillator({frequency: Frequency.A_3, type: Oscillator.NOISE});
  var filter = new Filter({type: Filter.HIGH_PASS, frequency: 10000});
  var envelope = new Envelope();
  var buildTrack = function(){
   this.play(envelope.process(filter.process(oscillator)));
  }

###
#  Biquad filter
#  Created by Ricard Marxer <email@ricardmarxer.com> on 2010-05-23.
#  Copyright 2010 Ricard Marxer. All rights reserved.
#  Translated to CoffeeScript by Ed McManus
#
# Implementation based on:
# http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt
class Filter

  # Biquad filter types
  @LOW_PASS = 0                # H(s) = 1 / (s^2 + s/Q + 1)
  @HIGH_PASS = 1                # H(s) = s^2 / (s^2 + s/Q + 1)
  @BAND_PASS_CONSTANT_SKIRT = 2 # H(s) = s / (s^2 + s/Q + 1)  (constant skirt gain, peak gain = Q)
  @BAND_PASS_CONSTANT_PEAK = 3  # H(s) = (s/Q) / (s^2 + s/Q + 1)      (constant 0 dB peak gain)
  @NOTCH = 4              # H(s) = (s^2 + 1) / (s^2 + s/Q + 1)
  @ALL_PASS = 5                # H(s) = (s^2 - s/Q + 1) / (s^2 + s/Q + 1)
  @PEAKING_EQ = 6         # H(s) = (s^2 + s*(A/Q) + 1) / (s^2 + s/(A*Q) + 1)
  @LOW_SHELF = 7          # H(s) = A * (s^2 + (sqrt(A)/Q)*s + A)/(A*s^2 + (sqrt(A)/Q)*s + 1)
  @HIGH_SHELF = 8         # H(s) = A * (A*s^2 + (sqrt(A)/Q)*s + 1)/(s^2 + (sqrt(A)/Q)*s + A)

  # Biquad filter parameter types
  @Q = 1
  @BW = 2 # SHARED with BACKWARDS LOOP MODE
  @S = 3

  constructor: (options={}) ->
    throw new Error "Must specify filter type." unless options.type?

    @Fs = SAMPLE_RATE
    @type = options.type # type of the filter
    @parameterType = Filter.Q # type of the parameter

    @x_1_l = 0
    @x_2_l = 0
    @y_1_l = 0
    @y_2_l = 0

    @x_1_r = 0
    @x_2_r = 0
    @y_1_r = 0
    @y_2_r = 0

    @b0 = 1
    @a0 = 1

    @b1 = 0
    @a1 = 0

    @b2 = 0
    @a2 = 0

    @b0a0 = @b0 / @a0
    @b1a0 = @b1 / @a0
    @b2a0 = @b2 / @a0
    @a1a0 = @a1 / @a0
    @a2a0 = @a2 / @a0

    @f0 = options.frequency || 300  # "wherever it's happenin', man."  Center Frequency or
                                    # Corner Frequency, or shelf midpoint frequency, depending
                                    # on which filter type.  The "significant frequency".

    @dBgain = 12      # used only for peaking and shelving filters

    @Q = 1            # the EE kind of definition, except for peakingEQ in which A*Q is
                      # the classic EE Q.  That adjustment in definition was made so that
                      # a boost of N dB followed by a cut of N dB for identical Q and
                      # f0/Fs results in a precisely flat unity gain filter or "wire".

    @BW = -3          # the bandwidth in octaves (between -3 dB frequencies for BPF
                      # and notch or between midpoint (dBgain/2) gain frequencies for
                      # peaking EQ

    @S = 1            # a "shelf slope" parameter (for shelving EQ only).  When S = 1,
                      # the shelf slope is as steep as it can be and remain monotonically
                      # increasing or decreasing gain with frequency.  The shelf slope, in
                      # dB/octave, remains proportional to S for all other values for a
                      # fixed f0/Fs and dBgain.

    # Since we now accept frequency as an option
    @recalculateCoefficients()


  ###
  setFrequency()
  Alias for setF0(). Sometimes referred to as the center frequency, midpoint
  frequency, or cutoff frequency, depending on filter type.

  Arguments
  Number value representing center frequency in Hz. Default 300.
  ###
  setFrequency: (freq) ->
    @setF0(freq)
  getFrequency: -> @f0

  ###
  setQ()
  "Q factor"

  Arguments
  Number value representing the filter's Q factor. Only used in some filter
  types. To see the impact Q has on the filter's frequency response, use the
  calculator at: http://www.earlevel.com/main/2013/10/13/biquad-calculator-v2/
  ###
  getQ: -> @Q
  setQ: (q) ->
    @parameterType = Filter.Q
    @Q = Math.max(Math.min(q, 115.0), 0.001)
    @recalculateCoefficients()

  #
  # Advanced filter parameters
  coefficients: ->
    b = [@b0, @b1, @b2]
    a = [@a0, @a1, @a2]
    {b: b, a: a}

  setFilterType: (type) ->
    @type = type
    @recalculateCoefficients()

  ###
  setBW()
  Set band width value used in "band" filter types.

  Arguments
  Number value representing the filter's band width. Ignored unless filter type
  is set to band pass.
  ###
  setBW: (bw) ->
    @parameterType = Filter.BW
    @BW = bw
    @recalculateCoefficients()

  setS: (s) ->
    @parameterType = Filter.S
    @S = Math.max(Math.min(s, 5.0), 0.0001)
    @recalculateCoefficients()

  ###
  setF0()
  Sometimes referred to as the center frequency, midpoint frequency, or cutoff
  frequency, depending on filter type.

  Arguments
  Number value representing center frequency in Hz. Default 300.
  ###
  setF0: (freq) ->
    @f0 = freq
    @recalculateCoefficients()

  setDbGain: (g) ->
    @dBgain = g
    @recalculateCoefficients()

  recalculateCoefficients: ->
    if @type == Filter.PEAKING_EQ || @type == Filter.LOW_SHELF || @type == Filter.HIGH_SHELF
      A = Math.pow(10, (@dBgain/40))  # for peaking and shelving EQ filters only
    else
      A  = Math.sqrt( Math.pow(10, (@dBgain/20)) )

    w0 = 2 * Math.PI * @f0 / @Fs

    cosw0 = Math.cos(w0)
    sinw0 = Math.sin(w0)

    alpha = 0

    switch @parameterType
      when Filter.Q
        alpha = sinw0/(2*@Q)
      when Filter.BW
        alpha = sinw0 * sinh( Math.LN2/2 * @BW * w0/sinw0 )
      when Filter.S
        alpha = sinw0/2 * Math.sqrt( (A + 1/A)*(1/@S - 1) + 2 )

    #
    #   FYI: The relationship between bandwidth and Q is
    #        1/Q = 2*sinh(ln(2)/2*BW*w0/sin(w0))      (digital filter w BLT)
    #   or   1/Q = 2*sinh(ln(2)/2*BW)                 (analog filter prototype)
    #
    #   The relationship between shelf slope and Q is
    #        1/Q = sqrt((A + 1/A)*(1/S - 1) + 2)
    #

    switch @type
      when Filter.LOW_PASS       # H(s) = 1 / (s^2 + s/Q + 1)
        @b0 =  (1 - cosw0)/2
        @b1 =   1 - cosw0
        @b2 =  (1 - cosw0)/2
        @a0 =   1 + alpha
        @a1 =  -2 * cosw0
        @a2 =   1 - alpha

      when Filter.HIGH_PASS       # H(s) = s^2 / (s^2 + s/Q + 1)
        @b0 =  (1 + cosw0)/2
        @b1 = -(1 + cosw0)
        @b2 =  (1 + cosw0)/2
        @a0 =   1 + alpha
        @a1 =  -2 * cosw0
        @a2 =   1 - alpha

      when Filter.BAND_PASS_CONSTANT_SKIRT       # H(s) = s / (s^2 + s/Q + 1)  (constant skirt gain, peak gain = Q)
        @b0 =   sinw0/2
        @b1 =   0
        @b2 =  -sinw0/2
        @a0 =   1 + alpha
        @a1 =  -2*cosw0
        @a2 =   1 - alpha

      when Filter.BAND_PASS_CONSTANT_PEAK       # H(s) = (s/Q) / (s^2 + s/Q + 1)      (constant 0 dB peak gain)
        @b0 =   alpha
        @b1 =   0
        @b2 =  -alpha
        @a0 =   1 + alpha
        @a1 =  -2*cosw0
        @a2 =   1 - alpha

      when Filter.NOTCH     # H(s) = (s^2 + 1) / (s^2 + s/Q + 1)
        @b0 =   1
        @b1 =  -2*cosw0
        @b2 =   1
        @a0 =   1 + alpha
        @a1 =  -2*cosw0
        @a2 =   1 - alpha

      when Filter.ALL_PASS       # H(s) = (s^2 - s/Q + 1) / (s^2 + s/Q + 1)
        @b0 =   1 - alpha
        @b1 =  -2*cosw0
        @b2 =   1 + alpha
        @a0 =   1 + alpha
        @a1 =  -2*cosw0
        @a2 =   1 - alpha

      when Filter.PEAKING_EQ  # H(s) = (s^2 + s*(A/Q) + 1) / (s^2 + s/(A*Q) + 1)
        @b0 =   1 + alpha*A
        @b1 =  -2*cosw0
        @b2 =   1 - alpha*A
        @a0 =   1 + alpha/A
        @a1 =  -2*cosw0
        @a2 =   1 - alpha/A

      when Filter.LOW_SHELF   # H(s) = A * (s^2 + (sqrt(A)/Q)*s + A)/(A*s^2 + (sqrt(A)/Q)*s + 1)
        coeff = sinw0 * Math.sqrt( (A^2 + 1)*(1/@S - 1) + 2*A )
        @b0 =    A*((A+1) - (A-1)*cosw0 + coeff)
        @b1 =  2*A*((A-1) - (A+1)*cosw0)
        @b2 =    A*((A+1) - (A-1)*cosw0 - coeff)
        @a0 =       (A+1) + (A-1)*cosw0 + coeff
        @a1 =   -2*((A-1) + (A+1)*cosw0)
        @a2 =       (A+1) + (A-1)*cosw0 - coeff

      when Filter.HIGH_SHELF   # H(s) = A * (A*s^2 + (sqrt(A)/Q)*s + 1)/(s^2 + (sqrt(A)/Q)*s + A)
        coeff = sinw0 * Math.sqrt( (A^2 + 1)*(1/@S - 1) + 2*A )
        @b0 =    A*((A+1) + (A-1)*cosw0 + coeff)
        @b1 = -2*A*((A-1) + (A+1)*cosw0)
        @b2 =    A*((A+1) + (A-1)*cosw0 - coeff)
        @a0 =       (A+1) - (A-1)*cosw0 + coeff
        @a1 =    2*((A-1) - (A+1)*cosw0)
        @a2 =       (A+1) - (A-1)*cosw0 - coeff

    @b0a0 = @b0/@a0
    @b1a0 = @b1/@a0
    @b2a0 = @b2/@a0
    @a1a0 = @a1/@a0
    @a2a0 = @a2/@a0


  ###
  process()
  ---------

  Arguments
  A single instance of Oscillator or the returned value from another process()
  call (such as Mixer).

  Returns
  An object that can be passed into play(), used in buildSample(), or passed
  into another object's process() method. More precisely, process() returns a
  closure in the format of `(time) -> sample`.

  Usage 1
  var someOscillator = new Oscillator({type: Oscillator.SAWTOOTH});
  var filter = new Filter;
  var processor = filter.process(someOscillator);
  var buildSample = function(time) {
    return processor(time);
  }

  Usage 2
  var someOscillator1 = new Oscillator({type: Oscillator.SQUARE});
  var someOscillator2 = new Oscillator;
  var filter = new Fiter;
  var processor = filter.process(envelope.process(mixer.process(someOscillator1, someOscillator2)));
  var buildSample = function(time) {
    return processor(time);
  }

  ###
  process: (child) ->
    unless Function.isFunction(child)
      throw new Error "#{@constructor.name}.process() requires a sound generator but did not receive any."
    f = (time) => @realProcess(time, child(time))
    f.duration = child.duration if child.duration
    f

  realProcess: (time, inputSample) ->
    #y[n] = (b0/a0)*x[n] + (b1/a0)*x[n-1] + (b2/a0)*x[n-2]
    #       - (a1/a0)*y[n-1] - (a2/a0)*y[n-2]
    sample = inputSample

    output = @b0a0*sample + @b1a0*@x_1_l + @b2a0*@x_2_l - @a1a0*@y_1_l - @a2a0*@y_2_l
    @y_2_l = @y_1_l
    @y_1_l = output
    @x_2_l = @x_1_l
    @x_1_l = sample

    output
