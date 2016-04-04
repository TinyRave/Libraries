errorMessages = []
Error = (newMessage) ->
  if errorMessages.indexOf(newMessage) == -1
    console.error newMessage
    errorMessages.push newMessage

class Oscillator
  # Oscillator Types
  @SINE           = 0
  @SQUARE         = 1
  @SAWTOOTH       = 2
  @TRIANGLE       = 3
  @BELL           = 4
  @BELL_REAL      = 5
  @NOISE          = 6

  constructor: (options={}) ->
    @frequency = options.frequency || 440
    @type = options.type || Oscillator.SINE
    @inverted = !!options.inverted

  process: (state={}) ->
    if arguments.length > 1
      Error "Oscillator.process() only takes 1 argument. Others will be ignored."
    @startTime ?= state.time
    localTime = state.time - @startTime
    state.sample = switch @type
      when Oscillator.SINE
        @sine(localTime)
      when Oscillator.SQUARE
        @square(localTime)
      when Oscillator.SAWTOOTH
        @sawtooth(localTime)
      when Oscillator.TRIANGLE
        @triangle(localTime)
      when Oscillator.BELL
        @bell(localTime)
      when Oscillator.BELL_REAL
        @bell_real(localTime)
      when Oscillator.NOISE
        Math.random() * 2 - 1
    state.sample *= -1 if @inverted
    state

  sine: (localTime) ->
    Math.sin(Math.PI * 2 * @frequency * localTime)

  square: (localTime) ->
    sample = Math.sin(Math.PI * 2 * @frequency * localTime)
    if sample > 0
      1
    else
      -1

  sawtooth: (localTime) ->
    hzDuration = 1 / @frequency
    progress = (localTime % hzDuration) / hzDuration
    progress * 2 - 1

  triangle: (localTime) ->
    hzDuration = 1 / @frequency
    progress = (localTime % hzDuration) / hzDuration
    if progress <= 0.5
      (progress * 2) * 2 - 1
    else
      2 - (progress * 2) * 2 - 1

  bell: (localTime) ->
    fundamental = @frequency
    # Ideal, per https://en.wikipedia.org/wiki/Strike_tone
    0.1 * (
      Math.sin(fundamental * 0.50 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 1.00 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 1.20 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 1.50 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 2.00 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 2.50 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 2.67 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 3.00 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 4.00 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 5.33 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 6.67 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 8.00 * Math.PI * 2 * localTime)
    )

  bell_real: (localTime) ->
    fundamental = @frequency
    # Actual, per https://en.wikipedia.org/wiki/Strike_tone
    0.1 * (
      Math.sin(fundamental * 0.500 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 1.000 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 1.183 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 1.506 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 2.000 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 2.514 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 2.662 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 3.011 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 4.166 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 5.433 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 6.796 * Math.PI * 2 * localTime) +
      Math.sin(fundamental * 8.215 * Math.PI * 2 * localTime)
    )


class PulseWidthModulator
  constructor: (options={}) ->
    modulatorType = options.modulatorType || Oscillator.SINE
    modulatorFrequency = options.modulatorFrequency || 5
    @modulator = new Oscillator(type: modulatorType, frequency: modulatorFrequency)
    @depth = options.depth || 0.5

  process: (state={}) ->
    modulatorSample = @depth * @modulator.process(time: state.time).sample
    modulatedSample = if state.sample > modulatorSample then -1 else 1
    { time: state.time, sample: modulatedSample }


class Envelope
  # Envelope types
  @AD   = 0
  @ADSR = 1

  constructor: (options={}) ->
    options.sustainLevel  ?= 0.3
    options.type          ?= Envelope.AD

    if options.type == Envelope.AD
      unless options.attackTime? && options.decayTime?
        Error "Options must specify 'attackTime' and 'decayTime' values for AD envelope type."
      options.sustainTime = 0
      options.releaseTime = 0
      options.sustainLevel = 0

    unless options.attackTime? && options.decayTime? && options.sustainTime? && options.releaseTime?
      Error "Options must specify 'attackTime', 'decayTime', 'sustainTime' and 'releaseTime' values for ADSR envelope type."

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
      # Decay
      progress = (localTime - @attackTime) / @decayTime
      @sustainLevel + ((1 - progress) * (1 - @sustainLevel))
    else if localTime <= @attackTime + @decayTime + @releaseTime
      # Sustain
      @sustainLevel
    else if localTime <= @totalTime
      # Release
      adsTime = @attackTime + @decayTime + @sustainTime
      progress = (localTime - adsTime) / @releaseTime
      (1 - progress) * @sustainLevel
    else
      0

  process: (state) ->
    if arguments.length > 1
      Error "Envelope.process() only takes 1 argument. Others will be ignored."
    @startTime ?= state.time
    localTime = state.time - @startTime
    state.sample = state.sample * @getMultiplier(localTime)
    state


class Mixer
  constructor: (options={}) ->
    # Calculate amplitude multiplier given perceived dB gain.
    # http://www.sengpielaudio.com/calculator-loudness.htm
    options.gain ?= -7.0
    @multiplier = Math.pow(10, options.gain / 20)
    @debugName = options.name

  process: (signalStates...) ->
    # Verify the time offsets are correct
    signalStates ?= [{}]
    t1 = signalStates[0].time
    sample = 0
    for state in signalStates
      if state.time != t1
        Error "Mixing signals with different time values. Because
        the mixer can only return 1 time value in mixer states, you may get
        unexpected results. Mixer: #{@debugName}."
      sample += @multiplier * state.sample

    if sample > 1 || sample < -1
      Error "Signal out of range. Reduce signal volume when creating
      the Mixer instance. Mixer: #{@debugName}."
      sample = Math.min(1, Math.max(-1, sample))

    {
      sample: sample
      time: t1
    }


#
#  Biquad filter
#
#  Created by Ricard Marxer <email@ricardmarxer.com> on 2010-05-23.
#  Copyright 2010 Ricard Marxer. All rights reserved.
#  Translated to CoffeeScript by Ed McManus
#

# Implementation based on:
# http:#www.musicdsp.org/files/Audio-EQ-Cookbook.txt

# Biquad filter
class Filter

  # Biquad filter types
  @LPF = 0                # H(s) = 1 / (s^2 + s/Q + 1)
  @HPF = 1                # H(s) = s^2 / (s^2 + s/Q + 1)
  @BPF_CONSTANT_SKIRT = 2 # H(s) = s / (s^2 + s/Q + 1)  (constant skirt gain, peak gain = Q)
  @BPF_CONSTANT_PEAK = 3  # H(s) = (s/Q) / (s^2 + s/Q + 1)      (constant 0 dB peak gain)
  @NOTCH = 4              # H(s) = (s^2 + 1) / (s^2 + s/Q + 1)
  @APF = 5                # H(s) = (s^2 - s/Q + 1) / (s^2 + s/Q + 1)
  @PEAKING_EQ = 6         # H(s) = (s^2 + s*(A/Q) + 1) / (s^2 + s/(A*Q) + 1)
  @LOW_SHELF = 7          # H(s) = A * (s^2 + (sqrt(A)/Q)*s + A)/(A*s^2 + (sqrt(A)/Q)*s + 1)
  @HIGH_SHELF = 8         # H(s) = A * (A*s^2 + (sqrt(A)/Q)*s + 1)/(s^2 + (sqrt(A)/Q)*s + A)

  # Biquad filter parameter types
  @Q = 1
  @BW = 2 # SHARED with BACKWARDS LOOP MODE
  @S = 3

  constructor: (options={}) ->
    unless options.type? and options.sampleRate?
    type, sampleRate

    @Fs = sampleRate
    @type = type # type of the filter
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

    @f0 = 3000        # "wherever it's happenin', man."  Center Frequency or
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

  coefficients: ->
    b = [@b0, @b1, @b2]
    a = [@a0, @a1, @a2]
    {b: b, a: a}

  setFilterType: (type) ->
    @type = type
    @recalculateCoefficients()

  setSampleRate: (rate) ->
    @Fs = rate
    @recalculateCoefficients()

  setQ: (q) ->
    @parameterType = Filter.Q
    @Q = Math.max(Math.min(q, 115.0), 0.001)
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
      when Filter.LPF       # H(s) = 1 / (s^2 + s/Q + 1)
        @b0 =  (1 - cosw0)/2
        @b1 =   1 - cosw0
        @b2 =  (1 - cosw0)/2
        @a0 =   1 + alpha
        @a1 =  -2 * cosw0
        @a2 =   1 - alpha

      when Filter.HPF       # H(s) = s^2 / (s^2 + s/Q + 1)
        @b0 =  (1 + cosw0)/2
        @b1 = -(1 + cosw0)
        @b2 =  (1 + cosw0)/2
        @a0 =   1 + alpha
        @a1 =  -2 * cosw0
        @a2 =   1 - alpha

      when Filter.BPF_CONSTANT_SKIRT       # H(s) = s / (s^2 + s/Q + 1)  (constant skirt gain, peak gain = Q)
        @b0 =   sinw0/2
        @b1 =   0
        @b2 =  -sinw0/2
        @a0 =   1 + alpha
        @a1 =  -2*cosw0
        @a2 =   1 - alpha

      when Filter.BPF_CONSTANT_PEAK       # H(s) = (s/Q) / (s^2 + s/Q + 1)      (constant 0 dB peak gain)
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

      when Filter.APF       # H(s) = (s^2 - s/Q + 1) / (s^2 + s/Q + 1)
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

  process: (state) ->
    #y[n] = (b0/a0)*x[n] + (b1/a0)*x[n-1] + (b2/a0)*x[n-2]
    #       - (a1/a0)*y[n-1] - (a2/a0)*y[n-2]
    sample = state.sample

    output = @b0a0*sample + @b1a0*@x_1_l + @b2a0*@x_2_l - @a1a0*@y_1_l - @a2a0*@y_2_l
    @y_2_l = @y_1_l
    @y_1_l = output
    @x_2_l = @x_1_l
    @x_1_l = sample
    {
      sample: output
      time: state.time
    }
