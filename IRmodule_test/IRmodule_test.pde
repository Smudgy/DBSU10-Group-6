import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

OOCSI oocsi;
boolean[] trigArr = {false, false, false}; // array to store triggervalues in
String channelName = "IR6_test";

void setup() {
  size(300, 100);
  stroke(255);
  strokeWeight(2);
  colorMode( HSB, 100 );

  // connect with OOCSI client for calling the service
  oocsi = new OOCSI(this, "Smudgy", "oocsi.id.tue.nl");
  oocsi.subscribe(channelName, "channel");
  println();
  call1(1000); // method to connect to channel
}

void draw() {
  background(0);
  background( 0, 0, 100 );

  for (int i = 0; i < trigArr.length; i++) {
    if ( trigArr[i] ) {
      fill(100, 100, 100);
      rect( (i) * width/3, 0, width/3, 100);
    }
  }
}

void handleOOCSIEvent(OOCSIEvent e) {
  if (e.has("IR6sensor")) {
    println(e.getInt("IR6sensor", 0));
  }
}

void channel(OOCSIEvent e) {
  if (e.has("IR6sensor")) {
    println(e.getInt("IR6sensor", 0));
  }
}

void mousePressed() {
  // 1: create call to getIR6 with 1000ms timeout and data "triggered"
  OOCSICall call = oocsi.call("getIR6", 1000).data("triggered", true);
  // 2: send out and wait until either there is a response or the timeout has passed
  call.sendAndWait();
  // 3: check for response
  if (call.hasResponse()) {
    // 4: get data out of the first response
    trigArr = (boolean[]) call.getFirstResponse().getObject("triggered");
    println(trigArr);
  }
}

void call1(int delay) {
  if (delay <= 7000) {
    OOCSICall call = oocsi.call("setIR6", delay).data("channelName", channelName);
    call.sendAndWait();
    if (call.hasResponse()) {
      println("IR6Module linked to channel!");
    } else {
      call1(delay + 1000); // try again, with a second extra delay
    }
  }
}