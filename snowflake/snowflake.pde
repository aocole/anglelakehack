import processing.sound.*;
int CUTOFF = 5;

class Ring
{
  float x, y, size, intensity, hue;

  void respawn(float newX, float newY, float newIntensity, float newHue)
  {
    x = newX;
    y = newY;
    intensity = newIntensity;
    hue = newHue;

    // Default size is based on the screen size
    size = height * 0.025;
  }

  void draw()
  {
    // Particles fade each frame
    intensity *= 0.90;
    
    // They grow at a rate based on their intensity
    size += height * intensity * 0.01;

    // If the particle is still alive, draw it
    if (intensity >= CUTOFF) {
      blendMode(ADD);
      tint(hue, 50, intensity);
      image(texture, x - size/2, y - size/2, size, size);
    }
  }
};


SoundFile sample;
OPC opc;
PImage texture;
Ring rings[];
float smoothX, smoothY;
boolean f = false;
Amplitude rms;
FFT fft;

// Declare a smooth factor to smooth out sudden changes in amplitude.
// With a smooth factor of 1, only the last measured amplitude is used for the
// visualisation, which can lead to very abrupt changes. As you decrease the
// smooth factor towards 0, the measured amplitudes are averaged across frames,
// leading to more pleasant gradual changes
float smoothingFactor = 0.25;

// Used for storing the smoothed amplitude value
float sum;

public void settings() {
  size(640, 640, P3D);
}

public void setup() {
  colorMode(HSB, 100);
  setupSound();
  setupFC();
  setupRings();
}

public void draw() {
 //drawSound();
 drawRings();
}

public void setupSound() {
  //Load and play a soundfile and loop it
  sample = new SoundFile(this, "jinglebellscreepy.wav");
  sample.loop();

  // Create and patch the rms tracker
  rms = new Amplitude(this);
  rms.input(sample);

  // Create the FFT analyzer and connect the playing soundfile to it.
  fft = new FFT(this, bands);
  fft.input(sample);
}      

public void drawSound() {
  // Set background color, noStroke and fill color
  background(125, 255, 125);
  noStroke();
  fill(255, 0, 150);

  float amp = getAmp() * height * 15;
  // We draw a circle whose size is coupled to the audio analysis
  ellipse(width/2, height/2, amp, amp);
}

float getAmp() {
  // smooth the rms data by smoothing factor
  sum += (rms.analyze() - sum) * smoothingFactor;

  // rms.analyze() return a value between 0 and 1
  return sum;
}

void setupFC()
{
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, true, false);
}

void setupRings() {
  texture = loadImage("ring2.png");
  // We can have up to 100 rings. They all start out invisible.
  rings = new Ring[100];
  for (int i = 0; i < rings.length; i++) {
    rings[i] = new Ring();
  }
}

int lastDrawn = 0;
void drawRings() {
  background(0);

  // Smooth out the mouse location. The smoothX and smoothY variables
  // move toward the mouse without changing abruptly.
  float prevX = smoothX;
  float prevY = smoothY;
  smoothX += (mouseX - smoothX) * 0.1;
  smoothY += (mouseY - smoothY) * 0.1;

  float a = getAmp();
  float f = getDominantFreq();
  println("amp:", a, " freq:", f);
  float intensity = map(a, 0.0, 1.0, 5, 70);
  float hue = map(f, 2, 40, 100, 0);
  println("i:", intensity, " h:", hue);
  // At every frame, randomly respawn one ring
  lastDrawn = (lastDrawn + 1) % rings.length;
  rings[lastDrawn].respawn(prevX, prevY, intensity, hue);

  // Give each ring a chance to redraw and update
  for (int i = 0; i < rings.length; i++) {
    rings[i].draw();
  }
}

// Define how many FFT bands to use (this needs to be a power of two)
int bands = 512;
int portion = 8; // only the first bands/portion is used

// Define a smoothing factor which determines how much the spectrums of consecutive
// points in time should be combined to create a smoother visualisation of the spectrum.
// A smoothing factor of 1.0 means no smoothing (only the data from the newest analysis
// is rendered), decrease the factor down towards 0.0 to have the visualisation update
// more slowly, which is easier on the eye.
float fftSmoothingFactor = 0.5;

// Create a vector to store the smoothed spectrum data in
float[] fftSum = new float[bands/portion];
float getDominantFreq() {
  // Perform the analysis
  fft.analyze();

  int highIndex = 0;
  for (int i = 0; i < bands/portion; i++) {
    // Smooth the FFT spectrum data by smoothing factor
    fftSum[i] += (fft.spectrum[i] - fftSum[i]) * fftSmoothingFactor;

    // find the index of the frequency band with the highest power
    if (fftSum[i] >= fftSum[highIndex]) {
      highIndex = i;
    }
  }

  return highIndex; 
}
