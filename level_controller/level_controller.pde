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
int progress = 0;

void setup() {
  size(300, 100);
  stroke(255);
  strokeWeight(2);
  colorMode( HSB, 100 );

  // connect with OOCSI client for calling the service
  oocsi = new OOCSI(this, "Smudgy", "oocsi.id.tue.nl");
  OOCSICall call = oocsi.channel("soundbox").call("play",1000).data("name", "secret").data("volume", 100).send();
}

void draw() {
  
  
  
}