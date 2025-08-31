// Fake Strudel process: outputs JSON frames at ~20fps
const fps = 20;
const interval = 1000 / fps;
let t = 0;

setInterval(() => {
  const samples = [];
  const cols = 80;
  for (let i = 0; i < cols; i++) {
    // fake sine waveform
    samples.push(Math.sin((t + i) * 0.1));
  }

  const frame = {
    time: t,
    waveform: samples,
    notes: [
      { pitch: 60 + (t % 12), duration: 0.5 }
    ]
  };

  console.log(JSON.stringify(frame));
  t++;
}, interval);
