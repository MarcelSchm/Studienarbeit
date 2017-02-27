import java.util.ArrayList;
import processing.serial.*;
import g4p_controls.*;

public void setup() {
  size(660, 420);
  createCOMPortGUI(10, 30, 200, 20);
  //createFileSystemGUI(10, 60, 300);
}

public void draw() {
  background(0, 0, 0);
}

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
    }
  }
  if ( isComPortSelected == true) {
    for (GButton buttonCounter : SerialPortsButton) {
      buttonCounter.dispose();
    }
    testButton.dispose();
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
        // open File TODO
        fahrprofil = loadTable(fname, "header");
        String outputPath = year() + "_" + month() + "_" + day() + "___" + hour() + "-" + minute()+ "-"+ second()+ ".csv";
        output = createWriter(outputPath);
        output.println("Messwert-Nr." + ";" + "ESC-Werte" + ";" + "Gewicht in g" + ";" + "Strom in A" + ";" + "Beschleunigung X-Richtung in g" + ";" + "Beschleunigung Y-Richtung in g" + ";" + "Beschleunigung Z-Richtung in g" );  //hier spalten ergänzen
        GLabel lblOutputFile = new GLabel(this, titleInputFile.getX(), titleInputFile.getY() + 160, titleInputFile.getWidth(),titleInputFile.getHeight());
        GLabel titleOutputFile = new GLabel(this, titleInputFile.getX(), titleInputFile.getY() + 60, titleInputFile.getWidth(),titleInputFile.getHeight());
        lblOutputFile.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
        lblOutputFile.setText(outputPath);
        lblOutputFile.setOpaque(true);
        lblOutputFile.setLocalColorScheme(G4P.CYAN_SCHEME);
        
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