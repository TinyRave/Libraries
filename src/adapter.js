var SAMPLE_RATE = 44100;
var BUFFER_SIZE = 2048; /* Per-channel */

var tr_samplesGenerated = 0;

/**
 * Polyfills
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
if ( !Array.isArray ) {
  Array.isArray = function(arg) {
    return Object.prototype.toString.call(arg) === '[object Array]';
  };
}
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
 *   1) Build the "real" track source: adapter.js (this file) + stdlib.js + your
 *        track compiled to js.
 *   2) Inject the "real" track source into a web worker
 *   3) Send a "generate" message to the web worker
 *   4) Handle the "generate" message and call buildSample() enough times to
 *        fill a stereo buffer with BUFFER_SIZE samples per channel.
 *   5) Send the buffer back up to the web worker host, via:
 *        postMessage(["buffer", buffer])
 *   6) Wait for the next "generate" message
 *   7) Note the host always tries to generate the next buffer before it's
 *        actually needed by the AudioContext.
 */
self.addEventListener('message', function(message) {
  if (message.data[0] === "generate") {
    var timeOffset = tr_samplesGenerated / SAMPLE_RATE;
    buffer = new Float64Array(BUFFER_SIZE * 2);
    if (typeof buildSample !== "undefined" && buildSample !== null) {
      for (var i=0; i < BUFFER_SIZE; i++) {
        var time = tr_samplesGenerated / SAMPLE_RATE;
        if (TinyRave && TinyRave.timer) {
          TinyRave.timer.setTime(time);
        }
        sample = buildSample(time);
        tr_samplesGenerated++;
        switch (typeof sample) {
          case "object":
            buffer[i * 2] = sample[0];
            buffer[i * 2 + 1] = sample[1];
            break;
          case "number":
            buffer[i * 2] = buffer[i * 2 + 1] = sample;
        }
      }
      return postMessage(["buffer", buffer]);
    } else {
      return postMessage(["log", "Your track must define a buildSample() function."]);
    }
  }
});
