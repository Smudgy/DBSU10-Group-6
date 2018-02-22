/**
*  simple example from the OOCSI repo documentation
*/

import nl.tue.id.oocsi.*;

OOCSI oocsi;

void setup () { 
  // new oocsi object
  oocsi = new OOCSI(this, "counterA", "localhost");
  // send data with message "count" and key 0, over channel "counterA"
  oocsi.channel("counterA").data("count", 0).send();
}

// oocsi event handler
void handleOOCSIEvent(OOCSIEvent e) {
  int count = e.getInt("count", 0);
  println(count);
  // increase count, send message again
  oocsi.channel("counterA").data("count", count + 1).send();
}