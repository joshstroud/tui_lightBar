/*
 * Firmata is a generic protocol for communicating with microcontrollers
 * from software on a host computer. It is intended to work with
 * any host computer software package.
 *
 * To download a host software package, please clink on the following link
 * to open the download page in your default browser.
 *
 * http://firmata.org/wiki/Download
 */

/* Supports as many analog inputs and analog PWM outputs as possible.
 *
 * This example code is in the public domain.
 */
#include <Firmata.h>
#include "LPD8806.h"
#include "SPI.h" // Comment out this line if using Trinket or Gemma
#ifdef __AVR_ATtiny85__
 #include <avr/power.h>
#endif

// Number of RGB LEDs in strand:
int nLEDs = 16;

int numStrips = 4;

int strips_colors[] = {0,0,0,0};

// digital outputs
int strips_dataPins[] = {2,4,6,8};
int strips_clockPins[] = {3,5,7,9};

// ghost analog inputs for messages, max is 10
int strips_msgPins[] = {9,18,20,22};
int strips_colorPins[] = {10,19,21,23};

LPD8806 strips[4] = {LPD8806(nLEDs, strips_dataPins[0], strips_clockPins[0]), 
                      LPD8806(nLEDs, strips_dataPins[1], strips_clockPins[1]), 
                      LPD8806(nLEDs, strips_dataPins[2], strips_clockPins[2]), 
                      LPD8806(nLEDs, strips_dataPins[3], strips_clockPins[3])};

byte analogPin = 0;

void setLEDPins(int whichStrip, LPD8806 strip, byte pin, int value) {
    int i = whichStrip;
    if(pin ==  strips_colorPins[i])
      strips_colors[i] = value;
    if(pin ==  strips_msgPins[i]) {
      if(strips_colors[i] == 0) {
        if(value % 4 == 0)
           strips[i].setPixelColor(value,  strips[i].Color(200,0,0));
        else
           strips[i].setPixelColor(value,  strips[i].Color(0,200,0));
      } else {
        for(int i = 0; i < nLEDs; i++)
            strips[i].setPixelColor(i, Wheel(strips[i], strips_colors[i]));
         strips_colors[i] = 0;
      }
       strips[i].show();
       strips[i].setPixelColor(value,0);
    }
 }  
  
void setManyPixelsColor(LPD8806 strip, const int* whichPixels, size_t arraySize, int cor) {
  for(int i = 0; i < arraySize; i++) {
    strip.setPixelColor(whichPixels[i], color);
  }
}
    


void analogWriteCallback(byte pin, int value)
{
    if (IS_PIN_PWM(pin)) {
        pinMode(PIN_TO_DIGITAL(pin), OUTPUT);
        analogWrite(PIN_TO_PWM(pin), value);
    }
    
    int whichStrip = 0;
    for(int i = 0; i < numStrips; i++) {
      if(pin == strips_msgPins[i] || pin == strips_colorPins[i])
        setLEDPins(i, strips[i], pin, value);
    }
}

void setup()
{
    Firmata.setFirmwareVersion(0, 1);
    Firmata.attach(ANALOG_MESSAGE, analogWriteCallback);
    Firmata.begin(57600);
    
    #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000L)
    clock_prescale_set(clock_div_1); // Enable 16 MHz on Trinket
  #endif

  for(int i = 0; i < numStrips; i++) {
  // Start up the LED  strip1
   //strips[i] =  LPD8806(nLEDs,  strips_dataPins[i],  strips_clockPins[i]);
   strips[i].begin();
   strips[i].show();
  }
}

void loop()
{

    while(Firmata.available()) {
        Firmata.processInput();
    }
    // do one analogRead per loop, so if PC is sending a lot of
    // analog write messages, we will only delay 1 analogRead
    Firmata.sendAnalog(analogPin, analogRead(analogPin)); 
    analogPin = analogPin + 1;
    if (analogPin >= TOTAL_ANALOG_PINS) analogPin = 0;
}

// removed LED functions, look at old colde

void rainbowCycle(LPD8806 strip, uint8_t wait) {
  uint16_t i, j;
  
  for (j=0; j < 384 * 5; j++) {     // 5 cycles of all 384 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel( strip, ((i * 384 / strip.numPixels()) + j) % 384) );
    }  
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

uint32_t Wheel(LPD8806 strip, uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128;   //Red down
      g = WheelPos % 128;      // Green up
      b = 0;                  //blue off
      break; 
    case 1:
      g = 127 - WheelPos % 128;  //green down
      b = WheelPos % 128;      //blue up
      r = 0;                  //red off
      break; 
    case 2:
      b = 127 - WheelPos % 128;  //blue down 
      r = WheelPos % 128;      //red up
      g = 0;                  //green off
      break; 
  }
  return(strip.Color(r,g,b));
}
