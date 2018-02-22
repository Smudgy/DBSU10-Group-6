/**
 *  simple example from the OOCSI repo documentation
 */

import nl.tue.id.oocsi.*;

OOCSI oocsi;
float count = 0;
String clientName = "irSensorGroup6";
String channelName = "GhostRoomChannel";

void setup () { 
  size(200, 200);

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
    count += 0.01; // counts boo messages
  }
  println(count + "boos");

  oocsi.channel( channelName ).data("boo", 0).send();
}

// receive direct messages
void handleOOCSIEvent(OOCSIEvent e) {
  // print out the "intensity" value in the message
  println();
  println("yay a msg!");
  count += 0.025;

  oocsi.channel( clientName ).data("hi", "cool").send();
}

// visualize
void draw() {
  colorMode(HSB, 100);
  fill(count/2 % 100, 100, 100);

  //count++;
  colorMode(RGB, 100);
  background(0);
  stroke(100);
  strokeWeight(2);
  ellipse(100 + 40 * sin( count / 20 ), (count % 220) - 20, 20, 20);
}