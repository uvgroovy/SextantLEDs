//Sextant LED Controller
//Written by Matthew Brooks for Sextant Camp, Burning Man 2014
//www.sextantcamp.com
//For Teensy 3.x devices that use DMA on USB->SPI I/O transfers
//Takes LED (WS2801) RGB values over USB and parallel outputs them on four channels
//Each channel at full speed gets about 500 LEDs before skew takes over clk/data lines
//Makes blinky (or fade) when not fed food bytes...

#define PARTY_TYPE 0    //relax color wheel fade
//#define PARTY_TYPE 1  //sparkle party!

#include "FastSPI_LED2.h"

#define NUM_LEDS 500     //per channel	
#define LED 13			 //good for visual status

byte r, g, b;
uint16_t dummy;

CRGB leds[NUM_LEDS];
CRGB ledstwo[NUM_LEDS];
CRGB ledsthree[NUM_LEDS];
CRGB ledsfour[NUM_LEDS];

void setup() {
	pinMode(LED, OUTPUT);
    digitalWrite(LED, HIGH);   // set the LED on
    Serial.begin(115200); 
      
    FastLED.addLeds<WS2801, 12, 10, RGB, DATA_RATE_MHZ(3)>(leds, NUM_LEDS); //1
    FastLED.addLeds<WS2801, 16, 19, RGB, DATA_RATE_MHZ(3)>(ledstwo, NUM_LEDS);  //2
    FastLED.addLeds<WS2801, 8, 5, RGB, DATA_RATE_MHZ(3)>(ledsthree, NUM_LEDS);  //3
    FastLED.addLeds<WS2801, 3, 1, RGB, DATA_RATE_MHZ(3)>(ledsfour, NUM_LEDS); //4
      
    for(int wipe = 0; wipe <500; wipe++) {
		r = 0; g = 0xFF; b =0;
		leds[wipe] = 0x110000;       //2
		ledstwo[wipe] = 0x001100;    //3
		ledsthree[wipe] = 0x000011;  //4
		ledsfour[wipe] = 0x110011;   //1
		}
	FastLED.show();
}

void loop() {
	if(!checkForData())
		party_wheel(PARTY_TYPE);
	writeToLEDS();
	}

byte checkForData() {
/*
      Format of expected output from computer
      buffer[0] = 'A';    // Magic word
      buffer[1] = 'd';
      buffer[2] = 'a';
      buffer[3] = (byte)((1) >> 8);      // LED count high byte                                                                                                                                                                       
      buffer[4] = (byte)((1) & 0xff);    // LED count low byte                                                                                                                                                                        
      buffer[5] = (byte)(buffer[3] ^ buffer[4] ^ 0x55); // Checksum    
*/
	Serial.print("Ada\n"); // Send ACK string to host, compatible with older adavision hosts
		if ((dummy = Serial.read()) == 'A') {
			if((dummy = Serial.read()) == 'd') {
				if((dummy = Serial.read()) == 'a') {
					return 1;
				}
			}
		}
    return 0;  
	}


void writeToLEDS() {

	//dummy serial reads to take care of old apps that output LED count bytes (+checksum) first      
	while ((dummy = Serial.read()) == -1);
	while ((dummy = Serial.read()) == -1);
	while ((dummy = Serial.read()) == -1);
   
	for(int x = 0; x < NUM_LEDS; x++) {
		while ((r = Serial.read()) == -1);
		while ((g = Serial.read()) == -1);
		while ((b = Serial.read()) == -1);
		leds[x] = ((r << 16) & 0xFF0000) | ((g << 8) & 0x00FF00) | (b & 0x0000FF);
		}
	digitalWrite(LED, LOW);   // set the LED off
	for(int x = 0; x < NUM_LEDS; x++) {
		while ((r = Serial.read()) == -1);
		while ((g = Serial.read()) == -1);
		while ((b = Serial.read()) == -1);
		ledstwo[x] = ((r << 16) & 0xFF0000) | ((g << 8) & 0x00FF00) | (b & 0x0000FF); 
		}
	for(int x = 0; x < NUM_LEDS; x++) {
		while ((r = Serial.read()) == -1);
		while ((g = Serial.read()) == -1);
		while ((b = Serial.read()) == -1);
		ledsthree[x] = ((r << 16) & 0xFF0000) | ((g << 8) & 0x00FF00) | (b & 0x0000FF);
		}  
	for(int x = 0; x < NUM_LEDS; x++) {
		while ((r = Serial.read()) == -1);
		while ((g = Serial.read()) == -1);
		while ((b = Serial.read()) == -1);
		ledsfour[x] = ((r << 16) & 0xFF0000) | ((g << 8) & 0x00FF00) | (b & 0x0000FF);
		}
	digitalWrite(LED, HIGH);   // set the LED on
	FastLED.show();
	}


void party_wheel(uint8_t type) {
	//if type is 0, sparkle party!  if type is 1, relaxing fade
	digitalWrite(LED, HIGH);   // set the LED on
	int x, y, z;
	int i;
	byte j;
	int sparx_count = 50;
  
	if(type) {
		for (j=0; j < 300; j++)	{     // 3 cycles of all 256 colors in the wheel
			for(x = 0; x < sparx_count; x++){
				leds[random(NUM_LEDS)] = Wheel(j);
				ledstwo[random(NUM_LEDS)] = Wheel(j);
				ledsthree[random(NUM_LEDS)] = Wheel(j);
				ledsfour[random(NUM_LEDS)] = Wheel(j);
				}  
			FastLED.show();   
			for(x = 0; x< 500; x++)	{
				leds[x] = 0x000000;
				ledstwo[x] = 0x000000;
				ledsthree[x] = 0x000000;
				ledsfour[x] = 0x000000;
				}
			FastLED.show();  
			if(checkForData())
				return;
		}
	} 
    
     
	else	{  //if type is 1, relaxing fade
		for (j=0; j < 300; j++) {     // 3 cycles of all 256 colors in the wheel     
			for(x = 0; x < NUM_LEDS; x++){
				leds[x] =       Wheel(j);
				ledstwo[x] =    Wheel(j);
				ledsthree[x] =  Wheel(j);
				ledsfour[x] =   Wheel(j);
				} 
			FastLED.show();
			delay(10); 
			if(checkForData())
				return;
			}   
		}
	digitalWrite(LED, HIGH);   // set the LED on
	}  
 
 
uint32_t Wheel(byte WheelPos)  {
	if (WheelPos < 85)
		return Color(WheelPos * 3, 255 - WheelPos * 3, 0);
   
	else if (WheelPos < 170) {
		WheelPos -= 85;
		return Color(255 - WheelPos * 3, 0, WheelPos * 3);
		} 
	else {
		WheelPos -= 170; 
		return Color(0, WheelPos * 3, 255 - WheelPos * 3);
		}
	}

uint32_t Color(byte r, byte g, byte b)  {
	uint32_t c;
	c = r;
	c <<= 8;
	c |= g;
	c <<= 8;
	c |= b;
	return c;
	}
  
