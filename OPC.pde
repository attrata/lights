/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */

import java.net.*;
import java.util.Arrays;

public class OPC implements Runnable
{
  Thread thread;
  Socket socket;
  OutputStream output, pending;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  int ledX;
  int ledY;

  int ledCount;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    thread = new Thread(this);
    thread.start();
    this.enableShowLocations = true;
    parent.registerMethod("draw", this);
    ledX = 400;
    ledY = 400;
    this.ledCount = 0;
  }

  // Set the location of a single LED
  void led(int index, int x, int y)
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }

  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0) * spacing * c + 0.5),
        (int)(y + (i - (count-1)/2.0) * spacing * s + 0.5));
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  void ledRing(int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(index + i, (int)(x - radius * cos(a) + 0.5),
        (int)(y - radius * sin(a) + 0.5));
    }
  }

  void ledJewel(int index, float x, float y, float angle)
  {
    led(index, int(x), int(y));
    ledRing(index+1,6,x,y,7/2,angle);
  }

  int rotateX(int X, int Y, float angle)
  {
    return int(X*(cos(angle)) - Y*(sin(angle)));
  }

  int rotateY(int X, int Y, float angle)
  {
    return int(Y*(cos(angle)) + X*(sin(angle)));
  }

  void bigTriangle(float angle)
  {
    int centerX = rotateX(0,35,angle);
    int centerY = rotateY(0,35,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
  }

  void smallTriangle(float angle)
  {
    float centerX = rotateX(0,24,angle);
    float centerY = rotateY(0,24,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large
    ledCount += 16;
    centerX = rotateX(10,41,angle);
    centerY = rotateY(10,41,angle);
    ledRing(ledCount,12, ledX + centerX,ledY + centerY,15.0 / 2, 0.0); // medium
    ledCount += 12;
    centerX = rotateX(-12,41,angle);
    centerY = rotateY(-12,41,angle);
    //void ledJewel(int index, float x, float y, float angle)
    ledJewel(ledCount, ledX + centerX,ledY + centerY,0); // jewel
    ledCount += 7;
  }

  void smallTrapezoidR(float angle)
  {
    float centerX = rotateX(-22,65,angle);
    float centerY = rotateY(-22,65,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large
    ledCount += 16;
    centerX = rotateX(-10,81,angle);
    centerY = rotateY(-10,81,angle);
    ledRing(ledCount,12, ledX + centerX,ledY + centerY,15.0 / 2, 0.0); // medium
    ledCount += 12;
    centerX = rotateX(-32,81,angle);
    centerY = rotateY(-32,81,angle);
    //void ledJewel(int index, float x, float y, float angle)
    ledJewel(ledCount, ledX + centerX,ledY + centerY,0); // jewel
    ledCount += 7;
  }

  void smallTrapezoidL(float angle)
  {
    float centerX = rotateX(22,65,angle);
    float centerY = rotateY(22,65,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large
    ledCount += 16;
    centerX = rotateX(10,81,angle);
    centerY = rotateY(10,81,angle);
    ledRing(ledCount,12, ledX + centerX,ledY + centerY,15.0 / 2, 0.0); // medium
    ledCount += 12;
    centerX = rotateX(32,81,angle);
    centerY = rotateY(32,81,angle);
    //void ledJewel(int index, float x, float y, float angle)
    ledJewel(ledCount, ledX + centerX,ledY + centerY,0); // jewel
    ledCount += 7;
  }


  void bigTrapezoidR(float angle)
  {
    int centerX = rotateX(-18,65,angle);
    int centerY = rotateY(-18,65,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
  }

  void bigTrapezoidL(float angle)
  {
    int centerX = rotateX(18,65,angle);
    int centerY = rotateY(18,65,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
  }

  void bigOuter2L(float angle)
  {
    int centerX = rotateX(18,110,angle);
    int centerY = rotateY(18,110,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
    centerX = rotateX(45,120,angle);
    centerY = rotateY(45,120,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large
    ledCount += 16;
  }

  void bigOuter2R(float angle)
  {
    int centerX = rotateX(-18,110,angle);
    int centerY = rotateY(-18,110,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
    centerX = rotateX(-45,120,angle);
    centerY = rotateY(-45,120,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large 
    ledCount += 16;
  }

  void bigOuter4L(float angle)
  {
    int centerX = rotateX(45,125,angle);
    int centerY = rotateY(45,125,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
    centerX = rotateX(18,110,angle);
    centerY = rotateY(18,110,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large
    ledCount += 16;
    centerX = rotateX(45,100,angle);
    centerY = rotateY(45,100,angle);
    ledRing(ledCount,12, ledX + centerX,ledY + centerY,15.0 / 2, 0.0); // medium
    ledCount += 12;    
    centerX = rotateX(15,130,angle);
    centerY = rotateY(15,130,angle);
    ledJewel(ledCount, ledX + centerX,ledY + centerY,0); // jewel
    ledCount += 7;
  }

  void bigOuter4R(float angle)
  {
    int centerX = rotateX(-45,125,angle);
    int centerY = rotateY(-45,125,angle);
    ledRing(ledCount,24, ledX + centerX, ledY + centerY,25.0 / 2, 0.0); // X-large
    ledCount += 24;
    centerX = rotateX(-18,110,angle);
    centerY = rotateY(-18,110,angle);
    ledRing(ledCount,16, ledX + centerX,ledY + centerY,18.0 / 2, 0.0); // large
    ledCount += 16;
    centerX = rotateX(-45,100,angle);
    centerY = rotateY(-45,100,angle);
    ledRing(ledCount,12, ledX + centerX,ledY + centerY,15.0 / 2, 0.0); // medium
    ledCount += 12;    
    centerX = rotateX(-15,130,angle);
    centerY = rotateY(-15,130,angle);
    ledJewel(ledCount, ledX + centerX,ledY + centerY,0); // jewel
    ledCount += 7;
  }
  
  void benchLInner(float angle)
  {
    int centerX = rotateX(12,180,angle);
    int centerY = rotateY(12,180,angle);
    
    // void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
    ledStrip(ledCount, 64, ledX + centerX,ledY + centerY, 1, PI/2 + angle, false);
    ledCount += 64;
  }

  void benchRInner(float angle)
  {
    int centerX = rotateX(-12,180,angle);
    int centerY = rotateY(-12,180,angle);
    
    // void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
    ledStrip(ledCount, 64, ledX + centerX,ledY + centerY, 1, PI/2 + angle, false);
    ledCount += 64;
  }
  
  void benchLOuter(float angle)
  {
    int centerX = rotateX(12,240,angle);
    int centerY = rotateY(12,240,angle);
    ledStrip(ledCount, 64, ledX + centerX,ledY + centerY, 1, PI/2 + angle, false);
    ledCount += 64;
  }

  void benchROuter(float angle)
  {
    int centerX = rotateX(-12,240,angle);
    int centerY = rotateY(-12,240,angle);
    ledStrip(ledCount, 64, ledX + centerX,ledY + centerY, 1, PI/2 + angle, false);
    ledCount += 64;
  }
  
  void cocoon(float angle)
  {
    int centerX = rotateX(0,280,angle);
    int centerY = rotateY(0,280,angle);
    ledStrip(ledCount, 32, ledX + centerX,ledY + centerY, 1, PI/2 + angle, false);
    ledCount += 32;
  }
  
  
  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        x + (i - (numStrips-1)/2.0) * stripSpacing * c,
        y + (i - (numStrips-1)/2.0) * stripSpacing * s, ledSpacing,
        angle, zigzag && (i % 2) == 1);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  void sendFirmwareConfigPacket()
  {
    if (pending == null) {
      // We'll do this when we reconnect
      return;
    }
 
    byte[] packet = new byte[9];
    packet[0] = (byte)0x00; // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = (byte)0x00; // Length high byte
    packet[3] = (byte)0x05; // Length low byte
    packet[4] = (byte)0x00; // System ID high byte
    packet[5] = (byte)0x01; // System ID low byte
    packet[6] = (byte)0x00; // Command ID high byte
    packet[7] = (byte)0x02; // Command ID low byte
    packet[8] = (byte)firmwareConfig;

    try {
      pending.write(packet);
    } catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (pending == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = (byte)0x00;               // Channel (reserved)
    header[1] = (byte)0xFF;               // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);   // Length high byte
    header[3] = (byte)(packetLen & 0xFF); // Length low byte
    header[4] = (byte)0x00;               // System ID high byte
    header[5] = (byte)0x01;               // System ID low byte
    header[6] = (byte)0x00;               // Command ID high byte
    header[7] = (byte)0x01;               // Command ID low byte

    try {
      pending.write(header);
      pending.write(content);
    } catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = (byte)0x00;              // Channel
      packetData[1] = (byte)0x00;              // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);   // Length high byte
      packetData[3] = (byte)(numBytes & 0xFF); // Length low byte
    }
  }
  
  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  void setPixel(int number, color c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }
  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  color getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } catch (Exception e) {
      dispose();
    }
  }

  void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = pending = null;
  }

  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for(;;) {

      if(output == null) { // No OPC connection?
        try {              // Make one!
          socket = new Socket(host, port);
          socket.setTcpNoDelay(true);
          pending = socket.getOutputStream(); // Avoid race condition...
          println("Connected to OPC server");
          sendColorCorrectionPacket();        // These write to 'pending'
          sendFirmwareConfigPacket();         // rather than 'output' before
          output = pending;                   // rest of code given access.
          // pending not set null, more config packets are OK!
        } catch (ConnectException e) {
          dispose();
        } catch (IOException e) {
          dispose();
        }
      }

      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(500);
      }
      catch(InterruptedException e) {
      }
    }
  }
}