import processing.serial.*;
import ws2801.*;

//LeapMotionP5 leap;


static final int arrayWidth  = 2000, // Width of LED array
                 arrayHeight = 1, // Height of LED array
                 imgScale    = 2; // Size of displayed preview
PImage           img         = createImage(arrayWidth, arrayHeight, RGB);
Serial           port;
WS2801           myLEDs;
int[]            remap;

int[] LEDARRAY = new int[2000];

void setup() {

  //size(arrayWidth * imgScale, arrayHeight * imgScale, JAVA2D);
  colorMode(HSB);
  
  //leap = new LeapMotionP5(this);
  port = new Serial(this, Serial.list()[2], 115200);
  myLEDs = new WS2801(port, arrayWidth * arrayHeight);


  // Generate zigzag remap array to reconstitute image into LED order.
  remap = myLEDs.zigzag(arrayWidth, arrayHeight,
    WS2801.START_TOP | WS2801.START_LEFT | WS2801.ROW_MAJOR);
}

void draw() {  
	for(int i=0; i < 200; i++)
		LEDARRAY[int(random(arrayWidth*arrayHeight))] = 0xFFFFFF;
	myLEDs.refresh(LEDARRAY);
	//delay(100);
	
	for(int i=0; i<arrayWidth*arrayHeight; i++)
		LEDARRAY[i] = 0x000000;
	
	myLEDs.refresh(LEDARRAY);
	//delay(100);
  