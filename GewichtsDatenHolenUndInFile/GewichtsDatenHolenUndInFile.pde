/**
 * Serial Duplex 
 * by Tom Igoe. 
 * 
 * Sends a byte out the serial port when you type a key
 * listens for bytes received, and displays their value. 
 * This is just a quick application for testing serial data
 * in both directions. 
 */


import processing.serial.*;

Serial myPort;      // The serial port
int whichKey = -1;  // Variable to hold keystoke values
double inByte = -1.0;    // Incoming serial data
byte[] ziel = new byte[4];  //gewichtsdaten
PrintWriter output; // Data File
boolean pressed = false; //maus gedrückt
Table table; //objekt zum Tabellarisch speichern
int messwertNr = 0; //ID des Messwertes

void setup() {
  size(400, 300);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);

  // List all the available serial ports:
  printArray(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // In Windows, this usually opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('@');
  output = createWriter("Gewicht.csv");
  output.println("Messwert-Nr." + ";" + "Gewicht in g" );
  
}

void draw() {
  background(0);
  text("Last Received: " + inByte, 10, 130); //<>//
  text("Last Sent: " + whichKey, 10, 100);
}

void serialEvent(Serial myPort) {
  try{
 // inByte = myPort.read();
  ziel=myPort.readBytes();
  inByte = umwandelnDouble(ziel );
  output.println(messwertNr + ";" + inByte);
  messwertNr++;
  //printArray(ziel);
  //print("array[0] ");
  //println(binary(ziel[0]));
  //  println("array[1] ");
  // println(binary(ziel[1]));
  //     println("array[2] ");
  //  println(binary(ziel[2]));
  //      println("array[3] ");
  //   println(binary(ziel[3]));
  }
  catch(RuntimeException e) {
    e.printStackTrace();
  }
  
}

void keyPressed() {
  // Send the keystroke out:
  myPort.write(key);
  whichKey = key;
}

double umwandelnDouble(byte array[]) {
  if('@'==(array[3])){
   int vorkomma = ((array[0] & 0x0F ) << 8) | (array[1] & 0xFF) ;
   print("test ");
   println(binary( ((array[0]&0x0F)<< 8) | (array[1]&0xFF)));
   int nachkomma = (array[2]) ;

          if( 2 == (array[0]&0xF0)>>4){
              return -1.0*((double)vorkomma + (double)nachkomma / 100.0);
}
  return (double)vorkomma + (double)nachkomma / 100.0;
  }
else return 180394.11;

}

void mousePressed(){
  if(pressed==false){
  pressed=true;
  return;
}
  else{
  output.flush();
  output.close();
  exit();
  }
}