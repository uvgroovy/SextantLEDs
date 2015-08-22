#include "FastSPI_LED2.h"

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#define PARTY_TYPE 0    //relax color wheel fade
//#define PARTY_TYPE 1  //sparkle party!


#define LEDS_PER_CHANNEL 500     //per channel  
#define NUM_CHANNELS 4
#define LED 13       //good for visual status

CRGB channel1[LEDS_PER_CHANNEL];
CRGB channel2[LEDS_PER_CHANNEL];
CRGB channel3[LEDS_PER_CHANNEL];
CRGB channel4[LEDS_PER_CHANNEL];

CRGB* channels[NUM_CHANNELS] {channel1, channel2, channel3, channel4};

inline CRGB color(byte r, byte g, byte b) {
  return  ((r << 16) & 0xFF0000) | ((g << 8) & 0x00FF00) | (b & 0x0000FF);
}

inline void colorSet(byte channel, int index, byte r, byte g, byte b) {
  colorSet(channel, index, color(r, g, b));
}

inline void colorSet(byte channel, int index, CRGB color) {
  channels[channel][index] = color;
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(115200);

  //                     DATA, CLOCK
  FastLED.addLeds<WS2801, 12, 10, RGB, DATA_RATE_MHZ(3)>(channel1, ARRAY_SIZE(channel1));
  FastLED.addLeds<WS2801, 16, 19, RGB, DATA_RATE_MHZ(3)>(channel2, ARRAY_SIZE(channel2));
  FastLED.addLeds<WS2801, 8 , 5 , RGB, DATA_RATE_MHZ(3)>(channel3, ARRAY_SIZE(channel3));
  FastLED.addLeds<WS2801, 3 , 1 , RGB, DATA_RATE_MHZ(3)>(channel4, ARRAY_SIZE(channel4));


  for (int i = 0; i < NUM_CHANNELS; i++) {
    for (int j = 0; j < LEDS_PER_CHANNEL; j++) {
      colorSet(i, j, 0, 0, 0);
    }
  }
  FastLED.show();
}


bool syncSerial() {
  while (Serial.available() >= 3) {
    int byteRead = Serial.read();
    if (byteRead != 'A') {
      continue;
    }
    byteRead = Serial.read();
    if (byteRead != 'd') {
      continue;
    }
    byteRead = Serial.read();
    if (byteRead != 'a') {
      continue;
    }
    
    Serial.print("Ada\n"); // Send ACK string to host, compatible with older adavision hosts
    return true;
  }
  return false;
}

void readMetaData() {
  //dummy serial reads to take care of old apps that output LED count bytes (+checksum) first

  for (int timeout = 0; (Serial.available() < 3) && (timeout < 10); ++timeout) {
    delay(10);
  }
  if (Serial.available() < 3)  {
    return;
  }

  Serial.read();
  Serial.read();
  Serial.read();
}

void readLedsFromSerial() {
  byte r, g, b;
  for (int i = 0; i < NUM_CHANNELS; i++) {
    for (int j = 0; j < LEDS_PER_CHANNEL; j++) {

      for (int timeout = 0; (Serial.available() < 3) && (timeout < 10); ++timeout) {
        delay(10);
      }
      if (Serial.available() < 3)  {
        return;
      }

      r = Serial.read();
      g = Serial.read();
      b = Serial.read();

      colorSet(i, j, r, g, b);

    }
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  if (syncSerial()) {
    readSerialAndShow();
  } else {
    party_wheel();
  }
}

void readSerialAndShow() {
    readMetaData();
    readLedsFromSerial();
    FastLED.show();
    
}

void party_wheel() {
  for (int i = 0; i < 256; i++) {   // 3 cycles of all 256 colors in the wheel
    if (Serial.available() >= 3) {
      return;
    }

    for (int j = 0; j < LEDS_PER_CHANNEL; j++) {
      for (int k = 0; k < NUM_CHANNELS; k++) {
        colorSet(k, j, wheel(i));
      }
    }


    FastLED.show();
    delay(10);

  }
}


CRGB wheel(byte WheelPos)  {
  if (WheelPos < 85)
    return color(WheelPos * 3, 255 - WheelPos * 3, 0);

  else if (WheelPos < 170) {
    WheelPos -= 85;
    return color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  else  {
    WheelPos -= 170;
    return color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}
