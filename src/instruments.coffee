_warningMessages = []
_logWarning = (message) ->
  unless message in _warningMessages
    console.error message
    _warningMessages.push message


# Oscillator.construct() arguments (named parameters, e.g.: Oscillator.construct(type: Oscillator.SINE)):
# ------------------------------------------------------------------------------
#   type: Optional. A Oscillator type, e.g. Oscillator.SINE.
#   frequency: Optional. Default 440. Number, or a function that takes a time parameter and returns a frequency. the time argument specifies how long the uGen has been running.
#   phase: Optional. Default 0. Number, or a function that takes a time parameter and returns a phase shift. the time argument specifies how long the uGen has been running.
#   amplitude: Optional. Default 1. Number, or a function that takes a time parameter and returns an amplitude multiplier. *Not* in DeciBell's. the time argument specifies how long the uGen has been running.

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
      # multiple ugens
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
      _logWarning "Options must specify 'attackTime', 'decayTime', 'sustainTime' and 'releaseTime' values for ADSR envelope type."

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

  process: (child) ->
    unless arguments.length == 1
      throw new Error "#{@constructor.name}.process() only accepts a single argument."
    unless Function.isFunction(child)
      throw new Error "#{@constructor.name}.process() requires a sound generator but did not receive any."
    f = (time) => @realProcess(time, child(time))
    f.duration = @attackTime + @decayTime + @sustainTime + @releaseTime
    f


class Mixer
  constructor: (options={}) ->
    # Calculate amplitude multiplier given perceived dB gain.
    # http://www.sengpielaudio.com/calculator-loudness.htm
    @setGain(options.gain || -7.0)

  getGain: -> @gain
  setGain: (@gain=-7.0) ->
    @multiplier = Math.pow(10, @gain / 20)

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


#
#  Biquad filter
#
#  Created by Ricard Marxer <email@ricardmarxer.com> on 2010-05-23.
#  Copyright 2010 Ricard Marxer. All rights reserved.
#  Translated to CoffeeScript by Ed McManus
#

# Implementation based on:
# http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt

# Biquad filter
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

  #
  # Basic parameters
  setFrequency: (freq) ->
    @setF0(freq)
  getFrequency: -> @f0

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

  setBW: (bw) ->
    @parameterType = Filter.BW
    @BW = bw
    @recalculateCoefficients()

  setS: (s) ->
    @parameterType = Filter.S
    @S = Math.max(Math.min(s, 5.0), 0.0001)
    @recalculateCoefficients()

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
