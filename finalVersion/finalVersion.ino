#include "Hx711myown.h"
#include "BMA180.h"
#include <Servo.h>

#define DOUT  A1 // Daten-Pin Waage
#define CLK  A0 // Clock-Pin Waage
#define SPIN 9 //Servo-Pin 
#define AMPPIN  A2 //Strom-Pin
// Beschleunigungssensor-Pins A4(SDA) & A5 (SCL) da I2C Schnittstelle

#define PROCESSING  //für weitergabe an processing
//#define DEBUGSCALE  //Waagen-Messwerte über Arduino Serial Monitor
//#define CALIBRATIONSCALE  // zum kalibrieren der Waage. hiermit kann der calibration factor eingestellt werden mit + und -
//#define DEBUGSERVO // Manuell Werte für den ESC vorgeben
//#define DEBUGCURRENT //Strom-Messwerte über Arduino Serial Monitor
//#define DEBUGACCELEROMETER // Beschleunigungs-MEsswerte über Arduino Serial Monitor
//#define SERIALOUTPUTALL //gib alle Messwerte über arduino serial monitor aus
HX711 scale(DOUT, CLK);
Servo myServo;
BMA180* beschleunigungssensor;

float calibration_factor = -246.5; //-246 für tablet, -247 für handy (Referenzwerte für lineare Interpol.
byte gewicht[4] = {0}; // Gewicht in 3 Bytes, ersten 2 byte Ganzzahl(plus evtl startzeichen), letzte byte komma
byte zeit[4] = {0};
byte strom[4] = {0};
byte servo[4] = {0};
byte servoAcknowledgeByte[4] = {0};
byte beschleunigungX[4] = {0};
byte beschleunigungY[4] = {0};
byte beschleunigungZ[4] = {0};
unsigned long zeitScale = 0; //Abstand zwischen Messungen 
unsigned long zeitServo = 0; //Abstand zwischen Messungen 
unsigned long zeitCurrent = 0; //Abstand zwischen Messungen 
unsigned long zeitAccelerometer = 0; //Abstand zwischen Messungen 
bool isValueReady[4] = {false};

int servoValue = 0;

const int numReadingsCurrent = 3; //number of readings for smoothing algorithm
float CurrentReadings[numReadingsCurrent];      // Strom Messwerte des Analog Inputs
int index = 0;                  // Index der Strom Messwerte
float total = 0;                  // Strom gesamtwert
float average = 0;                // Strom Durchschnitt
float currentValue = 0;



void setup() {
  Serial.begin(115200); //TODO (Serial hier korrekt?)
  /***********************WAAGE*******************************/
#ifdef DEBUGSCALE
  Serial.println("HX711 calibration sketch");
  Serial.println("Remove all weight from scale");
  Serial.println("After readings begin, place known weight on scale");
  Serial.println("Press + or a to increase calibration factor");
  Serial.println("Press - or z to decrease calibration factor");
#endif

  scale.set_scale();
  scale.tare(); //Reset the scale to 0

  long zero_factor = scale.read_average(); //Nullmessung
  scale.set_scale(calibration_factor); //einstellen über diesen Kalibrierungsfaktor. lineare Interpolation zwischen Nullmessung und dem Vergleichsgewicht
 
#ifdef DEBUGSCALE
  Serial.print("Zero factor: "); //kann genutzt werden, um die waage nicht mehr tarieren zu müssen.vllt noch sinnvoll
  Serial.println(zero_factor);
#endif
  /************************WAAGE-ENDE************************************/

  /*****************************SERVO************************************************************/
  myServo.attach(SPIN);  // attaches the servo on pin 9 to the servo object
#ifdef DEBUGSERVO
  Serial.println("Press + or a to increase servo");
  Serial.println("Press - or z to decrease servo");
#endif
  /*******************************SERVO-ENDE*****************************************************************/


  /*******************************STROMSENSOR**********************************************************************/
  for (int thisReading = 0; thisReading < numReadingsCurrent; thisReading++)
    CurrentReadings[thisReading] = 0;
  /*******************************STROMSENSOR-ENDE***********************************************************************/


  /********************************BESCHLEUNIGUNGSSENSOR*************************************************************************************/
#ifdef DEBUGACCELEROMETER
  Serial.println("BMA180 accelerometer test");
  Serial.println();
  beschleunigungssensor = new BMA180(true);
#endif
  beschleunigungssensor = new BMA180(false);
  /********************************BESCHLEUNIGUNGSSENSOR-ENDE*************************************************************************************/
}

void loop() {

  /************************SERVO****************************************************************************/
#ifdef DEBUGSERVO
  if (Serial.available()) {
    char temp = Serial.read();
    if (temp == '+' || temp == 'a') {
      if (servoValue < 180) {
        servoValue += 1;
      } else {
        Serial.println("Maximum reached");
      }

    } else if (temp == '-' || temp == 'z') {
      if (servoValue > 0) {
        servoValue -= 1;
      } else {
        Serial.println("Minimum reached");
      }
    }
    Serial.print("Servo Value:  ");
    Serial.println(servoValue);
  }
#endif

#ifdef PROCESSING
  //  if (isValueReady[3] == false) {
  //    if (Serial.read() == 'S') { // sendebereit
  //      umwandelnBytes(123,servoAcknowledgeByte); //empfangsbereit
  //      Serial.write(servoAcknowledgeByte[0]);
  //      Serial.write(servoAcknowledgeByte[1]);
  //      Serial.write(servoAcknowledgeByte[2]);
  //      Serial.write(servoAcknowledgeByte[3]);
  if (Serial.available() > 0) {
  servoValue = Serial.read();
  umwandelnBytes(servoValue, servo);
  isValueReady[0] = true;
  serialFlush();
     }
  //  }
#endif

#ifdef SERIALOUTPUTALL
 zeitServo = millis();
 umwandelnBytes(servoValue, servo);
  zeitServo = millis() - zeitServo;
  Serial.print("Servo Value:  ");
  Serial.print(servoValue);
  Serial.print(" Zeit: ");
  Serial.print(zeitServo);
  
#endif



  myServo.write(servoValue);                  // sets the servo position according to the scaled value
  //delay(15);                           // waits for the servo to get there
  /************************SERVO-ENDE****************************************************************************/


  /****************************WAAGE**************************************************************/
  #ifdef DEBUGSCALE
 Serial.print("Reading: ");
  zeitScale = millis();
  scale.get_units();
  zeitScale = millis() - zeitScale;
  Serial.print(scale.get_units());
  Serial.print(" g");
  Serial.print(" calibration_factor: ");
  Serial.print(calibration_factor);
  Serial.print(" Zeit(in Milisek) zwischen Messwerten: ");
  Serial.print(zeitScale);
  Serial.println();
#endif

#ifdef PROCESSING
  if (isValueReady[3] == false) {
    scale.set_scale(calibration_factor); //einstellen über diesen Kalibrierungsfaktor. lineare Interpolation zwischen Nullmessung und dem Vergleichsgewicht
 
    umwandelnBytes(scale.get_units(), gewicht);
    isValueReady[1] = true;
  }
#endif

#ifdef CALIBRATIONSCALE
 scale.set_scale(calibration_factor); //einstellen über diesen Kalibrierungsfaktor. lineare Interpolation zwischen Nullmessung und dem Vergleichsgewicht
  if (Serial.available())
  {
    char temp = Serial.read();
    if (temp == 't') {
      scale.tare();
    }
    if (temp == '+' || temp == 'a')
      calibration_factor += 1;
    else if (temp == '-' || temp == 'z')
      calibration_factor -= 1;
  }
#endif

#ifdef SERIALOUTPUTALL
 zeitScale = millis();
  float temp = scale.get_units();
  zeitScale = millis() - zeitScale;
  Serial.print("\tGewicht: ");
  Serial.print(temp);
  Serial.print(" Zeit: ");
  Serial.print(zeitScale);
#endif
  /****************************WAAGE-ENDE******************************************************************/

  /*******************************STROMSENSOR**********************************************************************/
  total = total - CurrentReadings[index];
  CurrentReadings[index] = analogRead(AMPPIN); //Raw data reading
  //Data processing:512->raw data from analogRead when the input is 0;
// *5/1024->analog read to 5 V ; the first 0.04->0.04V/A(sensitivity); the second 0.04->offset val;
  CurrentReadings[index] = (CurrentReadings[index] - 512) * 5 / 1024 / 0.04 ;//- 0.12;
  total = total + CurrentReadings[index];
  index = index + 1;
  if (index >= numReadingsCurrent){
    index = 0;
  }
  average = total / numReadingsCurrent; //Smoothing algorithm (http://www.arduino.cc/en/Tutorial/Smoothing)
  currentValue = average;
   zeitCurrent = millis() - zeitCurrent;

#ifdef PROCESSING
  if (isValueReady[3] == false) {
    umwandelnBytes(currentValue, strom); // hier wieder tauschen: currentValue
    isValueReady[2] = true;
  }
#endif

#ifdef DEBUGCURRENT
  Serial.print("StromWert: ");
  Serial.println(currentValue);
  delay(10);
#endif

#ifdef SERIALOUTPUTALL
  Serial.print("\tStromWert: ");
  Serial.print(currentValue);
  Serial.print(" Zeit: ");
  Serial.print(zeitCurrent);
#endif
  /*******************************STROMSENSOR-ENDE***********************************************************************/

  /********************************BESCHLEUNIGUNGSSENSOR*************************************************************************************/
  zeitAccelerometer = millis();
  beschleunigungssensor->accelerometerRead();
zeitAccelerometer = millis() - zeitAccelerometer;

#ifdef PROCESSING
  if (isValueReady[3] == false) {
    umwandelnBytes(beschleunigungssensor->acc_x, beschleunigungX);
    umwandelnBytes((beschleunigungssensor->acc_y + 0.04) , beschleunigungY);// offset to get exactly -1g
    umwandelnBytes(beschleunigungssensor->acc_z, beschleunigungZ);
    isValueReady[3] = true;
  }
#endif

#ifdef DEBUGACCELEROMETER
  Serial.print("Zeit zwischen Messwerten: ");
  Serial.println(zeitAccelerometer);
  Serial.print("x = ");
  Serial.print(beschleunigungssensor->acc_x,5);
  Serial.print("g");

  Serial.print("\t y = ");
  Serial.print(beschleunigungssensor->acc_y + 0.04,5);
  Serial.print("g");

  Serial.print("\t z = ");
  Serial.print(beschleunigungssensor->acc_z,5);
  Serial.println("g");
#endif

#ifdef SERIALOUTPUTALL

  Serial.print("\tx = ");
  Serial.print(beschleunigungssensor->acc_x);
  Serial.print("g");
   Serial.print(" Zeit: ");
  Serial.print(zeitAccelerometer);
  Serial.print("\ty = ");
  Serial.print(beschleunigungssensor->acc_y);
  Serial.print("g");
  Serial.print("\tz = ");
  Serial.print(beschleunigungssensor->acc_z);
  Serial.println("g");

#endif
  /********************************BESCHLEUNIGUNGSSENSOR-ENDE*************************************************************************************/
#ifdef PROCESSING
  messwerteSenden();
#endif
}

void messwerteSenden() {
  int gotMessage = 0;
  if (isValueReady[0] == true && isValueReady[1] == true && isValueReady[2] == true && isValueReady[3] == true) {
    
    umwandelnZeit(micros(),zeit); 
    Serial.write(servo[0]);
    Serial.write(servo[1]);
    Serial.write(servo[2]);
    Serial.write(servo[3]);
    //    while (1 != Serial.read() ) { //warte auf signal
    //    }
    Serial.write(zeit[0]);
    Serial.write(zeit[1]);
    Serial.write(zeit[2]);
    Serial.write(zeit[3]);
    Serial.write(zeit[4]);
    
    Serial.write(gewicht[0]);
    Serial.write(gewicht[1]);
    Serial.write(gewicht[2]);
    Serial.write(gewicht[3]);
    //    while (2 != Serial.read() ) { //warte auf signal
    //    }
    Serial.write(strom[0]);
    Serial.write(strom[1]);
    Serial.write(strom[2]);
    Serial.write(strom[3]);
    //    while (3 != Serial.read() ) { //warte auf signal
    //    }
    Serial.write(beschleunigungX[0]);
    Serial.write(beschleunigungX[1]);
    Serial.write(beschleunigungX[2]);
    Serial.write(beschleunigungX[3]);
    //    while (4 != Serial.read() ) { //warte auf signal
    //    }
    Serial.write(beschleunigungY[0]);
    Serial.write(beschleunigungY[1]);
    Serial.write(beschleunigungY[2]);
    Serial.write(beschleunigungY[3]);
    //    while (5 != Serial.read() ) { //warte auf signal
    //    }
    Serial.write(beschleunigungZ[0]);
    Serial.write(beschleunigungZ[1]);
    Serial.write(beschleunigungZ[2]);
    Serial.write('e'); // statt @ ein absolutes Endbyte
    //Serial.println(temptestcounter);

    // while (6 != Serial.read() ) { //warte auf signal
    //    }
  }
//  Serial.print("ZEit");
//  Serial.println(millis());
//  // Serial.print(isValueReady[0],BIN);
  //  Serial.print(isValueReady[1],BIN);
  //   Serial.print(isValueReady[2],BIN);
  //    Serial.print(isValueReady[3],BIN);
  isValueReady[0] = false;
  isValueReady[1] = false;
  isValueReady[2] = false;
  isValueReady[3] = false;
  //  Serial.print(isValueReady[0],BIN);
  //  Serial.print(isValueReady[1],BIN);
  //   Serial.print(isValueReady[2],BIN);
  //    Serial.print(isValueReady[3],BIN);



}

void umwandelnZeit(unsigned long zeit, byte array[]){
  array[0] = (zeit & 0xFF000000) >> 24;
  array[1] = (zeit & 0x00FF0000) >> 16;
  array[2] = (zeit & 0x0000FF00) >> 8;
  array[3] = (zeit & 0x000000FF);
  array[4] = '@';
  }

void serialFlush(){
  while(Serial.available() > 0) {
    char t = Serial.read();
  }
}   
  
void umwandelnBytes(double zahl, byte array[]) {
  bool negativ = false;
  if ( zahl < 0.000) {
    negativ = true;
  }
  if (true == negativ) {
    zahl *= -1;
  }
  uint16_t vorkomma = (int)zahl;
  unsigned int nachkomma = 0;
  zahl -= (int)zahl;
  nachkomma = 100 * zahl;
  array[0] = ((vorkomma & 0xF00) >> 8) ;

  if (true == negativ) {
    array[0] = array[0] | (1 << 5);
  }
  array[1] = (vorkomma & 0x0F0)  | (vorkomma & 0x00F);
  array[2] = (nachkomma & 0xF0) | (nachkomma & 0x0F);
  array[3] = '@';
  // 0000.0000                         0000.0000         0000.0000     0010.0000
  // posnegByte.vorkomma               vorkomma          nachkomma     endbyte.
}

