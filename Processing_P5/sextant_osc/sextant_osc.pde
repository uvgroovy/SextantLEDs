//Sextant OSC LED control by Matthew Brooks


import processing.serial.*;
import ws2801.*;
import oscP5.*;
import netP5.*;

int NUM_LEDS =  2000;
OscP5 oscP5;
NetAddress myRemoteLocation;
int delay = 0;

byte red, green, blue;

Serial           port;
WS2801           myLEDs;
int[]            remap;

int[] LEDARRAY = new int[NUM_LEDS];
boolean go = true;


void setup() {
	println(Serial.list());
	port = new Serial(this, Serial.list()[0], 115200);
	myLEDs = new WS2801(port, NUM_LEDS);
	oscP5 = new OscP5(this,12000);
	myRemoteLocation = new NetAddress("127.0.0.1",12000);

	// Generate zigzag remap array to reconstitute image into LED order.
	//remap = myLEDs.zigzag(NUM_LEDS,
	// WS2801.START_TOP | WS2801.START_LEFT | WS2801.ROW_MAJOR);

	oscP5.plug(this,"redChan","/red");
	oscP5.plug(this,"greenChan","/green");
	oscP5.plug(this,"blueChan","/blue");
	oscP5.plug(this,"delayVal","/delay");
	oscP5.plug(this,"buttonstop","/button");
}


public void buttonstop()
  {
  println("button toggle!");
  go = !go;
  }



public void redChan(float hexval)
  {
  println(" 1 int received: "+ hexval);
  red = byte(hexval);
  println("red: " + hexval);
  }


  public void greenChan(float hexval)
  {
  println(" 1 int received: "+ hexval);
  green = byte(hexval);



  println("green: " + hexval);
  }


  public void blueChan(float hexval)
  {
  println(" 1 int received: "+ hexval);
  blue = byte(hexval);
  println("blue: " + hexval);
  }


  public void delayVal(float hexval)
  {
  println(" 1 int received: "+ hexval);
  delay = int(hexval);
  println("delay: " + hexval);
  }

void draw() {

	for(int i=0; i < NUM_LEDS; i++)
		LEDARRAY[i] = ((byte)red << 16 & 0xFF0000) | ((byte)green << 8 & 0x00FF00) | ((byte)blue & 0x0000FF);
	myLEDs.refresh(LEDARRAY);

	if(go)
		myLEDs.refresh(LEDARRAY);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can
   * be used for double posting but is not required.
  */
	if(theOscMessage.isPlugged()==false) {
		/* print the address pattern and the typetag of the received OscMessage */
		println("### received an osc message.");
		println("### addrpattern\t"+theOscMessage.addrPattern());
		println("### typetag\t"+theOscMessage.typetag());
		}
}
