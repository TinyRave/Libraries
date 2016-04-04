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
  var buffer, channelBufferSize, i, j, ref, ref1, sample, sampleRate, timeOffset, type;
  if (message.data[0] === "generate") {
    ref = message.data, type = ref[0], channelBufferSize = ref[1], sampleRate = ref[2];
    timeOffset = tr_samplesGenerated / sampleRate;
    buffer = new Float64Array(channelBufferSize * 2);
    if (typeof buildSample !== "undefined" && buildSample !== null) {
      for (i = j = 0, ref1 = channelBufferSize; 0 <= ref1 ? j < ref1 : j > ref1; i = 0 <= ref1 ? ++j : --j) {
        sample = buildSample(tr_samplesGenerated / sampleRate);
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
