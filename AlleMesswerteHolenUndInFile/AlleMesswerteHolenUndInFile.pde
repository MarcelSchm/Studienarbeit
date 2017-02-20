  import processing.serial.*;
  import java.util.Locale;
  
  Serial myPort;      // The serial port
  int whichKey = -1;  // Variable to hold keystoke values
  double inByte = -1.0;    // Incoming serial data
  byte[] ziel = new byte[24];  //daten
  byte[] servo = new byte[4]; 
  byte[] gewicht = new byte[4]; 
  byte[] strom = new byte[4]; 
  byte[] beschleunigungX = new byte[4]; 
  byte[] beschleunigungY = new byte[4]; 
  byte[] beschleunigungZ = new byte[4]; 
  PrintWriter output; // Data File
  boolean pressed = false; //maus gedrückt
  Table table; //objekt zum Tabellarisch speichern
  int messungNr = 0; //laufende ID der Messwerte
  int messwertNr = 0; // messwert Nr. der Sensoren z.B. 1=Waage, 2=Stromsensor
  Table fahrprofil;
  int[] ESCWerte;
  int ESCLaufvariable = 0;
  
  
  void setup() {
  size(400, 300);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);
  
  // List all the available serial ports:
  printArray(Serial.list());
  
  fahrprofil = loadTable("C:/Users/User/Dropbox/Scripte/7. Semester/Studienarbeit/Arduino Code" + "/Rampe.csv", "header");
  ESCWerte = new int[fahrprofil.getRowCount()];
   println(fahrprofil.getRowCount() + " total rows in fahrprofil");
  for (TableRow row : fahrprofil.rows()) {
    //println(row.getString("ESC-Werte"));
    ESCWerte[ESCLaufvariable] = Integer.parseInt(row.getString("ESC-Werte"));
    ESCLaufvariable++;
  }
  
  // listet alle verfügbaren COM-Ports auf.
  // Im Geräte Manager schauen, welcher COM-Port der Arduino ist
  // und bei portName das entsprechende array element wählen
  String portName = Serial.list()[2]; // hier COM-Port ändern
  myPort = new Serial(this, portName, 9600);
  myPort.buffer(24);
  output = createWriter(year() + "_" + month() + "_" + day() + "___" + hour() + "-" + minute()+ "-"+ second()+ ".csv");
  output.println("Messwert-Nr." + ";" + "ESC-Werte" + ";" + "Gewicht in g" + ";" + "Strom in A" + ";" + "Beschleunigung X-Richtung in g" + ";" + "Beschleunigung Y-Richtung in g" + ";" + "Beschleunigung Z-Richtung in g" );  //hier spalten ergänzen
  
  }
  
  void draw() {
  background(0);
  text("Last Received: " + inByte, 10, 130); //<>//
  text("Last Sent: " + whichKey, 10, 100);
  }
  
  void serialEvent(Serial myPort) {
  try{
    ziel = myPort.readBytes();
    servo[0] = ziel[0];
    servo[1] = ziel[1];
    servo[2] = ziel[2];
    servo[3] = ziel[3];
    gewicht[0] = ziel[4];
    gewicht[1] = ziel[5];
    gewicht[2] = ziel[6];
    gewicht[3] = ziel[7];
    strom[0] = ziel[8];
    strom[1] = ziel[9];
    strom[2] = ziel[10];
    strom[3] = ziel[11];
    beschleunigungX[0] = ziel[12];
    beschleunigungX[1] = ziel[13];
    beschleunigungX[2] = ziel[14];
    beschleunigungX[3] = ziel[15];
    beschleunigungY[0] = ziel[16];
    beschleunigungY[1] = ziel[17];
    beschleunigungY[2] = ziel[18];
    beschleunigungY[3] = ziel[19];
    beschleunigungZ[0] = ziel[20];
    beschleunigungZ[1] = ziel[21];
    beschleunigungZ[2] = ziel[22];
    beschleunigungZ[3] = ziel[23];
    inByte = umwandelnDouble(servo);
    output.println(messungNr + ";" + String.format(Locale.US, "%.2f",inByte)); //hier neue Messwerte hinzufügen
    inByte = umwandelnDouble(gewicht);
    output.println( ";" + String.format(Locale.US,"%.2f",inByte)); 
    inByte = umwandelnDouble(strom);
    output.println( ";" + String.format(Locale.US,"%.2f",inByte));
    inByte = umwandelnDouble(beschleunigungX);
    output.println( ";" + String.format(Locale.US,"%.2f",inByte));
    inByte = umwandelnDouble(beschleunigungY);
    output.println( ";" + String.format(Locale.US,"%.2f",inByte));
    inByte = umwandelnDouble(beschleunigungZ);
    output.println( ";" + String.format(Locale.US,"%.2f",inByte));
    //while( messwertNr <= 5){
    //// inByte = myPort.read();
    //ziel=myPort.readBytes();
    //inByte = umwandelnDouble(ziel);
    //if(true){
    //if( messwertNr == 0){
    //output.println(messungNr + ";" + String.format(Locale.US, "%.2f",inByte)); //hier neue Messwerte hinzufügen
    //} else {
    //output.println( ";" + String.format(Locale.US,"%.2f",inByte)); //hier neue Messwerte hinzufügen
    //}
    //}
    //messwertNr++;
    //}
    //if(messwertNr > 5){
    //messwertNr = 0;
    //messungNr++;
  }
//    }
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
  else return 180394.11;// magic error number, if something doesnt work
  
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