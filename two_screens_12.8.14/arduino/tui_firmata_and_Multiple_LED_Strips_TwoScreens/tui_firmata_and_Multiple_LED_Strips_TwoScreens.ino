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

int strip1_color = 0;
int strip2_color = 0;

// digital outputs
int  strip1_dataPin  = 2;
int  strip1_clockPin = 3;
int  strip2_dataPin  = 4;
int  strip2_clockPin = 5;

// ghost analog inputs for messages, max is 10
int  strip1_msgPin = 6;
int  strip1_colorPin = 7;
int  strip2_msgPin = 8;
int  strip2_colorPin = 9;

// First parameter is the number of LEDs in the strand.  The LED  strip1s
// are 32 LEDs per meter but you can extend or cut the  strip1.  Next two
// parameters are SPI data and clock pins:
LPD8806  strip1 = LPD8806(nLEDs,  strip1_dataPin,  strip1_clockPin);
LPD8806  strip2 = LPD8806(nLEDs,  strip2_dataPin,  strip2_clockPin);

byte analogPin = 0;

void analogWriteCallback(byte pin, int value)
{
    if (IS_PIN_PWM(pin)) {
        pinMode(PIN_TO_DIGITAL(pin), OUTPUT);
        analogWrite(PIN_TO_PWM(pin), value);
    }
    // strip 1
    
    if(pin == strip1_colorPin || pin == strip1_msgPin) {
      if(pin ==  strip1_colorPin)
        strip1_color = value;
      if(pin ==  strip1_msgPin) {
        if(strip1_color == 0) {
          if(value % 4 == 0)
             strip1.setPixelColor(value,  strip1.Color(200,0,0));
          else
             strip1.setPixelColor(value,  strip1.Color(0,200,0));
        } else {
          for(int i = 0; i < nLEDs; i++)
              strip1.setPixelColor(i, Wheel(strip1, strip1_color));
           strip1_color = 0;
        }
         strip1.show();
         strip1.setPixelColor(value,0);
      }
    }
      
      // strip 2
     if(pin == strip2_colorPin || pin == strip2_msgPin) {
       if(pin ==  strip2_colorPin)
        strip2_color = value;
      if(pin ==  strip2_msgPin) {
        if(strip2_color == 0) {
          if(value % 4 == 0)
             strip2.setPixelColor(value,  strip2.Color(200,0,0));
          else
             strip2.setPixelColor(value,  strip2.Color(0,200,0));
        } else {
          for(int i = 0; i < nLEDs; i++)
              strip2.setPixelColor(i, Wheel(strip2, strip2_color));
           strip2_color = 0;
        }
      }
  
         strip2.show();
         strip2.setPixelColor(value,0);
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

  // Start up the LED  strip1
   strip1.begin();
   strip2.begin();

  // Update the  strip1, to start they are all 'off'
   strip1.show();
   strip2.show();
  
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
