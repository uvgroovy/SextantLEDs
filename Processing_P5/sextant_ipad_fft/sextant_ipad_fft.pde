

import processing.serial.*;
import ws2801.*;
import oscP5.*;
import netP5.*;

import ddf.minim.analysis.*;
import ddf.minim.*;
import ws2801.*; 


int NUM_LEDS =  2000;
OscP5 oscP5;
NetAddress myRemoteLocation;
int delay = 0;


Serial           port;
WS2801           myLEDs;
int[]            remap;

int[] LEDARRAY = new int[NUM_LEDS];
boolean go = true;

//-----FFT stuff

Minim minim;
AudioInput in;
FFT fft;
float[] peaks;

int peak_hold_time = 1;  // how long before peak decays
int[] peak_age;  // tracks how long peak has been stable, before decaying

// how wide each 'peak' band is, in fft bins
int binsperband = 5;
int peaksize; // how many individual peak bands we have (dep. binsperband)
float gain = 40; // in dB
float dB_scale = 2.0;  // pixels per dB

int buffer_size = 1024;  // also sets FFT size (frequency resolution)
float sample_rate = 44100;

int spectrum_height = 176; // determines range of dB shown

int[] freq_array = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int i,g;
float f;
byte red = 0x0; byte green = 0x0; byte blue = 0x0;

float[] freq_height = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  //avg amplitude of each freq band


//----end of FFT stuff



byte redw1=2, redw2=3, redw3=4, redw4=5, redw5=6, redw6, redw7;
byte bluew1=2, bluew2=3, bluew3=10, bluew4=10, bluew5=10, bluew6=10, bluew7;
byte greenw1=10, greenw2=10, greenw3=10, greenw4=10, greenw5=15, greenw6, greenw7;

int blackSpark=0;

void setup() {
  println(Serial.list());
  port = new Serial(this, Serial.list()[2], 115200);
  myLEDs = new WS2801(port, NUM_LEDS);
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO,buffer_size,sample_rate);
 
  // create an FFT object that has a time-domain buffer 
  // the same size as line-in's sample buffer
  fft = new FFT(in.bufferSize(), in.sampleRate());
  // Tapered window important for log-domain display
  fft.window(FFT.HAMMING);

  // initialize peak-hold structures
  peaksize = 1+Math.round(fft.specSize()/binsperband);
  peaks = new float[peaksize];
  peak_age = new int[peaksize];
  
  
  
  oscP5.plug(this,"resetButton","/reset");
  oscP5.plug(this,"redw1","/redw1");
  oscP5.plug(this,"redw2","/redw2");
  oscP5.plug(this,"redw3","/redw3");
  oscP5.plug(this,"redw4","/redw4");
  oscP5.plug(this,"redw5","/redw5");
  oscP5.plug(this,"redw6","/redw6");
  oscP5.plug(this,"redw7","/redw7");
  oscP5.plug(this,"greenw1","/greenw1");
  oscP5.plug(this,"greenw2","/greenw2");
  oscP5.plug(this,"greenw3","/greenw3");
  oscP5.plug(this,"greenw4","/greenw4");
  oscP5.plug(this,"greenw5","/greenw5");
  oscP5.plug(this,"greenw6","/greenw6");
  oscP5.plug(this,"greenw7","/greenw7");
  oscP5.plug(this,"bluew1","/bluew1");
  oscP5.plug(this,"bluew2","/bluew2");
  oscP5.plug(this,"bluew3","/bluew3");
  oscP5.plug(this,"bluew4","/bluew4");
  oscP5.plug(this,"bluew5","/bluew5");
  oscP5.plug(this,"bluew6","/bluew6");
  oscP5.plug(this,"bluew7","/bluew7"); 
  oscP5.plug(this,"blackSparkle","/blacksparkle"); 

}


public void blackSparkle(float hexval)
  {
 blackSpark = (int)hexval;
  }
  
public void buttonstop()
  {
  println("button toggle!");  
  go = !go;
  }
  
  
  public void resetButton()
    {
    redw1=0; redw2=0; redw3=0; redw4=0; redw5=0; redw6=0; redw7=0;
    bluew1=0; bluew2=0; bluew3=0; bluew4=0; bluew5=0; bluew6=0; bluew7=0;
    greenw1=0; greenw2=0; greenw3=0; greenw4=0; greenw5=0; greenw6=0; greenw7=0; 
    println("RESETING ALL VALUES");
    }

public void redw1(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  redw1 = byte(hexval);
  println("redw1: " + hexval);
  }
  
  
  public void redw2(float hexval)
  {
  println(" 1 int received: "+ hexval);  
 redw2 = byte(hexval);

  println("redw2: " + hexval);
  }
  
  
  public void redw3(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  redw3 = byte(hexval);
  println("redw3: " + hexval);
  }
  
  
  public void redw4(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  redw4 = byte(hexval);
  println("redw4: " + hexval);
  }
  
  
  public void redw5(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  redw5 = byte(hexval);
  println("redw5: " + hexval);
  }
  
  
  public void redw6(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  redw6 = byte(hexval);
  println("redw6: " + hexval);
  }
  
  
  public void redw7(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  redw7 = byte(hexval);
  println("redw7: " + hexval);
  }
  
  
  public void greenw1(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  greenw1 = byte(hexval);
  println("redw1: " + hexval);
  }
  
  
  public void greenw2(float hexval)
  {
  println(" 1 int received: "+ hexval);  
 greenw2 = byte(hexval);

  println("redw2: " + hexval);
  }
  
  
  public void greenw3(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  greenw3 = byte(hexval);
  println("redw3: " + hexval);
  }
  
  
  public void greenw4(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  greenw4 = byte(hexval);
  println("redw4: " + hexval);
  }
  
  
  public void greenw5(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  greenw5 = byte(hexval);
  println("redw5: " + hexval);
  }
  
  
  public void greenw6(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  greenw6 = byte(hexval);
  println("redw6: " + hexval);
  }
  
  
  public void greenw7(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  greenw7 = byte(hexval);
  println("redw7: " + hexval);
  }
  
  
  public void bluew1(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew1 = byte(hexval);
  println("redw1: " + hexval);
  }
  
  
  public void bluew2(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew2 = byte(hexval);

  println("redw2: " + hexval);
  }
  
  
  public void bluew3(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew3 = byte(hexval);
  println("redw3: " + hexval);
  }
  
  
  public void bluew4(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew4 = byte(hexval);
  println("redw4: " + hexval);
  }
  
  
  public void bluew5(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew5 = byte(hexval);
  println("redw5: " + hexval);
  }
  
  
  public void bluew6(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew6 = byte(hexval);
  println("redw6: " + hexval);
  }
  
  
  public void bluew7(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  bluew7 = byte(hexval);
  println("redw7: " + hexval);
  }
  
  
  
  
  public void delayVal(float hexval)
  {
  println(" 1 int received: "+ hexval);  
  delay = int(hexval);
  println("delay: " + hexval);
  }
  
  



void draw() {

for(int k=0; k<16; k++){
freq_array[k] = 0;
}

  // perform a forward FFT on the samples in input buffer
  fft.forward(in.mix);
  
// Frequency Band Ranges      
  freq_height[0] = fft.calcAvg((float) 0, (float) 50);
  freq_height[1] = fft.calcAvg((float) 51, (float) 69);
  freq_height[2] = fft.calcAvg((float) 70, (float) 94);
  freq_height[3] = fft.calcAvg((float) 95, (float) 129);
  freq_height[4] = fft.calcAvg((float) 130, (float) 176);
  freq_height[5] = fft.calcAvg((float) 177, (float) 241);
  freq_height[6] = fft.calcAvg((float) 242, (float) 331);
  freq_height[7] = fft.calcAvg((float) 332, (float) 453);
  freq_height[8] = fft.calcAvg((float) 454, (float) 620);
  freq_height[9] = fft.calcAvg((float) 621, (float) 850);
  freq_height[10] = fft.calcAvg((float) 851, (float) 1241);
  freq_height[11] = fft.calcAvg((float) 1242, (float) 1600);
  freq_height[12] = fft.calcAvg((float) 1601, (float) 2200);
  freq_height[13] = fft.calcAvg((float) 2201, (float) 3000);
  freq_height[14] = fft.calcAvg((float) 3001, (float) 4100);
  freq_height[15] = fft.calcAvg((float) 4101, (float) 5600);
   

// Amplitude Ranges  if else tree
  for(int j=0; j<16; j++){    
    if (freq_height[j] < 200000 && freq_height[j] > 200){freq_array[j] = 16;}
    else{ if (freq_height[j] <= 300 && freq_height[j] > 150){freq_array[j] = 15;}
    else{ if (freq_height[j] <= 250 && freq_height[j] > 125){freq_array[j] = 14;}
    else{ if (freq_height[j] <= 200 && freq_height[j] > 100){freq_array[j] = 13;}
    else{ if (freq_height[j] <= 160 && freq_height[j] > 90){freq_array[j] = 12;}
    else{ if (freq_height[j] <= 150 && freq_height[j] > 75){freq_array[j] = 11;}
    else{ if (freq_height[j] <= 140 && freq_height[j] > 65){freq_array[j] = 10;}
    else{ if (freq_height[j] <= 120 && freq_height[j] > 50){freq_array[j] = 9;}
    else{ if (freq_height[j] <= 50 && freq_height[j] > 45){freq_array[j] = 8;}
    else{ if (freq_height[j] <= 45 && freq_height[j] > 40){freq_array[j] = 7;}
    else{ if (freq_height[j] <= 40 && freq_height[j] > 35){freq_array[j] = 6;}
    else{ if (freq_height[j] <= 35 && freq_height[j] > 30){freq_array[j] = 5;}
    else{ if (freq_height[j] <= 30 && freq_height[j] > 15){freq_array[j] = 4;}
    else{ if (freq_height[j] <= 15 && freq_height[j] > 10){freq_array[j] = 3;}
    else{ if (freq_height[j] <= 10 && freq_height[j] > 5){freq_array[j] = 2;}
    else{ if (freq_height[j] <= 5 && freq_height[j] >= 1 ){freq_array[j] = 1;}
    else{ if (freq_height[j] < 1 ){freq_array[j] = 0;}
  }}}}}}}}}}}}}}}}}

  //send to serial
  //port.write(0xff); //write marker (0xff) for synchronization
  
    //for(i=0; i<16; i++){
    //port.write((byte)(freq_array[i]));
    //print((byte)(freq_array[i]));
    
    red = (byte)(red - 5);  if(red<0) red = 0;
    green = (byte)(green - 100);  if(green<0) green = 0;
    blue = (byte)(blue - 100);  if(blue<0) blue = 0;
    
    red += (  ((byte)(freq_array[0])*redw1) + ((byte)(freq_array[1])*redw2) + ((byte)(freq_array[3])*redw3) + ((byte)(freq_array[4])*redw4) + ((byte)(freq_array[5])*redw5)       );
  green += (  ((byte)(freq_array[6])*bluew1) + ((byte)(freq_array[7])*bluew3) + ((byte)(freq_array[8])*bluew4) + ((byte)(freq_array[9])*bluew5) + ((byte)(freq_array[10])*bluew6)      );
   blue += (  ((byte)(freq_array[11])*greenw1) + ((byte)(freq_array[12])*greenw2) + ((byte)(freq_array[13])*greenw3) + ((byte)(freq_array[14])*greenw4) + ((byte)(freq_array[15])*greenw5)  );
     
     if(red<0) red = 0; if(green<0) green = 0; if(blue<0) blue = 0;
     
   //println(red + " " + green + " " + blue);
      
    
    
    
    for(int i=0; i < NUM_LEDS; i++){
      LEDARRAY[i] = ((byte)red << 16 & 0xFF0000) | ((byte)green  << 8 & 0x00FF00) | ((byte)blue & 0x0000FF);
      }
      
      for(i=0; i < blackSpark; i++)
          {
          LEDARRAY[(int)random(NUM_LEDS)] = ((byte)red << 16 & 0x000000) | ((byte)green  << 8 & 0x000000) | ((byte)blue & 0x000000);
          }  
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

