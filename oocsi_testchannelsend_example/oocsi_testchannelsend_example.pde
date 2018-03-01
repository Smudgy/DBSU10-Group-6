/**
 *  simple send example from the OOCSI repo documentation
 *  note: you cannot receive messages from a channel that you've send from the same pde sketch (= same client name)
 */

import nl.tue.id.oocsi.*;

OOCSI oocsi;
float count = 0;
int boos = 0;
String clientName = "irSensorGroup6_2";
String channelName = "GhostRoomChannel";

void setup () { 
  size(100, 100);

  // new oocsi object
  oocsi = new OOCSI(this, clientName, "localhost", true);
}

// receive direct messages
void handleOOCSIEvent(OOCSIEvent e) {
  // print out the "intensity" value in the message
  count += 0.025;

  oocsi.channel( clientName ).data("hi", "cool").send();
}

// draw
void draw() {
  background(255);
  // send message every # frames
  noStroke();
  textAlign(CENTER, CENTER);
  if (frameCount % 5 == 0){
    oocsi.channel( channelName ).data("boo", 0).send();
    fill(255, 0, 0);
    textSize(20);
  } else {
    fill(0, 0, 255);
    textSize(20); 
  }
  text("sending", width/2, height/2); 
}