/**
 *  DBSU10 Casino level controller
 *  @author Tom van Roozendaal, group 6
 *  @version 1.2
 *  @since 24/03/2018
 *  
 *  Ideal playthrough:
 *  0. soundbox plays "group6_sit.wav"
 *  1. -- all sensors trigger ( validating the values through a loop )
 *  2. soundbox plays "group6_bets.wav"
 *  3. -- magnet keyboard detects the 3 correct inputs ( sends success message )
 *  4. soundbox plays "group6_lucky.wav" and "group6_roll_start.wav"
 *  5. -- clock detects correct angle ( sends success message )
 *  6. soundbox plays "group6_roll_end.wav" and "group6_cheers.wav"
 *  
 */
import processing.serial.*;
import cc.arduino.*;
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

OOCSI oocsi;
int progress = 0; // step counter, indicates how much progress has been made
boolean success = false;
String[] progStr = {
  "Level initialization, next: IR sensors", 
  "All IR6 sensors triggered, next: keypad", 
  "Magnet keyboard detects correct bets, next: clock", 
  "Clock detects correct angle, next: success!", 
  "Cheers, level finished"
};
// module variables
boolean[] trigArr = { false, false, false };
String keypadCode1 = "357";
boolean keypadSuccess = false;
boolean clockSuccess = false;
String soundbox = "soundbox2";
int sbVol = 70;

// timers
int timer = millis() + 5000; // 5 sec timer (for playing sound files)
int timer2 = millis() + 1000; // 1 sec timer2 (for checking modules)

void setup() {
  size(200, 200);
  oocsi = new OOCSI(this, "level6", "oocsi.id.tue.nl");

  // set keypad code
  OOCSICall c = oocsi.call("keypadSet", 1000).data("code", keypadCode1).sendAndWait();
  if ( c.hasResponse() ) {
    println(c.getFirstResponse().getString("result"));
  }
  // set clock code
  oocsi.subscribe("clock1200");
  oocsi.channel("clock1200").data("clockSet", 80).send();
  println();
}

void draw() {
  // some visualization
  background(50);
  textSize(16);
  noStroke();
  fill(255, 255, 255);
  text(Math.min(progress, 4) + ": " + progStr[Math.min(progress, 4)], 10, 10, width-20, height-20);

  // steps
  switch ( progress ) {
  case 0:
    // timer to loop sound files
    if ( millis() > timer ) {
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "group6_sit2").data("volume", sbVol);
      makeCall(c, 3);
      timer = millis() + 7000; // reset timer; 7 sec
    }

    if ( millis() > timer2 ) {
      OOCSICall c = oocsi.call("getIR6", 1000).data("triggered", true).sendAndWait();
      if ( c.hasResponse() ) {
        trigArr = (boolean[]) c.getFirstResponse().getObject("triggered");
        timer = millis() + 1000;
      }
    }

    // if all sensors are triggered
    if ( trigArr[0] && trigArr[1] && trigArr[2] ) {
      timer = 0;
      success = true;
    }
    break;
    // ------------------------------------------------
  case 1:
    // timer to loop sound files
    if ( millis() > timer ) {
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "group6_bets2").data("volume", sbVol);
      makeCall(c, 3);
      timer = millis() + 10000; // reset timer; 10 sec
    }

    // if the keypad sends success message
    if ( keypadSuccess ) {
      timer = 0;
      success = true;
      OOCSICall c2 = oocsi.call( soundbox, "play", 1000).data("name", "group6_roll_start").data("volume", sbVol);
      makeCall(c2, 3);
    }
    break;
    // ------------------------------------------------
  case 2:
    // timer to loop sound files
    if ( millis() > timer ) {
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "group6_lucky2").data("volume", sbVol);
      makeCall(c, 3);
      timer = millis() + 10000; // reset timer; 10 sec
    }

    // if the clock is angeled successfully
    if ( clockSuccess ) {
      timer = 0;
      success = true;
    }
    break;
    // ------------------------------------------------
  case 3:
    if ( millis() > timer ) {
      OOCSICall c2 = oocsi.call( soundbox, "play", 1000).data("name", "group6_roll_end").data("volume", sbVol);
      makeCall(c2, 3);
    }
    if ( millis() > timer + 800) {
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "group6_cheer").data("volume", sbVol);
      makeCall(c, 3);
      success = true;
    }
    break;
    // ------------------------------------------------
  case 4:
    if ( millis() > timer ) {
      println("success! Level finished");
      timer = millis() + 5000;
    }
    break;
  default:
    if ( millis() > timer ) {
      println("error, invalid progress value");
      timer = millis() + 5000;
    }
    break;
  }
  
  // advance if the step was successful
  if ( success ) {
    progress++;
    success = false;
  }
}

// -------------------------- METHODS --------------------------

// method for calling to modules without relevant feedback
// i.e. soundbox
void makeCall(OOCSICall call, int tries) {
  if (tries > 0) {
    call.sendAndWait();
    if (call.hasResponse()) {
      println("call made");
    } else {
      makeCall(call, tries - 1); // try again
    }
  }
}

// OOCSI direct receiver
void handleOOCSIEvent(OOCSIEvent e) {
  if ( e.has("type") && e.getString("type") == "success" && !keypadSuccess) {
    keypadSuccess = true;
    println("keypad is successful");
  }
}

// OOCSI clock channel receiver
void clock1200(OOCSIEvent e) {
  if ( e.has("clockVerify") && e.getInt("clockVerify", 0) == 1 && !clockSuccess) {
    clockSuccess = true;
    println("clock is successful");
  }
}

// simple skip feature
void mousePressed() {
  fill(0, 168, 107, 112);
  rect(0, 0, width, height);
  
  progress++;
  timer = 0;
  timer2 = 0;
}
