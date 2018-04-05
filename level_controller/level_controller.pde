/**
 *  DBSU10 Casino level controller
 *  @author Tom van Roozendaal, group 6
 *  @version 1.0
 *  @since 24/03/2018
 *  
 *  Ideal playthrough:
 *  1. -- all sensors trigger (sticky for amount of time)
 *  2. soundbox plays "gr6_magnet.wav"
 *  3. - magnet keyboard detects 3 inputs
 *  4. soundbox plays "gr6_magnet2.wav"
 *  5. -- IR6 detects the right sensors (2)
 *  6. soundbox plays "gr6_clock.wav"
 *  7. - clock detects correct angle
 *  8. soundbox plays "gr6_clock2.wav"
 *  9. -- IR6 detects the right sensors (1)
 *  0. soundbox plays "gr6_grats.wav"
 *  
 *  When shit goes wrong:
 *  - soundbox plays "gr6_night.wav"    "Thats not how that night went."
 *  - soundbox plays "gr6_sitdown.wav"  "Sit down! you're not done here yet!"
 *  - soundbox plays "gr6_leave.wav"    "Please leave the table, loser."
 *  - soundbox plays ""
 */
import processing.serial.*;
import cc.arduino.*;
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

OOCSI oocsi;
int progress = 0; // step counter, indicates how much progress has been made
boolean success = false;
String[] progStr = {
  "Level initialization", 
  "All IR6 sensors triggered, Soundbox plays", 
  "Magnet keyboard detects correct bets", 
  "Two IR6 sensors triggered", 
  "Clock detects correct angle", 
  "One IR6 sensor triggered"
};
// module variables
String keypadCode1 = "012";
boolean keypadSuccess = false;
boolean[] trigArr = { false, false, false };
String soundbox = "soundboxA";

int timer = millis() + 5000; // 5 sec timer (sound files)
int timer2 = millis() + 1000; // 1 sec timer2 (checking sensors)

void setup() {
  size(200, 200);
  oocsi = new OOCSI(this, "level6", "localhost");

  // set keypad code
  OOCSICall c = oocsi.call("keypadSet", 1000).data("code", keypadCode1).sendAndWait();
  println(c.getFirstResponse().getString("result"));
  oocsi.subscribe("clock");
}

void draw() {
  background(50);
  textSize(16);
  noStroke();
  fill(255, 255, 255);
  text(progress + ": " + progStr[progress], 10, 10, width-20, height-20);

  // steps
  switch ( progress ) {
  case 0:
    // timer to loop sound files
    if ( millis() > timer ) {
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "gr6_sit").data("volume", 80);
      makeCall(c, 3);
      timer = millis() + 10000; // reset timer; 10 sec
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
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "gr6_welcome").data("volume", 80);
      makeCall(c, 3);
      timer = millis() + 20000; // reset timer; 15 sec
    }

    // if the keypad sends success message
    if ( keypadSuccess ) {
      timer = 0;
      success = true;
    }
    break;
    // ------------------------------------------------
  case 2:
    // timer to loop sound files
    //if ( millis() > timer ) {
    //  OOCSICall c = oocsi.call("soundbox", "play", 1000).data("name", "gr6_loser").data("volume", 80);
    //  makeCall(c, 3);
    //  timer = millis() + 10000; // reset timer; 10 sec
    //}

    //if ( millis() > timer2 ) {
    //  OOCSICall c = oocsi.call("getIR6", 1000).data("triggered", true).sendAndWait();
    //  if ( c.hasResponse() ) {
    //    trigArr = (boolean[]) c.getFirstResponse().getObject("triggered");
    //    timer = millis() + 1000;
    //  }
    //}

    //// if two sensors are triggered ( 0 and 1 )
    //if ( trigArr[0] && trigArr[1] ) {
    //  timer = 0;
    //  success = true;
    //}
    //break;
    // ------------------------------------------------
  case 3:
    // timer to loop sound files
    if ( millis() > timer ) {
      OOCSICall c = oocsi.call( soundbox, "play", 1000).data("name", "gr6_round2").data("volume", 80);
      makeCall(c, 3);
      timer = millis() + 20000; // reset timer; 20 sec
    }

    // if the clock is angeled successfully
    if (  ) {
      OOCSICall c = oocsi.call("getClock").data("", "");
    }
    break;
    // ------------------------------------------------
  case 4:
    break;
    // ------------------------------------------------
  case 5:
    break;
    // ------------------------------------------------
  case 6:
    break;
    // ------------------------------------------------
  case 7:
    break;
    // ------------------------------------------------
  case 8:
    break;
    // ------------------------------------------------
  case 9:
    break;
    // ------------------------------------------------
  case 10:

    break;
  default:  
    print("error, invalid progress value");
    break;
  }

  if ( success ) {
    progress++;
    success = false;
  }
}

// method for calling to modules whos response is irrelevant
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
  if ( e.has("type") && e.getString("type") == "success") {
    keypadSuccess = true;
  }
}
