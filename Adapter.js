const SAMPLE_RATE = 44100;
const BUFFER_SIZE = 2048; /* Per-channel */

var tr_samplesGenerated = 0;

/**
 * Polyfills
 */
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

self.addEventListener('message', function(message) {
  if (message.data[0] === "generate") {
    var timeOffset = tr_samplesGenerated / SAMPLE_RATE;
    buffer = new Float64Array(BUFFER_SIZE * 2);
    if (typeof buildSample !== "undefined" && buildSample !== null) {
      for (var i=0; i < BUFFER_SIZE; i++) {
        sample = buildSample(tr_samplesGenerated / SAMPLE_RATE);
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
