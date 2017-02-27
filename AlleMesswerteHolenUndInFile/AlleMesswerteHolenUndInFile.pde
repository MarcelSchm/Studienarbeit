  import processing.serial.*;
  import java.util.Locale;
  import g4p_controls.*;
  
 // GButton[] SerialPortsButton;
  
 // Serial myPort;      // The serial port
  int whichKey = -1;  // Variable to hold keystoke values
  double inByte = -1.0;    // Incoming serial data
  byte[] ziel = new byte[24];  //daten
  byte[] servo = new byte[4]; 
  byte[] gewicht = new byte[4]; 
  byte[] strom = new byte[4]; 
  byte[] beschleunigungX = new byte[4]; 
  byte[] beschleunigungY = new byte[4]; 
  byte[] beschleunigungZ = new byte[4]; 
 // PrintWriter output; // Data File
  boolean pressed = false; //maus gedrückt
  Table table; //objekt zum Tabellarisch speichern
  int messungNr = 0; //laufende ID der Messwerte
  int messwertNr = 0; // messwert Nr. der Sensoren z.B. 1=Waage, 2=Stromsensor
//  Table fahrprofil;
  int[] ESCWerte;
  int ESCLaufvariable = 0;
  int test = 0;
  boolean ESCsendNextValue = true; //ob ESC wert gesendet wurde, true für ersten wert
   boolean isButtonPressed = false; // warte auf COM-Port auswahl
 //  String portName; // Com-Port name
   String fahrprofilPath;
   
   /***********************UI-Globale Variablen*******************************/
   // Controls used for file dialog GUI 
GButton btnInput;
GLabel lblInputFile, titleInputFile;

//controls for COM-Port GUI
Serial myPort;      // The serial port
GLabel comPortTitle;
GLabel infoCOMPort;
GButton[] SerialPortsButton;
GButton testButton;
String portName;
Table fahrprofil;
PrintWriter output;
boolean isGUIReady = false;
/**************************************************************************/
  
  void setup() {
  size(560, 620);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);
  createCOMPortGUI(10, 30, 200, 20);
  // List all the available serial ports and wait for decision:
  //printArray(Serial.list());
 //SerialPortsButton = new GButton[Serial.list().length]; // make buttons for every Com-port
 //for( int i = 0; i < SerialPortsButton.length; i++){
  // SerialPortsButton[i] = new GButton(this,10,(i+1)*30,200,20); // buttons untereinander anordnen
  // SerialPortsButton[i].setText( Serial.list()[i]);
 //}



  // selectInput("Auswählen der Fahrprofil Datei: ", "fileSelected");
  //fahrprofil = loadTable(fahrprofilPath, "header");
  //ESCWerte = new int[fahrprofil.getRowCount()];
  // println(fahrprofil.getRowCount() + " total rows in fahrprofil");
  //for (TableRow row : fahrprofil.rows()) {
  //  //println(row.getString("ESC-Werte"));
  //  ESCWerte[ESCLaufvariable] = Integer.parseInt(row.getString("ESC-Werte"));
  //  ESCLaufvariable++;
  //}
  //println(" VAriable: " + ESCLaufvariable);
  //ESCLaufvariable = 0;
  
  // listet alle verfügbaren COM-Ports auf.
  // Im Geräte Manager schauen, welcher COM-Port der Arduino ist
  // und bei portName das entsprechende array element wählen
  //portName = Serial.list()[2]; // hier COM-Port ändern
  //myPort = new Serial(this, portName, 115200);
  //myPort.bufferUntil('e');
  //output = createWriter(year() + "_" + month() + "_" + day() + "___" + hour() + "-" + minute()+ "-"+ second()+ ".csv");
  //output.println("Messwert-Nr." + ";" + "ESC-Werte" + ";" + "Gewicht in g" + ";" + "Strom in A" + ";" + "Beschleunigung X-Richtung in g" + ";" + "Beschleunigung Y-Richtung in g" + ";" + "Beschleunigung Z-Richtung in g" );  //hier spalten ergänzen
  
  }
  
  void draw() { //<>//
  background(0);
  if ( isGUIReady == true) {
  text("Last Received: " + inByte, 100, 130); 
  text("Last Sent: " + whichKey, 100, 100);
  text("Messwerte: " + test, 100,10);

     myPort.write(ESCWerte[ESCLaufvariable]);
     
     if( ESCLaufvariable < (fahrprofil.getRowCount() - 1) && ESCsendNextValue == true){
     ESCLaufvariable++;
     ESCsendNextValue = false;
     
     }
  

  }
    
  }
  
  void serialEvent(Serial myPort) {
  try{
    ziel = myPort.readBytes();
 
    servo[0] = ziel[0];
    servo[1] = ziel[1];
    servo[2] = ziel[2];
    servo[3] = ziel[3];
    test++;
    //myPort.write(1);
    gewicht[0] = ziel[4];
    gewicht[1] = ziel[5];
    gewicht[2] = ziel[6];
    gewicht[3] = ziel[7];
    //myPort.write(2);
    strom[0] = ziel[8];
    strom[1] = ziel[9];
    strom[2] = ziel[10];
    strom[3] = ziel[11];
    //myPort.write(3);
    beschleunigungX[0] = ziel[12];
    beschleunigungX[1] = ziel[13];
    beschleunigungX[2] = ziel[14];
    beschleunigungX[3] = ziel[15];
    //myPort.write(4);
    beschleunigungY[0] = ziel[16];
    beschleunigungY[1] = ziel[17];
    beschleunigungY[2] = ziel[18];
    beschleunigungY[3] = ziel[19];
    //myPort.write(5);
    beschleunigungZ[0] = ziel[20];
    beschleunigungZ[1] = ziel[21];
    beschleunigungZ[2] = ziel[22];
    if(ziel[23] == 'e'){
      ziel[23] = '@';
    }
    beschleunigungZ[3] = ziel[23];
    
    ESCsendNextValue = true;
    inByte = umwandelnDouble(servo);
    output.print(messungNr + ";" + String.format(Locale.US, "%.2f",inByte)); //hier neue Messwerte hinzufügen
    inByte = umwandelnDouble(gewicht);
    output.print( ";" + String.format(Locale.US,"%.2f",inByte)); 
    inByte = umwandelnDouble(strom);
    output.print( ";" + String.format(Locale.US,"%.2f",inByte));
    inByte = umwandelnDouble(beschleunigungX);
    output.print( ";" + String.format(Locale.US,"%.2f",inByte));
    inByte = umwandelnDouble(beschleunigungY);
    output.print( ";" + String.format(Locale.US,"%.2f",inByte));
    inByte = umwandelnDouble(beschleunigungZ);
    output.println( ";" + String.format(Locale.US,"%.2f",inByte));
    messungNr++;
    

    //while( messwertNr <= 5) { //<>//
    //// inByte = myPort.read();
    //ziel=myPort.readBytes();
    //inByte = umwandelnDouble(ziel);
    //if(inByte == 123){
    ////myPort.write(ESCWerte[ESCLaufvariable]);
    //if(ESCLaufvariable < fahrprofil.getRowCount()){
    //ESCLaufvariable++;
    //}
    //}
    //if( messwertNr == 0){
    //output.print(messungNr + ";" + String.format(Locale.US, "%.2f",inByte)); //hier neue Messwerte hinzufügen
    //myPort.write(1);
    //} else {
    //output.println( ";" + String.format(Locale.US,"%.2f",inByte)); //hier neue Messwerte hinzufügen
    //myPort.write(messwertNr + 1);
    
    //}
    
    //messwertNr++;
    //}
    //if(messwertNr > 5){
    //     // output.println(); //hier neue Messwerte hinzufügen
    //            ESCsendNextValue = true;
    //messwertNr = 0;
    //messungNr++;
  }
//}
  catch(RuntimeException e) {
    e.printStackTrace(); //<>//
    e.getCause();
  }
  
  }
  
  void keyPressed() {
  // Send the keystroke out:
  myPort.write(key);
  whichKey = key;
  }
  
  void fileSelected(File selection){
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fahrprofilPath = selection.getAbsolutePath();
  }
  }
  
  double umwandelnDouble(byte array[]) {
  if('@'==(array[3])){
   int vorkomma = ((array[0] & 0x0F ) << 8) | (array[1] & 0xFF) ;
   //print("test ");
   //println(binary( ((array[0]&0x0F)<< 8) | (array[1]&0xFF)));
   int nachkomma = (array[2]) ;
  
          if( 2 == (array[0]&0xF0)>>4){
              return -1.0*((double)vorkomma + (double)nachkomma / 100.0);
  }
  return (double)vorkomma + (double)nachkomma / 100.0;
  }
  else return -1;// magic error number, if something doesnt work
  
  }
  
  //void handleButtonEvents(GButton button, GEvent event){
  //  for(GButton buttonCounter : SerialPortsButton){
  //    if(buttonCounter == button){
  //    buttonCounter.getText();
  //    }
  //  }
  //isButtonPressed =true;
  //}
  
  //void mousePressed(){
  //if(pressed==false){
  //pressed=true;
  //return;
  //}
  //else{
  //output.flush();
  //output.close();
  //exit();
  //}
  //}
  
 /******************************UI-kopie**********************************************/
 public void handleButtonEvents(GButton button, GEvent event) { 
  boolean isComPortSelected = false;
  //COM-Port selection
  if (button == testButton) {
    comPortTitle.setText("gewählter COM-port: " + "NA");
    portName = testButton.getText();
    comPortTitle.setTextBold();
    comPortTitle.setLocalColorScheme(G4P.GREEN_SCHEME);
    isComPortSelected = true;
    infoCOMPort.dispose();
  }  
  for (GButton buttonCounter : SerialPortsButton) {
    if (buttonCounter == button) {
      comPortTitle.setText("gewählter COM-port: " + buttonCounter.getText());
      portName = buttonCounter.getText();
      comPortTitle.setTextBold();
      comPortTitle.setLocalColorScheme(G4P.GREEN_SCHEME);
      isComPortSelected = true;
      myPort = new Serial(this, portName, 115200);
      myPort.bufferUntil('e');
    }
  }
  if ( isComPortSelected == true) {
    for (GButton buttonCounter : SerialPortsButton) {
      buttonCounter.dispose();
    }
    if(testButton != null){
     testButton.dispose();     
    }

    createFileSystemGUI(10, 60, 300);
  }
  // Folder selection
  if (button == btnInput) {
    handleFileDialog(button);
  }
}  

// G4P code for folder and file dialogs
public void handleFileDialog(GButton button) {
  String fname;
  // File input selection
  if (button == btnInput) {
    // Use file filter if possible
    // selectInput("Wähle","test");
    fname = G4P.selectInput("wählen des Fahrprofils als csv datei", "csv", "Table");
    if (fname == null) {
      lblInputFile.setText("Abbruch durch Benutzer. Bitte erneut ein Fahrprofil im CSV Format wählen");
      lblInputFile.setLocalColorScheme(G4P.RED_SCHEME);
    } else {
      if (fname.contains(".csv") == true) {  
        lblInputFile.setText(fname);
        titleInputFile.setText("Fahrprofil gewählt: ");
        titleInputFile.setTextBold();
        btnInput.dispose();
        lblInputFile.moveTo(btnInput.getX(), btnInput.getY(), GControlMode.CORNER);
        lblInputFile.setLocalColorScheme(G4P.GREEN_SCHEME);
        titleInputFile.setLocalColorScheme(G4P.GREEN_SCHEME);
        // open File 
        fahrprofil = loadTable(fname, "header");
        String outputPath = year() + "_" + month() + "_" + day() + "___" + hour() + "-" + minute()+ "-"+ second()+ ".csv";
        output = createWriter(outputPath);
        output.println("Messwert-Nr." + ";" + "ESC-Werte" + ";" + "Gewicht in g" + ";" + "Strom in A" + ";" + "Beschleunigung X-Richtung in g" + ";" + "Beschleunigung Y-Richtung in g" + ";" + "Beschleunigung Z-Richtung in g" );  //hier spalten ergänzen
       
        GLabel titleOutputFile = new GLabel(this, titleInputFile.getX(), lblInputFile.getY() + lblInputFile.getHeight() + 10, titleInputFile.getWidth(),titleInputFile.getHeight());
        GLabel lblOutputFile = new GLabel(this, lblInputFile.getX(), titleOutputFile.getY() + titleOutputFile.getHeight() + 10, lblInputFile.getWidth(),lblInputFile.getHeight() + 50 );
        titleOutputFile.setText("Name und Pfad der Ausgabedatei: ", GAlign.LEFT, GAlign.MIDDLE);
        titleOutputFile.setOpaque(true);
        titleOutputFile.setTextBold();
        lblOutputFile.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
        lblOutputFile.setText(sketchPath("") + "\n\n" + outputPath);
        lblOutputFile.setOpaque(true);
        ESCWerte = new int[fahrprofil.getRowCount()];
   println(fahrprofil.getRowCount() + " total rows in fahrprofil");
  for (TableRow row : fahrprofil.rows()) {
    //println(row.getString("ESC-Werte"));
    ESCWerte[ESCLaufvariable] = Integer.parseInt(row.getString("ESC-Werte"));
    ESCLaufvariable++;
  }
  println(" VAriable: " + ESCLaufvariable);
  ESCLaufvariable = 0;
        isGUIReady = true;
        //output.flush();
        //output.close();
        
      } else {
        lblInputFile.setText("Es liegt kein passendes Dateiformat vor. Bitte eine CSV-Datei wählen");
        lblInputFile.setLocalColorScheme(G4P.RED_SCHEME);
      }
    }
  }
}

public void createFileSystemGUI(int x, int y, int w) {
  titleInputFile = new GLabel(this, x, y, w, 20);
  titleInputFile.setText("Bitte Fahrprofil (CSV-Datei) wählen", GAlign.LEFT, GAlign.MIDDLE);
  titleInputFile.setOpaque(true);
  titleInputFile.setTextBold();
  // Create buttons
  int bgap = 8;
  int bw = round((w - 2 * bgap) / 3.0f);
  btnInput = new GButton(this, x, y+30, bw, 20, "Input");
  lblInputFile = new GLabel(this, x, y+60, w, 60);
  lblInputFile.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  lblInputFile.setText("Noch kein Fahrprofil ausgewählt");
  lblInputFile.setOpaque(true);
  lblInputFile.setLocalColorScheme(G4P.BLUE_SCHEME);
}

public void createCOMPortGUI(int x, int y, int w, int h) {
  comPortTitle = new GLabel(this, x, y, w, 20);
  comPortTitle.setText("Bitte COM-Port wählen", GAlign.LEFT, GAlign.MIDDLE);
  comPortTitle.setOpaque(true);
  comPortTitle.setTextBold();
  printArray(Serial.list());
  if (Serial.list().length == 0) {  // no Com-Port connected
    infoCOMPort = new GLabel(this, x, y + 30, w, 3*h);
    infoCOMPort.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    infoCOMPort.setText("keine COM-Ports zur Auswahl vorhanden. Bitte Anschluss überprüfen und Programm neu starten");
    infoCOMPort.setOpaque(true);
    infoCOMPort.setLocalColorScheme(G4P.RED_SCHEME);
    testButton = new GButton(this, x, y + 100, w, h);
    testButton.setText("testen ohne COM-Port");
  }
  SerialPortsButton = new GButton[Serial.list().length]; // make buttons for every Com-port
  for ( int i = 0; i < SerialPortsButton.length; i++) {
    SerialPortsButton[i] = new GButton(this, x, (i+1)*y + 30, w, h); // buttons untereinander anordnen
    SerialPortsButton[i].setText( Serial.list()[i]);
  }
}
/*****************************************************************************/