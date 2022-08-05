#include <OctoWS2811.h>
#include <FastLED.h>
#include <Arduino.h>

template <EOrder RGB_ORDER = RGB,
          uint8_t CHIP = WS2811_800kHz>
class CTeensy4Controller : public CPixelLEDController<RGB_ORDER, 8, 0xFF>
{
    OctoWS2811 *pocto;

public:
    CTeensy4Controller(OctoWS2811 *_pocto)
        : pocto(_pocto){};

    virtual void init() {}
    virtual void showPixels(PixelController<RGB_ORDER, 8, 0xFF> &pixels)
    {

        uint32_t i = 0;
        while (pixels.has(1))
        {
            uint8_t g = pixels.loadAndScale0();
            uint8_t r = pixels.loadAndScale1();
            uint8_t b = pixels.loadAndScale2();
            pocto->setPixel(i++, r, g, b);
            pixels.stepDithering();
            pixels.advanceData();
        }

        pocto->show();
    }
};


//#include <Arduino.h>
//#include <OctoWS2811.h>

#define FASTLED_INTERNAL
//#include <FastLED.h>

//#include "CTeensy4Controller.h"

const int numPins = 2;
byte pinList[numPins] = {4,5};

const int ledsPerStrip = 70;
CRGB leds[numPins * ledsPerStrip];

// These buffers need to be large enough for all the pixels.
// The total number of pixels is "ledsPerStrip * numPins".
// Each pixel needs 3 bytes, so multiply by 3.  An "int" is
// 4 bytes, so divide by 4.  The array is created using "int"
// so the compiler will align it to 32 bit memory.
DMAMEM int displayMemory[ledsPerStrip * numPins * 3 / 4];
int drawingMemory[ledsPerStrip * numPins * 3 / 4];

OctoWS2811 octo(ledsPerStrip, displayMemory, drawingMemory, WS2811_GRB | WS2811_800kHz, numPins, pinList);

CTeensy4Controller<GRB, WS2811_800kHz> *pcontroller;


int angle=0;
float timePerDegree = 10000000; //us

const int pixelWidth = 64;

//SENSOR CODE
const int sensorPin = A9;
//Flag prevents multiple triggers on same rotation
bool triggerFlag = false;
float rotationTimer = 0.0;


void setup()
{
  octo.begin();
  pcontroller = new CTeensy4Controller<GRB, WS2811_800kHz>(&octo);

  FastLED.setBrightness(50);
  FastLED.addLeds(pcontroller, leds, numPins * ledsPerStrip);
  
  // Make the hall pin an input
  pinMode(sensorPin, INPUT);
}

void loop(){

  float timeSinceRotation = micros() - rotationTimer; //us

  angle = timeSinceRotation / timePerDegree;

  
  //Display First Arm
  for(int x = 0; x<ledsPerStrip ;x++)
  {
    leds[x]= angle > 180 ? CRGB(0xFF0000) : CRGB(0x000000);
  }
  //Display Second Arm
  for(int x = 0; x<ledsPerStrip ;x++)
  {
    leds[x]= angle < 180 ? CRGB(0xFF0000) : CRGB(0x000000);
  }
  FastLED.show();

  float sensorValue = analogRead(sensorPin);
  if(sensorValue <= 200 && !triggerFlag){

    timePerDegree = (micros()-rotationTimer)/360;
    
    //set flags
    triggerFlag = true;
    rotationTimer=micros();
  }
  else if(sensorValue > 300 && triggerFlag){
    triggerFlag = false;
  }
}
