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
String[] samplePathsDefault = {"snr.wav", "kck.wav", "hat.wav", "opn.wav","pr1.wav","pr2.wav","tm1.wav","tm2.wav"};
String path808 = "./sounds/808/";
String[] samplePaths808 = {path808 + "snr.wav", path808 + "kck.wav", path808 + "hat.wav", path808 + "opn.wav", path808 + "pr1.wav", path808 + "pr2.wav", path808 + "tm1.wav", path808 + "clp.wav"};

HashMap<String, AudioSample> samples = new HashMap<String,AudioSample>();

boolean ARDUINO_ENABLE = true;
boolean PHOTOCELL_ENABLE = true;
Arduino arduino;

color off = color(4, 79, 111);
color on = color(84, 145, 158);

int[] photoPins = {0,1,2,3,4,5};
int[] photoVal = new int[photoPins.length];
int[] thresholds = new int[photoPins.length];
boolean[] trigger = new boolean[photoPins.length];

HashMap<String,boolean[]> drumRow = new HashMap<String,boolean[]>();
boolean[] drumLock = new boolean[samplePathsDefault.length];
boolean[] hatRow = new boolean[16];
boolean[] snrRow = new boolean[16];
boolean[] kikRow = new boolean[16];
boolean[] openRow = new boolean[16];
boolean[] perc1Row = new boolean[16];
boolean[] perc2Row = new boolean[16];

boolean[] lock = new boolean[5];

ControlP5 gui;

public int bpm = 120;
int tempo = 125; // how long a sixteenth note is in milliseconds
int clock; // the timer for moving from note to note
int beat = 0; // which beat we're on
boolean beatTriggered = false; // only trigger each beat once
float lightSensitivity = 0.95; // 0 - 1.0

// reserve pins for sending LED data to Arduino
int strip1_msgPin = 6;  
int strip1_colorPin = 7;
int strip2_msgPin = 8;
int strip2_colorPin = 9;

String drumset = "808"; // options are default, 808

void setup() {
  size(600, 600);
  frameRate(400);
  // Prints out the available serial ports.
  println(Arduino.list());
  
    minim = new Minim(this);
  // load BD.mp3 from the data folder with a 1024 sample buffer
  // kick = Minim.loadSample("BD.mp3");
  // load BD.mp3 from the data folder, with a 512 sample buffer
    for(int i = 0; i < samplePathsDefault.length; i++) {
      if(drumset.equals("default")) {
        drumRow.put(samplePathsDefault[i].substring(0,3), new boolean[16]);                                                       
        samples.put(samplePathsDefault[i].substring(0,3), minim.loadSample(samplePathsDefault[i],512));
      } else if (drumset.equals( "808")) {
        int l = path808.length();
        drumRow.put(samplePaths808[i].substring(l,l+3), new boolean[16]);      
        samples.put(samplePaths808[i].substring(l,l+3), minim.loadSample(samplePaths808[i],512));
      } 
        
  }
  
  //println(samples);
  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
    println(drumRow);
    drumRow.get("snr")[4] = true;
    drumRow.get("snr")[12] = true;
    
    drumRow.get("kck")[0] = true;
    drumRow.get("kck")[4] = true;
    drumRow.get("kck")[8] = true;
    drumRow.get("kck")[12] = true;
    if(ARDUINO_ENABLE)
        arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
  if(PHOTOCELL_ENABLE) {
    
  if(drumset.equals("default")) {
      drumRow.get("hat")[0] = true;
      drumRow.get("hat")[2] = true;
      drumRow.get("hat")[4] = true;
      drumRow.get("hat")[6] = true;
      drumRow.get("hat")[8] = true;
      drumRow.get("hat")[10] = true;
      drumRow.get("hat")[12] = true;
      drumRow.get("hat")[14] = true;
                        
      drumRow.get("pr2")[2] = true;
      drumRow.get("pr2")[6] = true;
      drumRow.get("pr2")[10] = true;
      drumRow.get("pr2")[14] = true;
      
      drumRow.get("pr1")[2] = true;
      drumRow.get("pr1")[6] = true;
      drumRow.get("pr1")[10] = true;
      drumRow.get("pr1")[14] = true;
      
      drumRow.get("opn")[0] = true;
      drumRow.get("opn")[4] = true;
      drumRow.get("opn")[8] = true;
      drumRow.get("opn")[12] = true;
      
      drumRow.get("tm1")[0] = true;
      drumRow.get("tm1")[4] = true;
      drumRow.get("tm1")[8] = true;
      drumRow.get("tm1")[12] = true;
      
      drumRow.get("tm2")[0] = true;
      drumRow.get("tm2")[4] = true;
      drumRow.get("tm2")[8] = true;
      drumRow.get("tm2")[12] = true;
  } else if (drumset.equals("808")) {
    // http://www.attackmagazine.com/technique/beat-dissected/dark-berlin-techno/
      drumRow.get("tm1")[6] = true;
      drumRow.get("tm1")[12] = true;
      
      drumRow.get("clp")[4] = true; 
      
      drumRow.get("pr1")[8] = true;
      
      drumRow.get("hat")[2] = true;
      drumRow.get("hat")[6] = true;
      drumRow.get("hat")[10] = true;
      drumRow.get("hat")[14] = true;
      
      drumRow.get("pr2")[4] = true;
      drumRow.get("pr2")[12] = true;
                        
      drumRow.get("opn")[4] = true;
      drumRow.get("opn")[12] = true;
      
      
      
  }
  } 
  
  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);
  
  clock = millis();
  
  gui = new ControlP5(this);
  gui.setColorForeground(color(128, 200));
  gui.setColorActive(color(255, 0, 0, 200));

  Toggle h;
  int k = 0;

  for (Map.Entry row : drumRow.entrySet()) {
    for (int i = 0; i < 16; i++)
    {
      String drumName = samplePathsDefault[k].substring(0,3);
      h = gui.addToggle(drumName + i, ((boolean[])row.getValue())[i], 10+i*24, 50*(k+1), 14, 30);
      h.setId(i);
      h.setLabel(drumName);
    }
    k++;
  }

  gui.addNumberbox("bpm", 120, 10, 5, 20, 15);
  
  // Set the Arduino digital pins as inputs.
  for (int i = 0; i <= 13; i++)
  if(ARDUINO_ENABLE)
     arduino.pinMode(i, Arduino.INPUT);
    
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
  for (int i = 0; i < photoPins.length; i++) {
    if(ARDUINO_ENABLE == false || PHOTOCELL_ENABLE == false)
      trigger[i] = true;
    else {
      trigger[i] = false;

      if(thresholds[i] == 0)
        thresholds[i] = arduino.analogRead(photoPins[i]);
      
      photoVal[i] = arduino.analogRead(photoPins[i]);

      if( (photoVal[i] < (thresholds[i] * lightSensitivity)) && (photoVal[i] != 0)) {
        println("hit on ball "+i);
        trigger[i] = true;
      }
  }
  }

    int ledColor = 0;
    if ( !beatTriggered )
    {
      for (Map.Entry row : drumRow.entrySet())
        {
          if (((boolean[])row.getValue())[beat]) {
            boolean fire = false; 
            if(row.getKey().equals("kck") )
              fire = true;
            if(row.getKey().equals("snr") ) 
              fire = true;
            if(row.getKey().equals("hat") && trigger[5]) {
              fire = true;
              ledColor = 300; }
            if(row.getKey().equals("pr1") && trigger[1]) {
              fire = true;
                            ledColor = 60; }
             if(row.getKey().equals("pr2") && trigger[3]) {
              fire = true;
                            ledColor = 120; }
             if(row.getKey().equals("opn") && trigger[4]) {
              fire = true;
                            ledColor = 240; }
            if(row.getKey().equals("tm1") && trigger[2]) {
              fire = true; 
                            ledColor = 180; }
             if(row.getKey().equals("tm2") && trigger[0]) {
              fire = true;
                            ledColor = 0 ; ;}
            if(fire)
              samples.get(row.getKey()).trigger();
          }
        }
     beatTriggered = true;
    }
    
    //if ( trigger[1] && drumRow[0][beat]) hat.trigger();
    // if ( drumRow.get("snr")[beat] ) snare.trigger();
    //if ( drumRow.get("kik")[beat] ) kick.trigger();
    //if ( (trigger[0] || lock[4]) && drumRow.get("pr2")[beat]) perc2.trigger();
    // if ( (trigger[2] || lock[3]) && drumRow.get("pr1")[beat]) perc1.trigger();

  

  

  stroke(128);
  if ( beat % 4 == 0 )
  {
    fill(200, 0, 0);
  }
  else
  {
    fill(0, 200, 0);
  }
    
  
  // beat marker    
  rect(10+beat*24, 35, 14, 9);
  if(beatTriggered && ARDUINO_ENABLE) {
    arduino.analogWrite(strip1_msgPin, beat); 
    arduino.analogWrite(strip2_msgPin, beat);
    if(ledColor <180) {
      arduino.analogWrite(strip2_colorPin, ledColor);
    } else {
      arduino.analogWrite(strip1_colorPin, ledColor);
    }
  }
  //println(beat);
  // use the mix buffer do draw the waveforms.
  // because these are MONO files, we could have used the left or right buffers and got the same data
  /*for (int i = 0; i < kick.mix.size()-1; i++)
  {
    line(i, 65 - hat.mix.get(i)*30, i+1, 65 - hat.mix.get(i+1)*30);
    line(i, 115 - snare.mix.get(i)*30, i+1, 115 - snare.mix.get(i+1)*30);
    line(i, 165 - kick.mix.get(i)*30, i+1, 165 - kick.mix.get(i+1)*30);
  }*/
  
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
  for(Map.Entry sample : samples.entrySet())
    ((AudioSample)sample.getValue()).close();
    
  minim.stop();
  
  super.stop();
}

public void controlEvent(ControlEvent e)
{
  //println(e.controller().name() + ": " + e.controller().value());
  //println(e.controller().name().substring(0,3));
  for(Map.Entry row : drumRow.entrySet()) {
    if(e.controller().name().substring(0,3).equals(row.getKey()))
      ((boolean[])row.getValue())[ e.controller().id() ] = e.controller().value() == 0.0 ? false : true;
  }
  /*
    if ( e.controller().name().substring(0,7).equals("hatLock" )) {
        lock[0] = e.controller().value() == 0.0 ? false : true;
    }
    if ( e.controller().name().substring(0,7).equals("snrLock" ))
            lock[1] = e.controller().value() == 0.0 ? false : true;
    if ( e.controller().name().substring(0,7).equals("kikLock" ))
            lock[2] = e.controller().value() == 0.0 ? false : true;
    if ( e.controller().name().substring(0,9).equals("perc1Lock" ))
            lock[3] = e.controller().value() == 0.0 ? false : true;
    if ( e.controller().name().substring(0,9).equals("perc2Lock" ))
            lock[4] = e.controller().value() == 0.0 ? false : true;
            */
  if ( e.controller().name() == "bpm" )
  {
    float bps = (float)bpm/60.0f;
    tempo = int(1000 / (bps * 4)); 
  }
}

class drumRow {
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

  // assume there's a minim and arduino, do we need to pass this in?
  drumRow(String samplePath, int bar, int pin, int ledCol) {
    drumSample = minim.loadSample(samplePath, 512);
    drumName = samplePath.substring(0,3);
    whichBar = bar; 
    whichPin = pin;
    ledColor = ledCol;
    threshold = arduino.analogRead(whichPin);
    lastVal = threshold;
  }
  
  void createRowToggles(ControlP5 g, int rowNumber) {
    Toggle tog; 
    for (int i = 0; i < 16; i++) 
    {
      tog = g.addToggle(drumName + i, sequence[i], 10+i*24, 50*(rowNumber), 14, 30);
      tog.setId(i);
      tog.setLabel(drumName);
    }
  }
  
  void setSequence(int[] seq) {
    for(int i = 0; i < 15; i++)
      if(seq[i])
        sequence[i] = true;
  }
  
  // assume there's an arduino, do we need to pass this in?
  void checkForTrigger() {
    lastVal = arduino.analogRead(whichPin);
    if( (lastVal < (threshold * lightSensitivity)) && (lastVal != 0) )
      {
        // trigger sound
      }
  void func() {
   int x; 
  }
}
