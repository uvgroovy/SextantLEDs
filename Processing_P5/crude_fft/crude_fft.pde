/**
  * Live Spectrum to Arduino
  *
  * Run an FFT on live line-in input, splits into 16 frequency bands, and send this data to an Arduino in 16 byte packets.
  * Based on http://processing.org/learning/libraries/forwardfft.html by ddf.
  */
 
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*; //library for serial communication
import ws2801.*; 
 
Serial port; //creates object "port" of serial class
 
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


int NUM_LEDS =  2000;
WS2801 myLEDs;
int[] LEDARRAY = new int[NUM_LEDS];
byte red = 0x0; byte green = 0x0; byte blue = 0x0;

float[] freq_height = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  //avg amplitude of each freq band

void setup()
{
  size(400, 400);

  minim = new Minim(this);
  println(Serial.list());
  port = new Serial(this, Serial.list()[0],115200); //set baud rate
 
  myLEDs = new WS2801(port, NUM_LEDS); //<>//
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
}


void draw()
{
  
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
    
    red += (  ((byte)(freq_array[0])*2) + ((byte)(freq_array[1])*3) + ((byte)(freq_array[3])*4) + ((byte)(freq_array[4])*5) + ((byte)(freq_array[5])*6)       );
  green += (  ((byte)(freq_array[6])*2) + ((byte)(freq_array[7])*3) + ((byte)(freq_array[8])*10) + ((byte)(freq_array[9])*10) + ((byte)(freq_array[10])*10)      );
   blue += (  ((byte)(freq_array[11])*10) + ((byte)(freq_array[12])*10) + ((byte)(freq_array[13])*10) + ((byte)(freq_array[14])*10) + ((byte)(freq_array[15])*10)  );
     
     if(red<0) red = 0; if(green<0) green = 0; if(blue<0) blue = 0;
     
   println(red + " " + green + " " + blue);
      
    
    background(red,green,blue);
    
    for(int i=0; i < NUM_LEDS; i++){
    //  LEDARRAY[i] = ((byte)red << 16 & 0xFF0000) | ((byte)green  << 8 & 0x00FF00) | ((byte)blue & 0x0000FF);
    switch(i%3) {
     case 0:
       LEDARRAY[i] = ((byte)red << 16 & 0xFF0000);
       break;
     case 1:
       LEDARRAY[i] = ((byte)green  << 8 & 0x00FF00);
       break;
     case 2:
       LEDARRAY[i] = ((byte)blue & 0x0000FF);
       break;
    }
    
      }
      println("re-");
    myLEDs.refresh(LEDARRAY);  
  
      println("-fresh");
  //print("\n");
  //delay(2); //delay for safety
}
 
 
void stop()
{
  // always close Minim audio classes when you finish with them
  in.close();
  minim.stop();
 
  super.stop();
}