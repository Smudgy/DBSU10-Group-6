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
  size(300, 300);

  // new oocsi object
  oocsi = new OOCSI(this, clientName, "localhost", true);

  // send messages
  //oocsi.channel( clientName ).data("hi", "cool").send();
}

// receive direct messages
void handleOOCSIEvent(OOCSIEvent e) {
  // print out the "intensity" value in the message
  count += 0.025;

  oocsi.channel( clientName ).data("hi", "cool").send();
}

// visualize
void draw() {
  oocsi.channel( channelName ).data("boo", 0).send();
}