/**
 *  simple example from the OOCSI repo documentation
 */

import nl.tue.id.oocsi.*;

OOCSI oocsi;
float count = 0;
int boos = 0;
int booCount = -1;
String clientName = "irSensorGroup6";
String channelName = "GhostRoomChannel";

void setup () { 
  size(300, 300);
  colorMode(HSB, 100);
  
  // new oocsi object
  oocsi = new OOCSI(this, clientName, "localhost", true);
  oocsi.subscribe( channelName, "testchannel");

  // send messages
  oocsi.channel( clientName ).data("hi", "cool").send();
  // oocsi.channel( channelName ).data("boo", 0).send();
}

// receive from channel
// doesn't work if you've created the channel
void testchannel(OOCSIEvent e) {
  if (e.has("boo")) {
    boos++; // counts boo messages
  }
  println((boos % 900) + " BOOs");
}

// receive direct messages
void handleOOCSIEvent(OOCSIEvent e) {
  // print out the "intensity" value in the message
  count += 0.025;

  oocsi.channel( clientName ).data("hi", "cool").send();
}

// visualize
void draw() {
  background(0);
  
  stroke(0);
  strokeWeight(2);
  for (int y = 0; y < height && booCount < (boos % 900); y += 10) {
    for (int x = 0; x < width && booCount < (boos % 900); x += 10) {
      fill(x/3, 60, 100 - y/3  );
      rect(x, y, 10, 10 );
      booCount++;
    }
  }
  booCount = 0;
   
  noStroke();
  fill(100, 0, 100);
  ellipse(150 + 40 * sin( count / 80 ), (count/2 % 340) - 40, 20, 20);
}