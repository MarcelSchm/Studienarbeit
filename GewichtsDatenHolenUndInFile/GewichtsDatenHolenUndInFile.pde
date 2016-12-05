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

  // listet alle verfügbaren COM-Ports auf.
  // Im Geräte Manager schauen, welcher COM-Port der Arduino ist
  // und bei portName das entsprechende array element wählen
  String portName = Serial.list()[1]; // hier COM-Port ändern
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('@');
  output = createWriter(year() + "_" + month() + "_" + day() + "___" + hour() + "-" + minute()+ "-"+ second()+ ".txt");
  output.println("Messwert-Nr." + ";" + "Gewicht in g" );  //hier spalten ergänzen
  
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
  output.println(messwertNr + ";" + String.format("%.2f",inByte)); //hier neue Messwerte hinzufügen
  messwertNr++;
  }
  catch(RuntimeException e) {
    e.printStackTrace(); //<>//
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
else return 180394.11;// magic error number

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