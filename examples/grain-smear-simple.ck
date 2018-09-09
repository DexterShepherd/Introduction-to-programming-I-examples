// Dexter Shepherd - 2018

// Define the max amount of grains we want
30 => int numGrains;


// Create a master gain object and chuck it to the speakers
Gain master => dac;

// Set a base start position (in samples) to avoid
// prolonged silence at start of piece
100000 => int startPos;

// The amount we will advance the buffer after each read loop
100 => int readChunk;

// pitch the whole thing down a bit
0.7 => float baseRate;

// We need a global var to store the amount of samples
// in the buffer so we can skip around later on.
// This is a bit of a hack but it works ¯\_(ツ)_/¯
0 => int samples;



// Our main voice shred
fun void voice() {
  // define the buffer and an envelope and
  // chuck them to the master gain
  SndBuf g => Envelope e => master;
  // read a soundfile to the buffer
  "sounds/geosmin.wav" => g.read;

  // save the number of samples in the buffer for jumping
  // around ( see 23 )
  g.samples() => samples;

  // define the envelope duration
  1::ms => e.duration; 

  // set a gain for each voice so we don't blow up
  2.0 / numGrains => g.gain;

  // How long will we play each grain before incrementing
  // by readChunk
  Math.random2(1000, 10000) => int grainLen;

  // A counter to calculate the playhead position
  0 => int counter;

  // forever
  while(true) {
    // determine the start position in samples
    (readChunk * counter + startPos)$int % g.samples() => g.pos;

    // select an octave at "random"
    if ( Math.random2f(0, 1) < 0.2 ) {
      0.5 => g.rate;
    } else if ( Math.random2f(0, 1) < 0.2 ) {
      2.0 => g.rate;
    } else {
      1.0 => g.rate;
    }

    // set the rate to our random octave
    g.rate() * baseRate => g.rate;
    // ramp up the envelope
    e.keyOn();
    // advance time
    grainLen::samp => now;
    // ramp down the envelope
    e.keyOff();
    // advance a short amount of time for the envelope to decay
    1::ms => now;
    // increment the counter
    counter++;
  }
}

// add one grain every 500 ms until we have 30 grains
for(0 => int i; i < numGrains; i++) {
  spork ~ voice();
  500::ms => now;
}


// forever
while( true ) {
  // 1 out of every 20 times
  if ( Math.random2f(0.0, 1.0) > 0.95 ) {
    // jump to a new position
    Math.random2(0, samples) => startPos;
  }
  // advance time
  1::second => now;
}
