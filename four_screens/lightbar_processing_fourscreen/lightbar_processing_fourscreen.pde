/*
arduino_input
 
 Demonstrates the reading of digital and analog pins of an Arduino board
 running the StandardFirmata firmware.
 
 To use:
 * Using the Arduino software, upload the StandardFirmata example (located
 in Examples > Firmata > StandardFirmata) to your Arduino board.
 * Run this sketch and look at the list of serial ports printed in the
 message area below. Note the index of the port corresponding to your
 Arduino board (the numbering starts at 0).  (Unless your Arduino board
 happens to be at index 0 in the list, the sketch probably won't work.
 Stop it and proceed with the instructions.)
 * Modify the "arduino = new Arduino(...)" line below, changing the number
 in Arduino.list()[0] to the number corresponding to the serial port of
 your Arduino board.  Alternatively, you can replace Arduino.list()[0]
 with the name of the serial port, in double quotes, e.g. "COM5" on Windows
 or "/dev/tty.usbmodem621" on Mac.
 * Run this sketch. The squares show the values of the digital inputs (HIGH
 pins are filled, LOW pins are not). The circles show the values of the
 analog inputs (the bigger the circle, the higher the reading on the
 corresponding analog input pin). The pins are laid out as if the Arduino
 were held with the logo upright (i.e. pin 13 is at the upper left). Note
 that the readings from unconnected pins will fluctuate randomly. 
 
 For more information, see: http://playground.arduino.cc/Interfacing/Processing
 */

import processing.serial.*;
import ddf.minim.*;
import java.util.Map;

import controlP5.*;
import cc.arduino.*;

Minim minim;

String[] samplePathsDefault = {
  "snr.wav", "kck.wav", "hat.wav", "opn.wav", "pr1.wav", "pr2.wav", "tm1.wav", "tm2.wav"
};

String path808 = "./sounds/808/";
String[] samplePaths808 = {
  path808 + "snr.wav", path808 + "kck.wav", path808 + "hat.wav", path808 + "opn.wav", path808 + "pr1.wav", path808 + "pr2.wav", path808 + "tm1.wav", path808 + "clp.wav"
};

boolean ARDUINO_ENABLE = true;
boolean PHOTOCELL_ENABLE = true;
Arduino arduino;

color off = color(4, 79, 111);
color on = color(84, 145, 158);

int photoCellsPerBar = 4;

// use photoPins to count number of tracks
int[] photoPins = {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
};

// reserve pins for sending LED data to Arduino
int[] msgPins = {
  6, 8, 10, 12
};
int[] colorPins {
  7, 9, 11, 13
};

ControlP5 gui;

DrumRow[] drumRows;

public int bpm = 120;
int tempo = 125; // how long a sixteenth note is in milliseconds
int clock; // the timer for moving from note to note
int beat = 0; // which beat we're on
float lightSensitivity = 0.95; // 0 - 1.0



String drumset = "808"; // options are default, 808



void setup() {
  size(600, 600);
  frameRate(400);
  // Prints out the available serial ports.
  println(Arduino.list());

  minim = new Minim(this);

  if (ARDUINO_ENABLE)
    arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
    
  // Set the Arduino digital pins as inputs.
  for (int i = 0; i <= 13; i++) {
    if (ARDUINO_ENABLE)
      arduino.pinMode(i, Arduino.INPUT);
}

  gui = new ControlP5(this);
  gui.setColorForeground(color(128, 200));
  gui.setColorActive(color(255, 0, 0, 200));

  gui.addNumberbox("bpm", 120, 10, 5, 20, 15);

  // create drum row for each sample path, assign lightbar, pin
  // watch for off-by-one errors!
  if (samplePathsDefault.length != photoPins.length)
    println("sample paths length does not equal number of photo pins!");

  for (int i = 0; i < samplePathsDefault.length; i++) {
    int whichBar = Math.floor(i/photoCellsPerBar);
    String samplePath = "";
    if (drumset.equals("808")) 
      samplePath = samplePaths808[i];
    else 
      samplePath = samplePathsDefault[i];
    DrumRow dr = new DrumRow(samplePathsDefault[i], whichBar, photoPins[i], map(i, 0, samplePathsDefault.length, 0, 384), colorPins[whichBar], msgPins[whichBar]);
    dr.createRowToggles(i);
    drumRows = append(drumRows, dr);
  }

  for (int i = 0; i < drumRows.length; i++) {
    String n = drumRows[i].drumName;
    // hard-coded for now... 16 numbers
    int[] seqSet = {
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    };
    if (drumset.equals("default")) {
      if (n.equals("snr") {
        seqSet = {
          0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("kck")) {
        seqSet = {
          1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("hat")) {
        seqSet = {
          1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("pr1")) {
        seqSet = {
          0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("pr2")) {
        seqSet = {
          0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("opn")) {
        seqSet = {
          1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("tm1")) {
        seqSet = {
          1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (n.equals("tm2")) {
        seqSet = {
          1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
        };
        drumRows[i].setSequence(seqSet);
      } else if (drumset.equals("808")) {
        if (n.equals("tm1")) {
          seqSet = {
            0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
          };
          drumRows[i].setSequence(seqSet);
        } else if (n.equals("clp")) {
          seqSet = {
            1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
          };
          drumRows[i].setSequence(seqSet);
        } else if (n.equals("pr1")) {
          seqSet = {
            1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
          };
          drumRows[i].setSequence(seqSet);
        } else if (n.equals("hat")) {
          seqSet = {
            0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
          };
          drumRows[i].setSequence(seqSet);
        } else if (n.equals("pr2")) {
          seqSet = {
            0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
          };
          drumRows[i].setSequence(seqSet);
        } else if (n.equals("opn")) {
          seqSet = {
            0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
          };
          drumRows[i].setSequence(seqSet);
        }
      }
    }
  }

  clock = millis();

}




void draw() {
  background(0);
  fill(255);
  if ( millis() - clock >= tempo )
  {
    clock = millis();
    beat = (beat+1) % 16;
    beatTriggered = false;
  }
  for (int i = 0; i < drumRows.length; i++)
    drumRows[i].checkForTrigger(beat);

  stroke(128);
  if ( beat % 4 == 0 )
  {
    fill(200, 0, 0);
  } else
  {
    fill(0, 200, 0);
  }


  // beat marker    
  rect(10+beat*24, 35, 14, 9);

  gui.draw();
}

/*
void keyPressed()
 {
 if ( key == 'k' ) kick.trigger();
 }
 */

void stop()
{
  // always close Minim audio classes when you are done with them
  for (int i = 0; i < drumRows.length; i++)
    drumRows[i].drumSample.getValue().close();

  minim.stop();

  super.stop();
}

public void controlEvent(ControlEvent e)
{
  for (int i = 0; i < drumRows.length; i++) {
    if (e.controller().name().substring(0, 3).equals(drumRows[i].drumName))
      boolean val = true;
      if(e.controller().value() == 0.0)
        val = false;
      drumRows[i].sequence[e.controller().id()] = val;
  }
  
  if ( e.controller().name() == "bpm" )
  {
    float bps = (float)bpm/60.0f;
    tempo = int(1000 / (bps * 4));
  }
}

class DrumRow {
  boolean lock = false;
  boolean trigger = false;
  boolean[] sequence = new boolean[16];
  int ledColor;
  int whichBar;
  int whichPin;
  AudioSample drumSample;
  String drumName;
  boolean hold = false;
  int threshold = 0;
  int lastVal = 0;
  int colorPin;
  int msgPin; 

  // assume there's a minim and arduino, do we need to pass this in?
  DrumRow(String samplePath, int bar, int pin, int ledCol, int cPin, int mPin) {
    drumSample = minim.loadSample(samplePath, 512);
    drumName = samplePath.substring(0, 3);
    whichBar = bar; 
    whichPin = pin;
    ledColor = ledCol;
    threshold = arduino.analogRead(whichPin);
    lastVal = threshold;
    colorPin = cPin;
    msgPin = mPin;
  }

  void createRowToggles(int rowNumber) {
    Toggle tog; 
    for (int i = 0; i < 16; i++) 
    {
      tog = gui.addToggle(drumName + i, sequence[i], 10+i*24, 50*(rowNumber), 14, 30);
      tog.setId(i);
      tog.setLabel(drumName);
    }
  }

  void setSequence(int[] seq) {
    for (int i = 0; i < 15; i++)
      if (seq[i])
      sequence[i] = true;
  }

  // assume there's an arduino, do we need to pass this in?
  boolean checkForTrigger(int beat) {
    boolean beatTriggered = false;
    lastVal = arduino.analogRead(whichPin);

    if ( (lastVal < (threshold * lightSensitivity)) && (lastVal != 0))
    {
      if (sequence[beat] == true)
      { 
        println("triggering drum track " + i);
        beatTriggered = true;
        drumSample.trigger();
        arduino.analogWrite(colorPin, ledColor);
      }
    }
    return beatTriggered;
  }
}

