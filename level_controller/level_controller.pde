/**
 *  DBSU10 IR sensor module
 *  @author Tom van Roozendaal, group 6
 *  @version 1.5
 *  @since 22/02/2018
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
String[] progStr = {
  "0. Level initialization", 
  "1. All IR6 sensors triggered", 
  "2. Soundbox plays 6start", 
  "3. Magnet keyboard detects correct bets", 
  "4. Soundbox plays 6bets_placed", 
  "5. Two IR6 sensors triggered", 
  "6. Soundbox plays 6loser", 
  "7. Clock detects correct angle", 
  "8. Soundbox plays 6clock", 
  "9. One IR6 sensor triggered", 
  "10. Soundbox plays 6grats"
};

void setup() {
  size(500, 100);
  // connect with OOCSI client for calling the service
  oocsi = new OOCSI(this, "Smudgy", "localhost");
}

void draw() {
  background(50);
  textSize(24);
  noStroke();
  fill(255, 255, 255);
  text(progStr[progress], 10, 10, 490, 90);

  if ( frameCount % 60 == 0 ) {
    progress = (progress + 1) % progStr.length;
  }
}

// method for calling the SoundBox
void soundBoxCall(int delay, String name) {
  if (delay <= 7000) {
    OOCSICall call = oocsi.call("play", delay).data("name", name).data("volume", 100);
    call.sendAndWait();
    if (call.hasResponse()) {
      println("IR6Module linked to channel!");
    } else {
      soundBoxCall(delay + 1000, name); // try again, with a second extra delay
    }
  }
}

void call2(int delay) {
  if (delay <= 7000) {
    OOCSICall call = oocsi.call("play", delay).data("name", "secret").data("volume", 100);
    call.sendAndWait();
    if (call.hasResponse()) {
      println("IR6Module linked to channel!");
    } else {
      call2(delay + 1000); // try again, with a second extra delay
    }
  }
}