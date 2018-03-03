/**  
*  DBSU10 IR sensor module
*  @author Tom van Roozendaal, group 6
*  @version 1.1
*  @since 22/02/2018
*/
import processing.serial.*;
import cc.arduino.*;
import nl.tue.id.oocsi.*;

// arduino
Arduino arduino;
Serial serial;
// GPIO port numbers of the IR sensor components on arduino
int[] irPins = {2};

int ledPin = 4; // GPIO port number of the led pin
int buttonPin = 2; // GPIO port number of the button pin
float treshold = 1.5; // e.g. trigger within 1.5 meters
// the rest of the code assumes that the sensor will give an output already within our desired range,
// hence the treshold isn't used. If this isn't the case, we can easily program this in.

// oocsi
OOCSI oocsi;

// customizable variables
int pinAmount = irPins.length;
String channelName = "ghostroom";

void setup() {
  
  size(300 ,100);
  noStroke();
  
  println( Arduino.list() ); // to find the Arduino serial # needed to create the object, usually its the first element
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  //for (int i = 0; i < irPins.length; i++){
  //  arduino.pinMode(irPins[i], Arduino.OUTPUT); // setting the pin mode of irPin
  //}

  arduino.pinMode( ledPin, Arduino.OUTPUT );
  arduino.pinMode( buttonPin, Arduino.INPUT );

  oocsi = new OOCSI(this, "irModule6", "oocsi.id.tue.nl"); // localhost/host
  oocsi.subscribe( channelName, "testchannel" ); // connect to desired channel
}

void draw() {
  background(255);
  // relevant values are either ON or OFF
  for (int i = 0; i < irPins.length; i++){      
    if (arduino.analogRead( irPins[i] ) > 512) {
      fill(255, 150, 150);
      oocsi.channel( channelName ).data( "irSensor", 100).send(); // send message over the channel
      arduino.digitalWrite( ledPin, Arduino.HIGH );
    } else {
      fill(200, 200, 200);
      arduino.digitalWrite( ledPin, Arduino.LOW );
    }
    rect( i * 100, 0, width/irPins.length, 100);
  }
  
  println( arduino.analogRead( buttonPin ) );
}

// retreiving messages from the OOCSI server, however, our module is more interested into sending messages
public void testchannel(OOCSIEvent event) {
  System.out.println( event.getTimestamp() );
}

// ---------------- API METHODS ----------------

// sets the amount of active sensors
void setPins( int amount ) {
  pinAmount = Math.max( amount, 3 );
}

// sets the OOCSI channel name
void setChannel( String str ) {
  channelName = str; 
}

// returns array with sensor values
// parameters: -
int[] getValues() {
  int[] irVals = new int[ irPins.length ];
  for (int i = 0; i < irPins.length; i++){
    irVals[i] = arduino.analogRead( irPins[i] );
  }
  
  return ( irVals );
}

// returns amount of sensor values above the treshold ( = triggered )
// parameters: int treshold ( 0 - 1024 )
int getTriggered( int treshold ) {
  int count = 0;
  int[] irVals = getValues();
  
  for (int i = 0; i < irPins.length; i++){
    if ( irVals[i] > treshold ){
      count++;
    }
  }
  return ( count );
}

// returns boolean. true if all sensors are triggered
// parameters: int treshold ( 0 - 1024 )
boolean allTriggered( int treshold ) { 
  return ( irPins.length == getTriggered( int treshold ) );
}