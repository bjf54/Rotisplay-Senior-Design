#include <OctoWS2811.h>
#include <FastLED.h>
#include <Arduino.h>

#include "ImageDefinitions.h"

//#define FASTLED_ALLOW_INTERRUPTS 0

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

int offset=280;
int imageIndex = 0;

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

const int pixelWidth = 70;

//SENSOR CODE
const int sensorPin = A9;
//Flag prevents multiple triggers on same rotation
bool triggerFlag = false;
float rotationTimer = 0.0;


////////////////////////design a pattern of display the number and alphabates//////////////////////////////// 

int NUMBER9[]={1,1,1,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,1,1,1,1,1,1,1};
 int NUMBER8[]={0,1,1,0,1,1,1,0, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 0,1,1,0,1,1,1,0};
 int NUMBER7[]={1,0,0,0,0,0,0,0, 1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0, 1,0,0,1,1,1,1,1, 1,1,1,0,1,0,0,0};
 int NUMBER6[]={1,1,1,1,1,1,1,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,1,1,1};
 int NUMBER5[]={1,1,1,1,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,1,1,1};
 int NUMBER4[]= {1,0,0,0,0,0,1,1, 1,0,0,0,0,1,0,1, 1,0,0,0,1,0,0,1, 1,0,0,1,0,0,0,1, 0,1,1,0,0,0,0,1}; //FIX CHARACTER
 int NUMBER3[]={1,1,1,1,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,1,1,1};   //FIX CHARACTER
 int NUMBER2[]= {1,0,0,0,0,0,1,1, 1,0,0,0,0,1,0,1, 1,0,0,0,1,0,0,1, 1,0,0,1,0,0,0,1, 0,1,1,0,0,0,0,1};
 int NUMBER1[]= {0,0,1,0,0,0,0,0, 0,1,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0};
 int NUMBER0[]= {1,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 1,1,1,1,1,1,1,1};

 int _[] = {0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0};
 int A[] = {1,1,1,1,1,1,1,1, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0, 1,1,1,1,1,1,1,1};
 int B[] = {1,1,1,1,1,1,1,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 0,1,1,0,1,1,1,0};
 int C[] = {0,0,1,1,1,1,0,0, 0,1,0,0,0,0,1,0, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1};
 int D[] = {1,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 0,1,0,0,0,0,1,0, 0,0,1,1,1,1,0,0};
 int E[] = {1,1,1,1,1,1,1,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1, 1,0,0,1,0,0,0,1};
 int F[] = {1,1,1,1,1,1,1,1, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0};
 int G[] = {0,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,1,1,0};
 int H[] = {1,1,1,1,1,1,1,1, 0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0, 1,1,1,1,1,1,1,1};
 int I[] = {1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 1,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1};
 int J[] = {0,0,0,0,0,1,1,0, 0,0,0,0,1,0,0,1, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1, 1,1,1,1,1,1,1,0};
 int K[] = {1,1,1,1,1,1,1,1, 0,0,0,1,1,0,0,0, 0,0,1,0,0,1,0,0, 0,1,0,0,0,0,1,0, 1,0,0,0,0,0,0,1};
 int L[] = {1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1};
 int M[] = {1,1,1,1,1,1,1,1, 0,1,0,0,0,0,0,0, 0,0,1,0,0,0,0,0, 0,1,0,0,0,0,0,0, 1,1,1,1,1,1,1,1};
 int N[] = {1,1,1,1,1,1,1,1, 0,0,1,0,0,0,0,0, 0,0,0,1,1,0,0,0, 0,0,0,0,0,1,0,0, 1,1,1,1,1,1,1,1};
 int O[] = {0,1,1,1,1,1,1,0, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 1,0,0,0,0,0,0,1, 0,1,1,1,1,1,1,0};
 int P[] = {1,1,1,1,1,1,1,1, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0, 1,0,0,1,0,0,0,0, 0,1,1,0,0,0,0,0};
 int Q[] = {0,1,1,1,1,1,1,0, 1,0,0,0,0,0,0,1, 1,0,0,0,0,1,0,1, 0,1,1,1,1,1,1,0, 0,0,0,0,0,0,0,1};
 int R[] = {1,1,1,1,1,1,1,1, 1,0,0,1,1,0,0,0, 1,0,0,1,0,1,0,0, 1,0,0,1,0,0,1,0, 0,1,1,0,0,0,0,1};
 int S[] = {0,1,1,1,0,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,0,0,1, 1,0,0,0,1,1,1,0};
 int T[] = {1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0};
 int U[] = {1,1,1,1,1,1,1,0, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1, 1,1,1,1,1,1,1,0};
 int V[] = {1,1,1,1,1,1,0,0, 0,0,0,0,0,0,1,0, 0,0,0,0,0,0,0,1, 0,0,0,0,0,0,1,0, 1,1,1,1,1,1,0,0};
 int W[] = {1,1,1,1,1,1,1,1, 0,0,0,0,0,0,1,0, 0,0,0,0,0,1,0,0, 0,0,0,0,0,0,1,0, 1,1,1,1,1,1,1,1};
 int X[] = {1,1,0,0,0,0,1,1, 0,0,1,0,0,1,0,0, 0,0,0,1,1,0,0,0, 0,0,1,0,0,1,0,0, 1,1,0,0,0,0,1,1};
 int Y[] = {1,1,0,0,0,0,0,0, 0,0,1,0,0,0,0,0, 0,0,0,1,1,1,1,1, 0,0,1,0,0,0,0,0, 1,1,0,0,0,0,0,0};
 int Z[] = {1,0,0,0,0,1,1,1, 1,0,0,0,1,0,0,1, 1,0,0,1,0,0,0,1, 1,0,1,0,0,0,0,1, 1,1,0,0,0,0,0,1};
 
 int* charPixels[]= {_,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,NUMBER1,NUMBER2,NUMBER3,NUMBER4,NUMBER5,NUMBER6,NUMBER7,NUMBER8,NUMBER9,NUMBER0};
 const char charConversion[] = {
  '_','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9','0'
 };
 
 const int widthMultiplier = 30;
 const int heightMultiplier = 5;
 const int charWidth = 5*widthMultiplier;
 int textColor = 0xFF0000;
 int text[50];

 void textToInt(String textString){
  for(int i=0;i<49;i++){
    text[i]=0;
  }
  for(int i=0;i<textString.length();i++){
    for(int x=0;x<37;x++){
      if(textString[i]==charConversion[x]){
        text[i]=x;
        break;
      }
    }
  }
 }



 void buildText(String textString){
  textToInt(textString);

  for(int a=0; a<360;a++){
    //reset column
    for(int i=0;i<pixelWidth;i++){
      rawHex[0][a*pixelWidth+i]=0x0F0F0F;
    }
    //get index of character within string
    int charIndex = a/charWidth;
    //sub index within character
    int subindex = a%charWidth;

    for(int i=0;i<8*heightMultiplier;i++){
      //loop from edge of wheel backwards, setting leds
      int index = 69-i;
      //index of 
      int pixelValue = charPixels[text[charIndex]][ (subindex%widthMultiplier)*5+ i%heightMultiplier ];
      //set pixel
      if( pixelValue == 1){
        rawHex[0][a*pixelWidth+index]=textColor;
      }
    }
    

    
    
  }
 }


void setup()
{
  Serial.begin(115200);
  Serial1.begin(115200);
  
  octo.begin();
  pcontroller = new CTeensy4Controller<GRB, WS2811_800kHz>(&octo);

  FastLED.setBrightness(50);
  FastLED.addLeds(pcontroller, leds, numPins * ledsPerStrip);
  
  // Make the hall pin an input
  pinMode(sensorPin, INPUT);

  //buildText("T");
}

bool rmpMode = true;

void loop(){

  //Handle Bluetooth passthrough
  if (Serial.available()) {
    char dat = Serial.read();
    Serial1.write(dat);
  }

  //Handle Bluetooth Commands
  if (Serial1.available()) {
    char dat[100] = {};
    int i=0;
    while(Serial1.available()){
      
      dat[i] = Serial1.read();
      i++;
    }
    String input = String(dat);
    Serial.println(input);
    if(input.indexOf('!')!=0){
      char commandChar = input[0];
      int parameter = input.substring(1,input.indexOf('!')).toInt();
      switch(commandChar){
        case 'b'://Brightness
          FastLED.setBrightness(parameter);
          break;
        case 'r'://Rpm
          
          break;
        case 'o'://Offset
          offset = parameter;
          break;
        case 'p'://Preset image
          imageIndex=parameter;
          break;
      }
    }
  }

  float timeSinceRotation = micros() - rotationTimer; //us

  angle = timeSinceRotation / timePerDegree;

  if(rmpMode){
    for(int i=0; i<25200;i++){
      //Serial.print(int(rawHex[0][i]));
      //Serial.print(',');
    }

    //Serial.println("end");
    
  }
    
  //Display First Arm
  for(int x = 0; x<ledsPerStrip ;x++)
  {
    leds[x]= true ? CRGB(rawHex[imageIndex][(( (angle+offset) %360)*pixelWidth)+x]) : CRGB(0x0F0000);
  }
  //Display Second Arm
  for(int x = 0; x<ledsPerStrip ;x++)
  {
    leds[ledsPerStrip+x]= true ? CRGB(rawHex[imageIndex][( (angle+offset+180)%360)*pixelWidth+x]) : CRGB(0x000F00);
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
