// Analogue Shift Register Ideas
// Dexter Shepherd - 2018

// Define a pattern and a root offset
[ 0, 3, 2, 2, 7, 2 ] @=> int sequence[];
40 => int root;

// Declare signal chain
// Osc -> ADSR Envelope -> master bus
SinOsc oscs[5];
ADSR envs[oscs.size()];
Gain master => dac;

for( 0 => int i; i < oscs.size(); i++ ) {
  oscs[i] => envs[i] => master;
  // set gains so we don't explode
  1.0 / oscs.size() => oscs[i].gain;
  // give each voice a different envelope
  envs[i].set(Math.random2(100, 2000)::ms, Math.random2(100, 2000)::ms, 0.0, 0::ms);
}

// Spork the play shreds 1 second apart
for( 0 => int i; i < oscs.size(); i++ ) {
  spork ~ playVoice(i);
  1000::ms => now;
}

// keep the main shred looping
while(true) {
  1::second => now;
}

// The main oscillator play shred
fun void playVoice(int index) {
  // offset a counter by the index of the oscillator ( so each osc
  // plays a different note in the sequence)
  index => int counter;
  // loop forever
  while(true) {
    // Take the frequency of the midi note at sequence[counter]
    // and modulo by sequence length so we don't go out of bounds
    // Add the root offset and an octave offset determined by index
    Std.mtof(sequence[counter % sequence.size()] + root + (12 * index)) => oscs[index].freq;
    // start the envelope
    envs[index].keyOn();
    // wait a random amount of time
    Math.random2(1000, 3000)::ms => now;
    // increment the counter
    counter++;
  }
}

