import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus
/*
 * A simple grid sequencer, launching several effects in rhythm.
 */

float BPM = 40;
int[][] pattern = {
  {1, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 1, 0, 0, 0, 0, 0},
  {0, 1, 0, 0, 0, 0, 0, 0},
  {1, 0, 0, 0, 0, 0, 0, 0},
  {1, 0, 1, 0, 0, 0, 0, 0},
  {0, 1, 1, 0, 0, 0, 0, 0},
  {1, 0, 1, 0, 0, 0, 0, 0},
  {1, 1, 0, 0, 0, 0, 0, 0}
};

OPC opc;

// Grid coordinates
int gridX = 20;
int gridY = 20;
int gridSquareSize = 15;
int gridSquareSpacing = 20;

// Timing info
float rowsPerSecond = 2 * BPM / 60.0;
float rowDuration = 1.0 / rowsPerSecond;
float patternDuration = pattern.length / rowsPerSecond;

// LED array coordinates
int ledX = 400;
int ledY = 400;
int ledSpacing = 15;
int ledWidth = ledSpacing * 23;
int ledHeight = ledSpacing * 7;

// Images
PImage imgGreenDot;
PImage imgOrangeDot;
PImage imgPinkDot;
PImage imgPurpleDot;
PImage imgCheckers;
PImage imgGlass;
PImage[] dots;

// Timekeeping
long startTime, pauseTime;

void setup()
{
  size(800, 800);

  imgGreenDot = loadImage("greenDot.png");
  imgOrangeDot = loadImage("orangeDot.png");
  imgPinkDot = loadImage("pinkDot.png");
  imgPurpleDot = loadImage("purpleDot.png");
  imgCheckers = loadImage("checkers.png");
  imgGlass = loadImage("glass.jpeg");

  // Keep our multicolored dots in an array for easy access later
  dots = new PImage[] { imgOrangeDot, imgPurpleDot, imgPinkDot, imgGreenDot };

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Three 8x8 grids side by side
  //opc.ledGrid8x8(0, ledX, ledY, ledSpacing, 0, true);
  //opc.ledGrid8x8(64, ledX - ledSpacing * 8, ledY, ledSpacing, 0, true);
  //opc.ledGrid8x8(128, ledX + ledSpacing * 8, ledY, ledSpacing, 0, true);
  
  //  void ledRing(int index, int count, float x, float y, float radiusmalls, float angle)


  int ledCount = 0;
  //int smallTriangle(float angle, int ledCount)
  ledCount = opc.smallTriangle(0, ledCount);
  ledCount = opc.bigTriangle((1*PI)/3, ledCount);
  ledCount = opc.smallTriangle((2*PI)/3, ledCount);
  ledCount = opc.smallTriangle((3*PI)/3, ledCount);
  ledCount = opc.bigTriangle((4*PI)/3, ledCount);
  ledCount = opc.bigTriangle((5*PI)/3, ledCount);

  ledCount = opc.smallTrapezoidL(0,ledCount);
  ledCount = opc.bigTrapezoidL((1*PI)/3,ledCount);
  ledCount = opc.smallTrapezoidL((2*PI)/3,ledCount);
  ledCount = opc.bigTrapezoidL((3*PI)/3,ledCount);
  ledCount = opc.smallTrapezoidL((4*PI)/3,ledCount);
  ledCount = opc.smallTrapezoidL((5*PI)/3,ledCount);

  ledCount = opc.smallTrapezoidR(0,ledCount);
  ledCount = opc.smallTrapezoidR((1*PI)/3,ledCount);
  ledCount = opc.smallTrapezoidR((2*PI)/3,ledCount);
  ledCount = opc.bigTrapezoidR((3*PI)/3,ledCount);
  ledCount = opc.smallTrapezoidR((4*PI)/3,ledCount);
  ledCount = opc.smallTrapezoidR((5*PI)/3,ledCount);


  //int bitOuter2L(float angle, int ledCount)
  ledCount = opc.bigOuter2L(0, ledCount);
  ledCount = opc.bigOuter4L((1*PI)/3, ledCount);
  ledCount = opc.bigOuter4L((2*PI)/3, ledCount);
  ledCount = opc.bigOuter2L((3*PI)/3, ledCount);
  ledCount = opc.bigOuter4L((4*PI)/3, ledCount);
  ledCount = opc.bigOuter2L((5*PI)/3, ledCount);
  
  ledCount = opc.bigOuter4R(0, ledCount);
  ledCount = opc.bigOuter2R((1*PI)/3, ledCount);
  ledCount = opc.bigOuter4R((2*PI)/3, ledCount);
  ledCount = opc.bigOuter2R((3*PI)/3, ledCount);
  ledCount = opc.bigOuter4R((4*PI)/3, ledCount);
  ledCount = opc.bigOuter2R((5*PI)/3, ledCount);
  
  ledCount = opc.benchL((1*PI)/3, ledCount);
  ledCount = opc.benchR((1*PI)/3, ledCount);
  ledCount = opc.benchL((3*PI)/3, ledCount);
  ledCount = opc.benchR((3*PI)/3, ledCount);
  ledCount = opc.benchL((5*PI)/3, ledCount);  
  ledCount = opc.benchR((5*PI)/3, ledCount);  


  ledCount = opc.cocoon(0, ledCount);
  ledCount = opc.cocoon((1*PI)/3, ledCount);
  ledCount = opc.cocoon((2*PI)/3, ledCount);
  ledCount = opc.cocoon((3*PI)/3, ledCount);
  ledCount = opc.cocoon((4*PI)/3, ledCount);
  ledCount = opc.cocoon((5*PI)/3, ledCount);
  
  MidiBus.list();
  myBus = new MidiBus(this, "SmartPAD", "SmartPAD"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.
  myBus.sendControllerChange(0, 0, 90); // Send a controllerChange

//  opc.ledRing(64,24,ledX - 75,ledY + 42,70.0 / 2, 0.0);
  // Init timekeeping, start the pattern from the beginning
  startPattern();
}

void draw()
{
  background(0);

  long m = millis();
  if (pauseTime != 0) {
    // Advance startTime forward while paused, so we don't make any progress
    long delta = m - pauseTime;
    startTime += delta;
    pauseTime += delta;
  }

  float now = (m - startTime) * 1e-3;
  drawEffects(now);
  drawGrid(now);
  drawInstructions();
}

void clearPattern()
{
  for (int row = 0; row < pattern.length; row++) {
    for (int col = 0; col < pattern[0].length; col++) {
      pattern[row][col] = 0;
    }
  }
}

void startPattern()
{
  startTime = millis();
  pauseTime = 0;
}

void pausePattern()
{
  if (pauseTime == 0) {
    // Pause by stopping the clock and remembering when to unpause at
    pauseTime = millis();
  } else {
    pauseTime = 0;
  }
}   

void mousePressed()
{
  int gx = (mouseX - gridX) / gridSquareSpacing;
  int gy = (mouseY - gridY) / gridSquareSpacing;
  if (gx >= 0 && gx < pattern[0].length && gy >= 0 && gy < pattern.length) {
    pattern[gy][gx] ^= 1;
  }
}

void keyPressed()
{
  if (keyCode == DELETE) clearPattern();
  if (keyCode == BACKSPACE) clearPattern();
  if (keyCode == UP) startPattern();
  if (key == ' ') pausePattern();
}

void drawGrid(float now)
{
  int currentRow = int(rowsPerSecond * now) % pattern.length;
  blendMode(BLEND);

  for (int row = 0; row < pattern.length; row++) {
    for (int col = 0; col < pattern[0].length; col++) {
      fill(pattern[row][col] != 0 ? 190 : 64);
      rect(gridX + gridSquareSpacing * col, gridY + gridSquareSpacing * row, gridSquareSize, gridSquareSize);
    }
    
    if (row == currentRow) {
      // Highlight the current row
      fill(255, 255, 0, 32);
      rect(gridX, gridY + gridSquareSpacing * row,
        gridSquareSpacing * (pattern[0].length - 1) + gridSquareSize, gridSquareSize);
    }
  }
}

void drawInstructions()
{
  int size = 12;
  int x = gridX + gridSquareSpacing * pattern[0].length + 5;
  int y = gridY + size;

  fill(255);
  textSize(size);

  text("<- Click squares to create an effect pattern\n[Delete] to clear, [Space] to pause, [Up] to restart pattern.\n", x, y);
}

void drawEffects(float now)
{
  // To keep this simple and flexible, we'll calculate every possible effect that
  // could be in progress: every grid square, and the previous/next loop of the pattern.
  // Each effect is rendered according to the time difference between the present and
  // when that grid square would fire.

  // When did the current loop of the pattern begin?
  float patternStartTime = now - (now % patternDuration);

  for (int whichPattern = -1; whichPattern <= 1; whichPattern++) {
    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[0].length; col++) {
        if (pattern[row][col] != 0) {
          float patternTime = patternStartTime + patternDuration * whichPattern;
          float firingTime = patternTime + rowDuration * row;
          drawSingleEffect(col, firingTime, now);
        }
      }
    }
  }
}

void drawSingleEffect(int column, float firingTime, float now)
{
  /*
   * Map sequencer columns to effects. Edit this to add your own effects!
   *
   * Parameters:
   *   column -- Number of the column in the sequencer that we're drawing an effect for.
   *   firingTime -- Time at which the effect in question should fire. May be in the
   *                 past or the future. This number also uniquely identifies a particular
   *                 instance of an effect.
   *   now -- The current time, in seconds.
   */

  float timeDelta = now - firingTime;
 
  switch (column) {

    // First four tracks: Colored dots rising from below
    case 0:
    case 1:
    case 2:
    case 3:
//      drawDotEffect(column, timeDelta, dots[column]);
//    drawDotRadial(column, timeDelta, dots[column], 0);  
    drawDotRadial(column, timeDelta, dots[column], column * PI/3);  
      break;
   
    // Stripes moving from left to right. Each stripe particle is unique based on firingTime.
    case 4: drawStripeEffect(firingTime, timeDelta); break;

    // Image spinner overlays
    case 5: drawSpinnerEffect(timeDelta, imgCheckers); break;
    case 6: drawSpinnerEffect(timeDelta, imgGlass); break;

    // Full-frame flash effect
    case 7: drawFlashEffect(timeDelta); break;
  }
}


void drawDotRadial(int column, float time, PImage im, float angle)
{
  // Draw an image dot that hits the bottom of the array at the beat,
  // then quickly shrinks and fades.

  float motionSpeed = rowsPerSecond * 90.0;
  float fadeSpeed = motionSpeed * 1.0;
  float shrinkSpeed = motionSpeed * 1.2;
  float size = 200 - max(0, time * shrinkSpeed);
  float centerX = 0; 
  float topY = (time * motionSpeed) - (size/2) + 400;
  int brightness = int(255 - max(0, fadeSpeed * time));

  // Adjust the 'top' position so the dot seems to appear on-time
  //topY -= size * 0.4;

//  int rotateX(int X, int Y, float angle)
  int X = opc.rotateX(int(centerX),int(topY),angle);
  int Y = opc.rotateY(int(centerX),int(topY),angle);

  X += ledX - (size/2);
  Y += ledY - (size/2);
 
  if (brightness > 0) {
    blendMode(ADD);
    tint(brightness);
    image(im, X, Y, size, size);
  }
}

void drawDotEffect(int column, float time, PImage im)
{
  // Draw an image dot that hits the bottom of the array at the beat,
  // then quickly shrinks and fades.

  float motionSpeed = rowsPerSecond * 90.0;
  float fadeSpeed = motionSpeed * 1.0;
  float shrinkSpeed = motionSpeed * 1.2;
  float size = 200 - max(0, time * shrinkSpeed);
  float centerX = ledX + (column - 1.5) * 75.0;
  float topY = (ledY - time * motionSpeed);
  int brightness = int(255 - max(0, fadeSpeed * time));

  // Adjust the 'top' position so the dot seems to appear on-time
  topY -= size * 0.4;
 
  if (brightness > 0) {
    blendMode(ADD);
    tint(brightness);
    image(im, centerX - size/2, topY, size, size);
  }
}

void drawSpinnerEffect(float time, PImage im)
{
  float t = time / (rowDuration * 1.5);
  if (t < -1 || t > 1) return;

  float angle = time * 5.0;
  float size = 400;
  int alpha = int(128 * (1.0 + cos(t * PI)));

  if (alpha > 0) {
    pushMatrix();
    translate(ledX, ledY);
    rotate(angle);
    blendMode(ADD);
    tint(alpha);
    image(im, -size/2, -size/2, size, size);
    popMatrix();
  }
}

void drawFlashEffect(float time)
{
  float t = time / (rowDuration * 2.0);
  if (t < 0 || t > 1) return;

  // Not super-bright, and with a pleasing falloff
  blendMode(ADD);
  fill(64 * pow(1.0 - t, 1.5));
  rect(0, 0, width, height);
}

void drawStripeEffect(float identity, float time)
{
  // Pick a pseudorandom dot and Y position
  randomSeed(int(identity * 1e3));
  PImage im = dots[int(random(dots.length))];
  float y = ledY - ledHeight/2 + random(ledHeight);

  // Animation
  float motionSpeed = rowsPerSecond * 400.0;
  float x = ledX - ledWidth/2 + time * motionSpeed;
  float sizeX = 300;
  float sizeY = 30;
  
  blendMode(ADD);
  tint(255);
  image(im, x - sizeX/2, y - sizeY/2, sizeX, sizeY);   
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  println("address:"+pitch/16+" "+pitch %16);
  if (pattern[pitch / 16][pitch % 16] == 0){
    pattern[pitch / 16][pitch % 16] = 1;
    myBus.sendNoteOff(channel, pitch, 100);
  }
   else if (pattern[pitch / 16][pitch % 16] == 1){
    pattern[pitch / 16][pitch % 16] = 0;
    myBus.sendNoteOn(channel, pitch, 0);     
  }
}