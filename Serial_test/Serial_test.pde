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
double inByte = -1.0;    // Incoming serial data
String test=new String("shit");
PrintWriter output; //Data File
boolean pressed=false;
byte[] uebertragen=new byte[5];//erwartete anzahl
void setup() {
  size(700, 300);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 27);
  textFont(myFont);

  // List all the available serial ports:
  printArray(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // In Windows, this usually opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[2];
  myPort = new Serial(this, portName, 9600);
  output= createWriter("Gewicht.txt");
}

void draw() {
  background(0);
  text("Last Received(int): " + inByte, 10, 130);
  text("Last Received(String): " + test, 10, 160);
//}

//void serialEvent(Serial myPort) {
 if(myPort.available()>0){//daten vorhanden
 text("empfangen",40,100);
  uebertragen = myPort.readBytes();
  myPort.readBytes(uebertragen);
  inByte=umwandelnDouble(uebertragen);
//uebertragen=myPort.readBytes();

 // output.println(inByte);
 }
}

void keyPressed() {
  // Send the keystroke out:
output.flush();
output.close();
exit();
}
void mousePressed(){
  if(pressed==false){
  pressed=true;
  return;
}
  else{
  keyPressed();
  }
}

double umwandelnDouble(byte array[]) {
  if('@'==(array[0] & 0xF0)){
   int vorkomma = ((array[0] & 0x0F ) << 8) | (array[1]) ;
   int nachkomma = (array[2]) ;
  return (double)vorkomma + (double)nachkomma / 100;
  }
  
  else{
  inByte=-9.0;
  return inByte;
  }

}