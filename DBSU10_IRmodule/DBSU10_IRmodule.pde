/**  
*  DBSU10 IR sensor module
*  @author Tom van Roozendaal, group 6
*  @version 1.0
*  @since 22/02/2018
*/
import processing.serial.*;
import cc.arduino.*;
import nl.tue.id.oocsi.*;

// arduino
Arduino arduino;
int irPin; // pin # of the IR sensor component
float treshold = 1.5; // e.g. trigger within 1.5 meters
// the rest of the code assumes that the sensor will give an output already within our desired range,
// hence the treshold isn't used. If this isn't the case, we can easily program this in.

// oocsi
OOCSI oocsi;
String channelName = "ghostroom";

// visualisation
int fillRed = 255;

void setup() {
  size(200,200);
  noStroke();

  println( Arduino.list() );
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(irPin, Arduino.OUTPUT);

  oocsi = new OOCSI(this, "irModule6", "localhost"); // localhost/host
  oocsi.subscribe( channelName, "testchannel" ); // connect to desired channel
}

void draw() {
  background(255);
  // relevant values are either ON or OFF
  if (arduino.digitalRead( irPin ) == Arduino.HIGH) {
      fillRed = 255;
      oocsi.channel( channelName ).data( "irSensor", 100).send(); // send message over the channel
  } else {
      fillRed = 120;
  }
  // visualize sensor output
  fill(fillRed, 120, 120);
  ellipse(100, 100, 100, 100);
}

// retreiving messages from the OOCSI server, however, our module is more interested into sending messages
public void testchannel(OOCSIEvent event) {
  System.out.println(event.getTimestamp());
}