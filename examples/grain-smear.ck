30 => int numGrains;
Gain master => dac;

100000 => int startPos;
100 => int readChunk;
0.7 => float baseRate;

0 => int samples;

int printer[numGrains];

int shouldEnd[numGrains];

fun void voice(int id) {
  SndBuf g => Envelope e => master;
  "sounds/geosmin.wav" => g.read;
  g.samples() => samples;
  1::ms => e.duration; 
  2.0 / numGrains => g.gain;

  Math.random2(1000, 10000) => int grainLen;

  0 => int counter;
  while(!shouldEnd[id]) {
    (readChunk * counter + startPos)$int % g.samples() => g.pos;

    if ( Math.random2f(0, 1) < 0.2 ) {
      0.5 => g.rate;
      0 => printer[id];
    } else if ( Math.random2f(0, 1) < 0.2 ) {
      2.0 => g.rate;
      2 => printer[id];
    } else {
      1.0 => g.rate;
      1 => printer[id];
    }

    g.rate() * baseRate => g.rate;
    e.keyOn();
    grainLen::samp => now;
    e.keyOff();
    1::ms => now;
    counter++;
  }
}

clearPrinter();
spork ~ print();

for(0 => int i; i < numGrains; i++) {
  spork ~ voice(i);
  500::ms => now;
}


now + 1::minute => time end;
while( now < end ) {
  if ( Math.random2f(0.0, 1.0) > 0.95 ) {
    Math.random2(0, samples) => startPos;
    <<<"                                 ", "">>>;
  }
  1::second => now;
}

for(0 => int i; i < numGrains; i++) {
  1 => shouldEnd[i];
  500::ms => now;
}

fun void clearPrinter() {
  for(0 => int i; i < numGrains; i++) {
    -1 => printer[i];
  }
}

fun void print() {
  "" => string toPrint;
  while(1) {
    for(0 => int i; i < numGrains; i++) {
      if ( printer[i] == 0) {
        cherr <= "|";;
      } else if ( printer[i] == 1 ) {
        cherr <= ".";
      } else if ( printer[i] == 2 ) {
        cherr <= "-";
      } else {
        cherr <= " ";
      }
    }
    cherr <= IO.newline();
    clearPrinter();
    200::ms => now;
  }
}
