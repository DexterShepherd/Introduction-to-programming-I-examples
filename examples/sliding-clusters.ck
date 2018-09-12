// Sliding Clusters Example
// Dexter Shepherd - 2018

// Define the notes in our scale and an offset
[0, 2, 3, 5, 7, 10] @=> int scale[];
[0, 12, 24, 36] @=> int octaves[];
45 => int root;

// define the max voices and sequence length
8 => int numVoices;
7 => int seqLen;

// set up arrays to store the chord sequence, gain sequence,
// time sequence, and slide time sequence
int chords[seqLen][numVoices];
float gains[seqLen][numVoices];
dur times[seqLen];
dur slideTimes[seqLen];

// fill the time and slide time arrays with data
for ( 0 => int i; i < seqLen; i++) {
  Math.random2(1500, 3000)::ms => times[i];
  Math.random2(50, 200)::ms => slideTimes[i];
}

// fill the chords and gain arrays
fillChords();

// define some signal chain
// osc -> master bus
SinOsc oscs[numVoices];
Gain master => dac;
for(0 => int i; i < numVoices; i++) {
  // set initial gains to 0
  0 => oscs[i].gain;
  oscs[i]  => master;
}

// define an envelope for the "slide" effect
Envelope slide => blackhole;

// main loop
0 => int counter;
while(true) {
  spork ~ slidePitches(counter);
  times[counter] => now;
  (counter + 1) % seqLen => counter;
}

// fill the chord arrays with random sequences
// fill the gains array with random floats
fun void fillChords() {
  for(0 => int i; i < seqLen; i++) {
    for(0 => int j; j < numVoices; j++) {
      Math.random2(0, scale.size() - 1) => int index;
      octaves[Math.random2(0, octaves.size() - 1)] => int octave;
      scale[index] + root + octave => chords[i][j];
      Math.random2f(0.0, 1.0 / numVoices) => gains[i][j];
    }
  }
}

// the meat of the thing
fun void slidePitches(int c) {
  // set the new slide duration
  slideTimes[c] => slide.duration;
  // figure out when to stop sliding
  now + slide.duration() => time end;

  // define some arrays for the previous gains and freqs
  // ( so we can interpolate between them )
  float lastFreqs[numVoices];
  float lastGains[numVoices];
  for ( 0 => int i; i < numVoices; i++ ) {
    oscs[i].freq() => lastFreqs[i];
    oscs[i].gain() => lastGains[i];
  }

  // start the slide
  slide.keyOn();
  // until the slide is over
  while( now < end ) {
    // set each osc freq and gain to a value
    // between the last value and the next value
    // dependant on the slide value
    // when slide is 0, everything is at the old value
    // when slide is 1, everything is at the next value
    for(0 => int i; i < numVoices; i++) {
      Std.scalef(
        slide.value(),
        0.0, 1.0,
        lastFreqs[i], Std.mtof(chords[c][i])
      ) => oscs[i].freq;
      Std.scalef(
        slide.value(),
        0.0, 1.0,
        lastGains[i], gains[c][i]
      ) => oscs[i].gain;
    }
    // move time forward by samples
    1::samp => now;
  }
  // reset the envelope
  slide.keyOff();
}
