#include "FastSPI_LED2.h"

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#define LEDS_PER_CHANNEL 500     //per channel  
#define NUM_CHANNELS 4
#define LED 13       //good for visual status

#define NUMLETTERS 7 // SEXTANT

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


const CRGB RED    = color(255,   0,   0);
const CRGB ORANGE = color(255, 112,  44);
const CRGB YELLOW = color(255, 237,  27);
const CRGB GREEN  = color(177,  78,   0);
const CRGB LBLUE  = color(  0, 166, 228);
const CRGB BLUE   = color( 51,  79, 202);
const CRGB PURPLE = color(177,  72, 162);


uint8_t gammaFilter[256] = {0};

void setGamma(double gamma) {
  const int minGammaValue = 0;
  const int maxGammaValue = 255;
  const int range = maxGammaValue - minGammaValue;
  for (int i = 0; i < 256; i ++) {
    float d = (float)i / 255.0;
    gammaFilter[i] = (byte)( minGammaValue + (int)(range * pow(d, gamma) + 0.5));
  }
}

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


void setup() {
  pinMode(LED, OUTPUT);

  //                     DATA, CLOCK
  FastLED.addLeds<WS2801, 12, 10, RGB, DATA_RATE_MHZ(3)>(channel1, ARRAY_SIZE(channel1));
  FastLED.addLeds<WS2801, 16, 19, RGB, DATA_RATE_MHZ(3)>(channel2, ARRAY_SIZE(channel2));
  FastLED.addLeds<WS2801, 8 , 5 , RGB, DATA_RATE_MHZ(3)>(channel3, ARRAY_SIZE(channel3));
  FastLED.addLeds<WS2801, 3 , 1 , RGB, DATA_RATE_MHZ(3)>(channel4, ARRAY_SIZE(channel4));

  setGamma(2.5);
  ;
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


void flowingRed() {
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
      uint8_t c1 = gammaFilter[int(255 * (1 - r))];
      uint8_t c2 = gammaFilter[int(255 * r)];

      const CRGB firstColor = color(c1, 0, 0);
      const CRGB secondColor = color(c2 * r, 0, 0);

      letterWipe(i - 1, firstColor);
      letterWipe(i, secondColor);
      FastLED.show();
      delay(deltaTime);
    }
  }

}

void blinkLetter(int letter, int times, int delayTimeOn = 150, int delayTimeOff = -1,  CRGB color = 0) {
  color = (color != CRGB(0)) ? color : getLetterColor(letter);

  delayTimeOff = (delayTimeOff < 0) ? delayTimeOn : delayTimeOff;

  for (int i = 0; i < times; ++i) {
    letterWipe(letter, color);
    FastLED.show();
    delay(delayTimeOn);

    letterWipe(letter, 0);
    FastLED.show();
    delay(delayTimeOff);
  }
}

void brokenNeonSign() {

}

// shal tiri
void conversation() {

  // hi
  blinkLetter(6, 3);
  delay(200);
  // hello
  blinkLetter(0, 4);
  delay(200);
  // whats' up?
  blinkLetter(6, 2);
  delay(200);
  // Doing well how are you?
  blinkLetter(0, 6);
  delay(200);
  // good!
  blinkLetter(6, 1);
  delay(100);
  // lets party!
  blinkLetter(6, 3);
  // ok!
  blinkLetter(0, 2);

  // everyone parties
  for (int i = 0; i < 100; i++) {
    for (int j = 0; j < NUMLETTERS; j++) {
      bool letterOn = random(NUMLETTERS) % 2;
      CRGB color = letterOn ? getLetterColor(j) : CRGB(0);
      letterWipe(j, color);
    }
    FastLED.show();
    delay(100);
  }

}

///////////////////////////////////////////////////////////////////////////////////////////////// morse
void talk(int letter, const char* words) {

  for (int i = 0; words[i] != '\0'; ++i) {
    letter_morse(letter, words[i]);
  }

}

#define DOT_TIME 100
#define DASH_TIME (3*DOT_TIME)
#define INNER_GAP (DOT_TIME)
#define SHORT_GAP (3*DOT_TIME)
#define LONG_GAP (7*DOT_TIME)

const char* morsecodes[] = {
  ".-", //a
  "-...", //b
  "-.-.", //c
  "-..", //d
  ".", //e
  "..-.", //f
  "--.", //g
  "...", //h
  "..", //i
  ".---", //j
  "-.-", //k
  ".-..", //l
  "--", //m
  "-.", //n
  "---", //o
  ".--.", //p
  "--.-", //q
  ".-.", //r
  "...", //s
  "-", //t
  "..-", //u
  "...-", //v
  ".--", //w
  "-..-", //x
  "-.--", //y
  "--..", //z
};

void letter_morse(int letter, char ch) {
  ch = tolower(ch);
  int codeIndex = ch - 'a';

  if (ch == ' ') {
    delay(LONG_GAP);
    return;
  }

  if ((codeIndex >= 0) && (codeIndex <= 26) ) {
    const char* letterMorseCode = morsecodes[codeIndex];
    for (int i = 0; letterMorseCode[i] != '\0'; ++i) {
      if (letterMorseCode[i] == '.' ) {
        blinkLetter(letter, 1, DOT_TIME, INNER_GAP);
      } else {
        blinkLetter(letter, 1, DASH_TIME, INNER_GAP);
      }
    }

  } else {
    delay(SHORT_GAP);
  }


}

// tal shiri
void conversationMorse() {
  for (int j = 0; j < NUMLETTERS; j++) {
    letterWipe(j, 0);
  }
  FastLED.show();

  talk(6, "hi ");
  talk(0, "hi ");
  talk(0, "lets party");
  talk(0, "ok");

  // everyone parties
  for (int i = 0; i < 100; i++) {
    for (int j = 0; j < NUMLETTERS; j++) {
      bool letterOn = random(NUMLETTERS) % 2;
      CRGB color = letterOn ? getLetterColor(j) : CRGB(0);
      letterWipe(j, color);
    }
    FastLED.show();
    delay(100);
  }

}

////////////////////////////////////////////////////////////////////// end morse


//////////////////////// colors match sextant fb page
CRGB getLetterColor(int letter) {
  switch (letter) {
    case 0:
      return RED;
    case 1:
      return ORANGE;
    case 2:
      return YELLOW;
    case 3:
      return GREEN;
    case 4:
      return LBLUE;
    case 5:
      return BLUE;
    case 6:
      return PURPLE;
  }
  return 0;
}


typedef void (*Animation)();
//Animation animations[] = {animation1, animation2, animation3, flowingRed, conversationMorse};
Animation animations[] = { flowingRed};

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
