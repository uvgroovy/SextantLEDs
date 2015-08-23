#include "FastSPI_LED2.h"

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#define PARTY_TYPE 0    //relax color wheel fade
// #define PARTY_TYPE 1  //sparkle party!


#define LEDS_PER_CHANNEL 500     //per channel  
#define NUM_CHANNELS 4
#define LED 13       //good for visual status

#define NUMLETTERS 7 // SEXTANT

CRGB channel1[LEDS_PER_CHANNEL];
CRGB channel2[LEDS_PER_CHANNEL];
CRGB channel3[LEDS_PER_CHANNEL];
CRGB channel4[LEDS_PER_CHANNEL];

CRGB* channels[NUM_CHANNELS] {channel1, channel2, channel3, channel4};

// letter ranges
// start and end index for each letter
int letterRanges[NUMLETTERS][2] = {
  {0, 1},
  {1, 2},
  {2, 3},
  {3, 4},
  {4, 5},
  {5, 6},
  {6, 7},
};

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



void animation1() {
  for (int j = 0 ; j < 256; ++j) {
    for (int i = 0; i < NUMLETTERS; i ++) {
      letterWipe(i, wheel(j));
    }
    FastLED.show();
    delay(10);
  }
}

void animation2() {

  for (int i = 0; i < NUMLETTERS; i ++) {
    letterWipe(i, 0);
  }
  FastLED.show();

  for (int i = 0; i < NUMLETTERS; i ++) {
    if (i > 0) {
      letterWipe(i - 1, 0);

    }
    letterWipe(i, wheel(i * 20));
    FastLED.show();
    delay(500);
  }

}


void animation3() {

  for (int j = 0 ; j < 256; ++j) {
    for (int i = 0; i < NUMLETTERS; i ++) {
      letterWipe(i, wheel(j + i * 20));
    }
    FastLED.show();
    delay(10);
  }
}


void animation4() {
  const CRGB initialColor = color(255, 0, 0);
  const int steps = 100;
  const int deltaTime = 10;
  for (int i = 0; i < NUMLETTERS; i ++) {
    letterWipe(i, 0);
  }
  letterWipe(0, initialColor);

  FastLED.show();

  for (int i = 1; i < NUMLETTERS; i ++) {
    for (int j = 0; j <= steps; ++j) {
      float r = j * 1.0 / steps;
      const CRGB firstColor = color(255 * (1 - r), 0, 0);
      const CRGB secondColor = color(255 * r, 0, 0);

      letterWipe(i - 1, firstColor);
      letterWipe(i, secondColor);
      FastLED.show();
      delay(deltaTime);
    }
  }

}


typedef void (*Animation)();
Animation animations[] = {animation1, animation2, animation3, animation4};

//Animation animations[] = { animation4};
void loop() {

  animations[random(ARRAY_SIZE(animations))]();
}

void letterWipe(int letter, CRGB color) {

  for (int i = letterRanges[letter][0]; i < letterRanges[letter][1]; ++i) {
    colorSet(i / LEDS_PER_CHANNEL, i % LEDS_PER_CHANNEL, color);
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
