/**  
 *  DBSU10 IR sensor module
 *  @author Tom van Roozendaal, group 6
 *  @version 1.5
 *  @since 22/02/2018
 */
import processing.serial.*;
import cc.arduino.*;
import nl.tue.id.oocsi.*;

// arduino
Arduino arduino;
int[] irPins = { 2, 3, 4 }; // GPIO port numbers of the IR sensor components on arduino
int ledPin = 13; // GPIO port number of the led pin ( 13 = default )

// oocsi
OOCSI oocsi;

// customizable variables
int pinAmount = irPins.length;
String channelName;
boolean stick = false;
int delay = 1000; // delay for a sensor to be seeing before it gets triggered in ms
boolean respondOnTrigger = true;
boolean responded = false;
boolean linkedChannel = false;

// timer/trigger related arrays
int[] timers = new int[3];
boolean[] started = {false, false, false};
boolean[] triggers = {false, false, false};

void setup() {
  size(300, 100);
  strokeWeight( 2 );
  stroke( 255 );
  colorMode( HSB, 100 );

  println( Arduino.list() ); // to find the Arduino serial # needed to create the object
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  for ( int i = 0; i < irPins.length; i++ ) {
    arduino.pinMode(irPins[i], Arduino.INPUT); // setting the pin mode of irPin
  }
  arduino.pinMode( ledPin, Arduino.OUTPUT );

  oocsi = new OOCSI(this, "irModule6", "oocsi.id.tue.nl"); // localhost/host
  // register for responses to API calls
  oocsi.register("setIR6", "setValues");
  oocsi.register("getIR6", "getValues");
  println();
}

void draw() {
  background( 0, 0, 100 );

  for (int i = 0; i < pinAmount; i++) {
    if ( triggers[i] && stick) {
      fill(60, 100, 100);
    } else if ( arduino.digitalRead( irPins[i] ) != 1 ) {
      if ( delay > 0 && !triggers[i]) {
        // if started is false, reset the timer
        if (!started[i]) {
          timers[i] = millis() + delay;
        }
        started[i] = true;
        fill(60, 50, 100);
        if (timers[i] - millis() < 0) {
          triggers[i] = true;
          println("sensor " + (i+1) + " triggered!" );
          if (respondOnTrigger && linkedChannel) {
            oocsi.channel(channelName).data("IR6sensor", (i+1));
            println("data sent to " + channelName);
          }
        }
      } else {
        //println("sensor " + (i+1) + " triggered!" );
        if (respondOnTrigger && linkedChannel && !responded) {
          oocsi.channel(channelName).data("IR6sensor", (i+1));
          responded = true;
        }
        fill(60, 100, 100);
      }
    } else {
      if ( delay > 0 ) {
        started[i] = false;
      }
      triggers[i] = false;
      fill(60, 0, 75);
    }

    //println( arduino.digitalRead( irPins[i] ) );
    rect( (i) * width/irPins.length, 0, width/irPins.length - 1, 100 - 2);
  }
}

// ---------------- OOCSI EVENT HANDLERS ----------------

// retreiving messages from the channel
public void testchannel(OOCSIEvent event) {
  System.out.println( event.getTimestamp() );
}
// sending messages over the channel
public void sendData() {
  if ( channelName != null && !channelName.isEmpty() ) {
    oocsi.channel( channelName ).data( "irSensor", 100).send(); // send message over the channel
  }
}

// ---------------- API METHODS ----------------

// how to use these calls: oocsi.call("set/get", ms).data("value", val);
// configurates the module, responses with true as feedback
void setValues(OOCSIEvent event, OOCSIData response) {
  if (event.has("pinAmount")) {
    pinAmount =  Math.max( event.getInt("pinAmount", 0), irPins.length );
    response.data("pinAmountChanged", true);
    clearTriggers();
  }
  if (event.has("channelName")) {
    channelName = event.getString("channelName");
    //oocsi.subscribe( channelName, "testchannel" ); // connect to desired channel
    linkedChannel = true; // module is subscribed to a channel
    response.data("channelNameChanged", true);
    println("Module will send data over to "+ channelName);
  }
  if (event.has("delay")) {
    delay = event.getInt("delay", 1000);
    clearTriggers();
    response.data("delayChanged", true);
  }
  if (event.has("respondOnTrigger")) {
    respondOnTrigger = event.getBoolean("respondOnTrigger", true);
    response.data("respondOnTriggerChanged", true);
  }
  if (event.has("stick")) {
    stick = event.getBoolean("stick", false);
    response.data("stickChanged", true);
  }
  if (event.has("clear")) {
    int index = event.getInt("clear", 0) - 1;
    if ( index > -1 && index < pinAmount) {
      triggers[index] = false; // clear the trigger at that index
      response.data("TriggerCleared", index + 1);
    } else {
      clearTriggers(); // clear all triggers
      response.data("TriggerCleared", 0);
    }
  }
  if (event.has("reset")) {
    pinAmount = irPins.length;
    channelName = "";
    stick = false;
    delay = 1000;
    respondOnTrigger = true;
    responded = false;
    linkedChannel = false;
  }
}

// gets values from the module
void getValues(OOCSIEvent event, OOCSIData response) {
  // responses with amount of sensor values that are triggered at that moment
  // type: boolean
  if (event.has("triggered")) {
    response.data("triggered", triggers );
    println("triggers sent");
  }
  // returns all custom global variables
  if (event.has("setup")) {
    response.data("pinAmount", pinAmount)
      .data("channelName", channelName)
      .data("delay", delay)
      .data("stick", stick);
  }
}

// ---------------- STANDARD METHODS ----------------

// clears the triggers value
void clearTriggers() {
  for (int i = 0; i < triggers.length; i++) {
    triggers[i] = false;
  }
}
