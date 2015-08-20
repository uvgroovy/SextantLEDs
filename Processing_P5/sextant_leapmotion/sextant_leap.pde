import processing.serial.*;
import ws2801.*;
import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;

LeapMotionP5 leap;

static final int arrayWidth  = 1000, // Width of LED array
                 arrayHeight = 1, // Height of LED array
                 imgScale    = 2; // Size of displayed preview
PImage           img         = createImage(arrayWidth, arrayHeight, RGB);
Serial           port;
WS2801           myLEDs;
int[]            remap;

int[] LEDARRAY = new int[1000];

void setup() {

   //size(1000, 700, P3D);

  //leap = new LeapMotionP5(this);
  //fill(255);
  
  //size(arrayWidth * imgScale, arrayHeight * imgScale, JAVA2D);
  //colorMode(HSB);
  
  leap = new LeapMotionP5(this);
  println(Serial.list());
  port = new Serial(this, Serial.list()[4], 115200);
  myLEDs = new WS2801(port, arrayWidth * arrayHeight);


  // Generate zigzag remap array to reconstitute image into LED order.
  remap = myLEDs.zigzag(arrayWidth, arrayHeight,
    WS2801.START_TOP | WS2801.START_LEFT | WS2801.ROW_MAJOR);
}

float prevXmin = 0;
float prevYmin = 0;
float prevZmin = 0;
float prevXmax = 0;
float prevYmax = 0;
float prevZmax = 0;

void draw() {

 /* background(0);
  for (Finger f : leap.getFingerList()) {
    PVector screenPos = leap.getTipOnScreen(f);
    ellipse(screenPos.x, screenPos.y, 10, 10);
  }*/
  
  PVector ColorFingerPos = leap.getTip(leap.getFinger(0));
  
 
  // xmin: -1107.5898 ymin: -0.4010043 zmin: -3544.697
  //xmax: 2567.6943 ymax: 2.0 zmax: 3128.341

  int red =     int(map(int(ColorFingerPos.x), -200, 600, 0, 255));
  int green =   int(map(int(ColorFingerPos.y), -0.4010043, 2.0, 0, 255));
  int blue =    int(map(int(ColorFingerPos.z), -3544.67, 3128.341, 0, 255));
  
  
  PVector delayFingerPos = leap.getTip(leap.getFinger(4));
  int delay =   int(map(int(delayFingerPos.y), 20, 600, 0 , 300));
  //println("delayorig: " + delayFingerPos + "delay: " + delay);
  //println("red: " + red + " green: " + green + " blue: " + blue + " delay: " + delay);
  //println(fingerPos);
  println(int(leap.getVelocity(leap.getHand(0)).y));
  int speed = int(leap.getVelocity(leap.getHand(0)).y);
  
for(int i=0; i < 300; i++)
   {
   if(speed > 70)
     {
      for(int colz= 0;  colz < 1000; colz++)
        LEDARRAY[i] = 0xFF0000;
     delay = 200;
     break;
     }
   else
     LEDARRAY[int(random(arrayWidth*arrayHeight))] = ((byte)red << 16 & 0xFF0000) | ((byte)green << 8 & 0x00FF00) | ((byte)blue & 0x0000FF);
   }
   //myLEDs.setGamma(1.5);
  myLEDs.refresh(LEDARRAY);
  if(delay < 0)
    delay(0);
  else
    delay(delay);

 for(int i=0; i<arrayWidth*arrayHeight; i++)
   LEDARRAY[i] = 0x000000;
 myLEDs.refresh(LEDARRAY);
//delay(((int)fingerPos.y*100)/600 );
  
  
  
  //img.loadPixels();
  
  //int ranLED = int(random(arrayWidth*arrayHeight));
  //for(int i=0; i < 300; i++)
    //img.pixels[int(random(arrayWidth*arrayHeight))] = int(random(0xFFFFFF));
  
  //img.updatePixels();
 
//for(int i=0; i<arrayWidth*arrayHeight; i++)
 // img.pixels[i] = 0xFF0000;
//myLEDs.refresh();
//delay(100);


  // Preview LED data on computer display
  //image(img, 0, 0, width, height);

  // Issue pixel data to the Arduino
  myLEDs.refresh(LEDARRAY);
}


