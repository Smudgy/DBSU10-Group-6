/**  
*  DBSU10 IR sensor module
*  @author Tom van Roozendaal, group 6
*  @version 1.2
*  @since 22/02/2018
*/
import processing.serial.*;
import cc.arduino.*;
import nl.tue.id.oocsi.*;

// arduino
Arduino arduino;
int[] irPins = { 2 }; // GPIO port numbers of the IR sensor components on arduino
int ledPin = 13; // GPIO port number of the led pin ( 13 = default )

// oocsi
OOCSI oocsi;

// customizable variables
int pinAmount = irPins.length;
String channelName = "ghostroom";
int threshold = 512; // Arduino outputs range from 0 to 1024

void setup() {
  size(300 ,100);
  noStroke();
  
  println( Arduino.list() ); // to find the Arduino serial # needed to create the object, usually its the first element
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  for (int i = 0; i < irPins.length; i++){
    arduino.pinMode(irPins[i], Arduino.INPUT); // setting the pin mode of irPin
  }

  arduino.pinMode( ledPin, Arduino.OUTPUT );

  oocsi = new OOCSI(this, "irModule6", "oocsi.id.tue.nl"); // localhost/host
  oocsi.subscribe( channelName, "testchannel" ); // connect to desired channel
  
  // register for responses to calls
  oocsi.register("settings", "config");
}

void draw() {
  background(255);
  
  for (int i = 0; i < pinAmount - 1; i++){      
    if (arduino.analogRead( irPins[i] ) > threshold) {
      fill(255, 150, 150);
      oocsi.channel( channelName ).data( "irSensor", 100).send(); // send message over the channel
      arduino.digitalWrite( ledPin, Arduino.HIGH );
    } else {
      fill(200, 200, 200);
      arduino.digitalWrite( ledPin, Arduino.LOW );
    }
    
    rect( i * 100, 0, width/irPins.length, 100);
  }
}

// retreiving messages from the OOCSI server, however, our module is more interested into sending messages
public void testchannel(OOCSIEvent event) {
  System.out.println( event.getTimestamp() );
}

// ---------------- API METHODS ----------------

// configurates the module, responses with true as feedback
void config(OOCSIEvent event, OOCSIData response){
  if (event.has("pinAmount")) {
    pinAmount =  Math.max( event.getInt("pinAmount", 0), 3);
    response.data("pinAmountChanged", true);
  }
  if (event.has("threshold")) {
    threshold = Math.max( event.getInt("threshold", 0), 1024 );
    response.data("thresholdChanged", true);
  }
  if (event.has("channelName")) {
    channelName = event.getString("channelName");
    response.data("channelNameChanged", true);
  }
}

// returns array with sensor values
// parameters: -
int[] getValues() {
  int[] irVals = new int[ irPins.length ];
  for (int i = 0; i < pinAmount - 1; i++){
    irVals[i] = arduino.analogRead( irPins[i] );
  }
  return ( irVals );
}

// returns amount of sensor values above the threshold ( = "triggered" )
// parameters: int treshold ( 0 - 1024 )
int getTriggered( int threshold ) {
  int count = 0;
  int[] irVals = getValues();
  
  for (int i = 0; i < irVals.length; i++){
    if ( irVals[i] > threshold ){
      count++;
    }
  }
  return ( count );
}

// returns boolean. true if all sensors are triggered
// parameters: int treshold ( 0 - 1024 )
boolean allTriggered( int threshold ) { 
  return ( pinAmount == getTriggered( int threshold ) );
}