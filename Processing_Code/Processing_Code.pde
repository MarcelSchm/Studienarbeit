import processing.serial.*; //  //<>//
import java.util.Locale;
import g4p_controls.*;
/******************Global Values Declaration******************************/
byte[] ziel = new byte[29];  //daten
byte[] servo = new byte[4]; 
byte[] zeit = new byte[5];
byte[] gewicht = new byte[4]; 
byte[] strom = new byte[4]; 
byte[] beschleunigungX = new byte[4]; 
byte[] beschleunigungY = new byte[4]; 
byte[] beschleunigungZ = new byte[4]; 
Table table; //object to save measured data tabulary
int messungNr = 0; //ongoing ID of measured data
int[] ESCWerte; //array for the values of the driving profile
int ESCLaufvariable = 0;
int messwertCounter = 0;
boolean ESCsendNextValue = true; //to validate the sending of the ESC value, true for the first value(serial event check)
boolean isButtonPressed = false; // wait for COM-Port selection
boolean StopAndStore = false, emergencyShutdown = false;
//  String portName; // Com-Port name
String fahrprofilPath;
boolean OnetimeRun = false, startLogging = false, stopLogging = false;
double lastMillis = 0.0;
/**************************************************************************/

/***********************UI-Global Values***********************************/
// Controls used for file dialog GUI 
GButton btnInput;
GLabel lblInputFile, titleInputFile, titleOutputFile, lblOutputFile, progress;

//controls for COM-Port GUI
Serial myPort;      // The serial port
GLabel comPortTitle;
GLabel infoCOMPort;
GButton[] SerialPortsButton;


//other
String portName;
Table fahrprofil;
PrintWriter output;
boolean isGUIReady = false, startprgm = false;
String fname;//string for file name(fahrprofil)
GButton btnEnd, btnStart, btnEmergency;
int counterForProgressLabel =0, counterForStopAndStore = 0; // necesssary because statements are executed after one iteration of GUI
/**************************************************************************/

void setup() {
  size(560, 620);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);
  createCOMPortGUI(10, 30, 200, 20);
}

void draw() { 
  background(0);
  lastMillis = millis();
  if ( isGUIReady == true) {
    if ( ESCLaufvariable >= (ESCWerte.length - 1) ) {
      lblOutputFile.setLocalColorScheme(G4P.GREEN_SCHEME);
      titleOutputFile.setLocalColorScheme(G4P.GREEN_SCHEME);
      progress.setText("Messung beendet und abgespeichert");
      if ( OnetimeRun == false ) {
        myPort.write(0);

        output.flush();
        output.close();
        btnEnd.dispose();
        btnEmergency.dispose();
        myPort.write(0);
        OnetimeRun = true;
      }
      if ( 0 == progress.getText().compareTo("Messung beendet und abgespeichert") ) { // necessary, Infomessage pops up before progress bar draw
        counterForProgressLabel++;
        if (counterForProgressLabel == 2) { // need 2 loops to update before showing Infomessage
          G4P.showMessage(this, "Die Messung wurde erfolgreich beendet", "Messung beendet", G4P.INFO);
        }
      }
    }
    if ( StopAndStore == true || emergencyShutdown == true || ( ESCLaufvariable > (ESCWerte.length - 1)) ) {
      myPort.write(0);
      myPort.write(0);
      myPort.write(0); // three times to be sure that next values in buffer are zeros
      delay(20); //wait for motor to stop
      counterForStopAndStore++;
      lblOutputFile.setLocalColorScheme(G4P.YELLOW_SCHEME);
      titleOutputFile.setLocalColorScheme(G4P.YELLOW_SCHEME);
      progress.setText("Messung vorzeitig beendet");
      if ( counterForStopAndStore == 2) { // need 2 loops to update before showing Infomessage

        stopAndStore();
      }
    } else if ( ESCLaufvariable < (ESCWerte.length - 1)) {
      myPort.write(ESCWerte[ESCLaufvariable]);
      if ( ESCLaufvariable < (ESCWerte.length - 1) && ESCsendNextValue == true) {
        ESCLaufvariable++;
        messwertCounter++;
        ESCsendNextValue = false;
      }
    }
  }
}

void serialEvent(Serial myPort) {
  try { // try-catch-block for potential transmission errors
    if (StopAndStore == false) {
      ziel = myPort.readBytes();
      lastMillis = millis() - lastMillis;
      //println(" Zeitabstand : " + lastMillis); //if you want to get time between 2 serial events
      servo[0] = ziel[0];
      servo[1] = ziel[1];
      servo[2] = ziel[2];
      servo[3] = ziel[3];
      zeit[0] = ziel[4];
      zeit[1] = ziel[5];
      zeit[2] = ziel[6];
      zeit[3] = ziel[7];
      zeit[4] = ziel[8];
      gewicht[0] = ziel[9];
      gewicht[1] = ziel[10];
      gewicht[2] = ziel[11];
      gewicht[3] = ziel[12];
      strom[0] = ziel[13];
      strom[1] = ziel[14];
      strom[2] = ziel[15];
      strom[3] = ziel[16];
      beschleunigungX[0] = ziel[17];
      beschleunigungX[1] = ziel[18];
      beschleunigungX[2] = ziel[19];
      beschleunigungX[3] = ziel[20];
      beschleunigungY[0] = ziel[21];
      beschleunigungY[1] = ziel[22];
      beschleunigungY[2] = ziel[23];
      beschleunigungY[3] = ziel[24];
      beschleunigungZ[0] = ziel[25];
      beschleunigungZ[1] = ziel[26];
      beschleunigungZ[2] = ziel[27];
      if (ziel[28] == 'e') { //last byte sended is 'e', changed so that 'umwandelnDouble' will work
        ziel[28] = '@';
      }
      beschleunigungZ[3] = ziel[28];
      ESCsendNextValue = true;

      if ( startLogging == true && stopLogging == false) { 
        writeToFile(umwandelnDouble(servo), umwandelnZeit(zeit), umwandelnDouble(gewicht), umwandelnDouble(strom), umwandelnDouble(beschleunigungX), umwandelnDouble(beschleunigungY), umwandelnDouble(beschleunigungZ));
      }
    }
  }
  catch(RuntimeException e) {
    e.printStackTrace();
    e.getCause();
  }
} 

void writeToFile(double servo, double zeit, double gewicht, double strom, double beschleunigungX, double beschleunigungY, double beschleunigungZ) { // for sequential sending of measured data. The head of the output file is written after pressing the "Messung starten" button 
  servo = map((int)servo, 0, 179, 0, 100);
  output.print(messungNr  + ";" + String.format(Locale.US, "%.0f", servo));
  output.print( ";" + String.format(Locale.US, "%.2f", zeit)); 
  output.print( ";" + String.format(Locale.US, "%.0f", gewicht));
  output.print( ";" + String.format(Locale.US, "%.2f", strom));
  output.print( ";" + String.format(Locale.US, "%.2f", beschleunigungX));
  output.print( ";" + String.format(Locale.US, "%.2f", beschleunigungY));
  output.println( ";" + String.format(Locale.US, "%.2f", beschleunigungZ));
  messungNr++;
}


long umwandelnZeit(byte array[]) {
  if ('@' == (array[4])) {
    long temp = 0;
    temp = (((array[0] << 24) & 0xFF000000) | ((array[1] << 16) & 0x00FF0000) | ((array[2] << 8)& 0x0000FF00) | ((array[3] & 0x000000FF)));
    //println("binär: " + binary(((array[0] << 24) | (array[1] << 16) | (array[2] << 8) | (array[3]))));
    //println(temp);
    return temp;
  } else return -1;// magic error number, if something doesnt work
}




double umwandelnDouble(byte array[]) {
  if ('@' == (array[3])) {
    int vorkomma = ((array[0] & 0x0F ) << 8) | (array[1] & 0xFF) ;
    //print("test");
    //println(binary( ((array[0]&0x0F)<< 8) | (array[1]&0xFF)));
    int nachkomma = (array[2]) ;

    if ( 2 == (array[0] & 0xF0) >> 4) {
      return -1.0 * ((double)vorkomma + (double)nachkomma / 100.0);
    }
    return (double)vorkomma + (double)nachkomma / 100.0;
  } else return -1;// magic error number, if something doesnt work
}


public int map(int x, int inMin, int inMax, int outMin, int outMax) { //map a range of values to another range of values

  if (x < inMin) {  // if not in range
    return outMin;
  } else if (x > inMax) {
    return outMax;
  } else {
    return (int)(((x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin)+0.5);// 0.5 for correct rounding
  }
}

/******************************UI**********************************************/
public void shutdown(GButton button) {
  StopAndStore = true;
  button.dispose();
  output.flush();
  output.close();
  myPort.write(0);
}

public void stopAndStore() {
  myPort.write(0);
  G4P.showMessage(this, "Die Messung wurde vorzeitig beendet", "Messung vorzeitig beendet", G4P.INFO);
  shutdown(btnEnd);
  stopLogging = true;
  btnEmergency.setEnabled(false);
}

public void handleButtonEvents(GButton button, GEvent event) { 
  boolean isComPortSelected = false;
  if (button == btnEmergency) {
    myPort.write(0);
    emergencyShutdown = true;
    output.flush();
    output.close();
    lblOutputFile.setLocalColorScheme(G4P.RED_SCHEME);
    titleOutputFile.setLocalColorScheme(G4P.RED_SCHEME);
    progress.setText("Notaus, Datensatz möglicherweise nicht vollständig");
    btnEnd.dispose();
  }

  // End-Programm Selection
  if (button == btnEnd) {
    if (ESCLaufvariable < (ESCWerte.length - 1)) {
      StopAndStore = true;
      myPort.write(0);
    }
  }
  //start-button Selection
  if (button == btnStart) {
    startprgm = true;
    handleFileDialog(button);

    // open File 
    fahrprofil = loadTable(fname, "header");
    String outputPath = year() + "_" + String.format("%02d", month()) + "_" + String.format( "%02d", day()) + "___" + String.format( "%02d", hour()) + "-" + String.format( "%02d", minute()) + "-"+ String.format( "%02d", second()) + ".csv";
    output = createWriter(outputPath);
    output.println("Messwert-Nr." + ";" + "ESC-Werte" + ";" + "Laufzeit seit Systemstart des MikroControllers in microsekunden" + ";" + "Gewicht in g" + ";" + "Strom in A" + ";" + "Beschleunigung X-Richtung in g" + ";" + "Beschleunigung Y-Richtung in g" + ";" + "Beschleunigung Z-Richtung in g" );  //hier spalten ergänzen
    startLogging = true; //reset all counter to begin with zero after a stable connection
    ESCLaufvariable = 0;

    titleOutputFile = new GLabel(this, titleInputFile.getX(), lblInputFile.getY() + lblInputFile.getHeight() + 10, titleInputFile.getWidth(), titleInputFile.getHeight());
    lblOutputFile = new GLabel(this, lblInputFile.getX(), titleOutputFile.getY() + titleOutputFile.getHeight() + 10, lblInputFile.getWidth(), lblInputFile.getHeight() + 50 );
    titleOutputFile.setText("Name und Pfad der Ausgabedatei: ", GAlign.LEFT, GAlign.MIDDLE);
    titleOutputFile.setOpaque(true);
    titleOutputFile.setTextBold();
    lblOutputFile.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    lblOutputFile.setText(sketchPath("") + "\n\n" + outputPath);
    lblOutputFile.setOpaque(true);
    ESCWerte = new int[fahrprofil.getRowCount() + 5]; // to be sure that last send values are zeros
    for (TableRow row : fahrprofil.rows()) {
      ESCWerte[ESCLaufvariable] = map(Integer.parseInt(row.getString("ESC-Werte")), 0, 100, 0, 179); // mapping 0% to 100% to Servo values from 0 to 179
      ESCLaufvariable++;
    }
    for ( int i = ESCLaufvariable; i <= 5; i++ ) {
      ESCWerte[i] = 0;
    }
    ESCLaufvariable = 0;
    isGUIReady = true;
    btnEnd = new GButton(this, SerialPortsButton[0].getX() + titleOutputFile.getWidth() + 80, SerialPortsButton[0].getY(), SerialPortsButton[0].getWidth() / 2, SerialPortsButton[0].getHeight());
    btnEmergency = new GButton(this, btnEnd.getX(), btnEnd.getY() + 50, btnEnd.getWidth() / 2, btnEnd.getHeight());
    btnEnd.setText("Stop & Store");
    btnEnd.setLocalColorScheme(G4P.YELLOW_SCHEME);
    btnEmergency.setText("Notaus");
    btnEmergency.setLocalColorScheme(G4P.RED_SCHEME);
    progress = new GLabel(this, lblOutputFile.getX(), lblOutputFile.getY() + lblOutputFile.getHeight() + 10, titleOutputFile.getWidth(), titleOutputFile.getHeight());
    progress.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    progress.setText("Messung läuft...");
    progress.setTextItalic();
    progress.setLocalColorScheme(G4P.YELLOW_SCHEME);
    btnStart.dispose();
  }

  //COM-Port selection
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


    createFileSystemGUI(10, 60, 300);
  }
  // Folder selection
  if (button == btnInput) {
    handleFileDialog(button);
  }
}  

// G4P code for folder and file dialogs
public void handleFileDialog(GButton button) {
  // File input selection
  if (button == btnInput) {
    // Use file filter if possible
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
        btnStart = new GButton(this, lblInputFile.getX(), lblInputFile.getY() + lblInputFile.getHeight() + 10, lblInputFile.getWidth() / 2, 2 * titleInputFile.getHeight());
        btnStart.setText("Messung starten");

        //start button
        if (startprgm == true) {
        }
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

public void createCOMPortGUI(int x, int  y, int w, int h) {
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
  }
  SerialPortsButton = new GButton[Serial.list().length]; // make buttons for every Com-port
  for ( int i = 0; i < SerialPortsButton.length; i++) {
    SerialPortsButton[i] = new GButton(this, x, (i+1)*y + 30, w, h); // buttons untereinander anordnen
    SerialPortsButton[i].setText( Serial.list()[i]);
  }
}
/*****************************************************************************/