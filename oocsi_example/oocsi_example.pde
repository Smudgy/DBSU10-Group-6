/**
 *  simple send example from the OOCSI repo documentation
 *  note: you cannot receive messages from a channel that you've send from the same pde sketch (= same client name)
 */

import nl.tue.id.oocsi.*;

OOCSI oocsi;
float count = 0;
int boos = 0;
int booCount = 0;

int spacing = 10;

String clientName = "irSensorGroup6";
String channelName = "GhostRoomChannel";

void setup () { 
  size(300, 300);
  colorMode(HSB, 100);
  surface.setResizable(true);
  
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
  count += 0.025;

  oocsi.channel( clientName ).data("hi", "cool").send();
}

// visualize
void draw() {
  if ( frameCount % 1 == 0 ) {
    background(0);
    
    noStroke();
    for (int y = 0; y < height && booCount < ( boos % int(( width / spacing ) * ( height / spacing ))); y += spacing) {
      for (int x = 0; x < width && booCount < ( boos % int(( width / spacing ) * ( height / spacing ))); x += spacing) {
        fill(x/3, 100, 100 - y/3  );
        rect(x, y, spacing, spacing );
        //println(booCount);
        booCount++;
      }
    }
    boos++;
    booCount = 0;
     
    noStroke();
    fill(100, 0, 100);
    ellipse(150 + 40 * sin( count / 80 ), (count/2 % (height + 40)) - 40, 20, 20);
  }
}