/**
 * This script is required for TinyRave tracks to play. A "Track" is actually
 * just this script + your track source, injected into a sandboxed web worker.
 *
 * Adapter.js allows communication between the web worker, where we build frames
 * of audio, and TinyRave.com, which hands the audio frames to your computer's
 * sound system.
 */

/**
 * BUFFER_SIZE may change in the future, but can be ignored by almost all tracks
 *
 * Value is the number of samples, per channel, to generate for each frame of
 * audio.
 */
var BUFFER_SIZE = 2048;
var SAMPLE_RATE; // Will be updated below - undefined until first buildSample()
var TWO_PI = 2 * Math.PI;

// Internal count of samples generated, per channel.
var tr_samplesGenerated = 0;

/**
 * Function.isFunction(obj) Polyfill
 *
 * Returns
 * True if obj looks like a function. False otherwise.
 */
if ( !Function.isFunction ) {
  Function.isFunction = function(arg) {
    return Object.prototype.toString.call(arg) === "[object Function]";
  };
  // Optimization from: http://underscorejs.org/docs/underscore.html#section-143
  if (typeof /./ != 'function' && typeof Int8Array != 'object') {
    Function.isFunction = function(obj) {
      return typeof obj == 'function' || false;
    };
  };
}
/**
 * Array.isArray(obj) Polyfill
 *
 * Returns
 * True if obj looks like an array. False otherwise.
 */
if ( !Array.isArray ) {
  Array.isArray = function(arg) {
    return Object.prototype.toString.call(arg) === '[object Array]';
  };
}
/**
 * arrayInstance.fill(value) Polyfill
 *
 * Fill every slot in the array with `value`. Runs in place.
 *
 * Returns
 * The array instance.
 */
if ( ![].fill) {
  Array.prototype.fill = function( value ) {
    var O = Object( this );
    var len = parseInt( O.length, 10 );
    var start = arguments[1];
    var relativeStart = parseInt( start, 10 ) || 0;
    var k = relativeStart < 0
            ? Math.max( len + relativeStart, 0)
            : Math.min( relativeStart, len );
    var end = arguments[2];
    var relativeEnd = end === undefined
                      ? len
                      : ( parseInt( end)  || 0) ;
    var final = relativeEnd < 0
                ? Math.max( len + relativeEnd, 0 )
                : Math.min( relativeEnd, len );
    for (; k < final; k++) {
        O[k] = value;
    }
    return O;
  };
}

/**
 * Handle messages from the web worker host. Here's how tracks work on TinyRave:
 *
 *   1) Build the "real" track source: concatenate adapter.js (this file) +
 *        stdlib.js + your track compiled to js.
 *   2) Inject the "real" track source into a web worker
 *   3) TinyRave sends a "generate" message to the web worker
 *   4) The web worker handles the "generate" message and call buildSample()
 *        enough times to fill a stereo buffer with BUFFER_SIZE samples per
 *        channel.
 *   5) Send the buffer back to the web worker host, via:
 *        postMessage(["buffer", buffer])
 *   6) The web worker sits idle until the next "generate" message.
 *
 *   Note: the host tries to stay 1 buffer ahead of the AudioContext to have the
 *        next frame ready by the time it's needed. Additionally, it's possible
 *        for the system to pick a different SAMPLE_RATE than the one we specify
 *        so we need to pass it to our worker from the host.
 */
var handleMessage = function(message) {
  var sample;
  if (message.data[0] === "generate") {
    SAMPLE_RATE = message.data[1];
    buffer = new Float64Array(BUFFER_SIZE * 2);
    if (typeof buildSample === "undefined" && typeof buildTrack === "undefined")
    {
      postMessage(["log", "You must define a buildSample() or buildTrack() function."]);
    }
    else
    {
      // StdLib V1 Hooks - if you've defined buildTrack and not buildSample
      if (typeof TinyRave !== "undefined") {
        if (typeof buildSample === "undefined" && typeof buildTrack !== "undefined" && typeof TinyRave.initializeBuildTrack !== "undefined") {
          TinyRave.initializeBuildTrack();
        }
      }

      for (var i=0; i < BUFFER_SIZE; i++) {
        var time = tr_samplesGenerated / SAMPLE_RATE;

        // StdLib V1 Hooks - update global timer
        if (typeof TinyRave !== "undefined") {
          if (TinyRave.timer) {
            TinyRave.timer.setTime(time);
          }
        }

        sample = buildSample(time);
        tr_samplesGenerated++;
        switch (typeof sample) {
          case "object":
            if (sample[0] > 1 || sample[0] < -1 || sample[1] > 1 || sample[1] < -1)
            {
              sample[0] = Math.max(-1, Math.min(sample[0], 1))
              sample[1] = Math.max(-1, Math.min(sample[1], 1))
            }
            buffer[i * 2] = sample[0];
            buffer[i * 2 + 1] = sample[1];
            break;
          case "number":
            if (sample > 1 || sample < -1)
            {
              sample = Math.max(-1, Math.min(sample, 1))
            }
            buffer[i * 2] = buffer[i * 2 + 1] = sample;
        }
      }
      postMessage(["buffer", buffer]);
    }
  }
}
self.addEventListener('message', handleMessage);

/**
 * require()
 *
 * This is just a shorthand wrapper around importScripts, not an implementation
 * of require you may be familiar with. importScripts doesn't expect any modular
 * format. It acts more like include in PHP, or #include in C. All imported
 * scripts are essentially inlined, so global scope is shared.
 *
 * Arguments
 *   Library name. Required. String.
 *
 * Usage
 *   require('v1/instruments')
 *
 * Maintainer note: use special care to make backwards-compatible updates.
 */
var _loadedURLs = [];
var require = function(path){
  var url;
  if (path.indexOf(".js" === -1)){
    path = path + ".js";
  }
  url = "http://tinyrave.com/lib/" + path;
  if (_loadedURLs.indexOf(url.toLowerCase()) === -1) {
    importScripts(url);
    _loadedURLs.push(url.toLowerCase());
  }
}
