#include "Hx711myown.h"
#include <Servo.h>

#define DOUT  A1 // Daten-Pin Waage
#define CLK  A0 // Clock-Pin Waage
#define SPIN 9 //Servo-Pin 
#define AMPPIN  A2 //Strom-Pin

//#define PROCESSING  //für weitergabe an processing
#define DEBUGSERIAL  //Waagen-Messwerte über Arduino Serial Monitor
//#define CALIBRATIONSCALE  // zum kalibrieren der Waage. hiermit kann der calibration factor eingestellt werden mit + und -
//#define DEBUGSERVO // Manuell Werte für den ESC vorgeben
#define DEBUGCURRENT //Strom-Messwerte über Arduino Serial Monitor
HX711 scale(DOUT, CLK);
Servo myServo;

float calibration_factor = -246.5; //-246 für tablet, -247 für handy (Referenzwerte für lineare Interpol.
byte gewicht[4] = {0}; // Gewicht in 3 Bytes, ersten 2 byte Ganzzahl(plus evtl startzeichen), letzte byte komma
byte strom[4] = {0};
byte servo[4] = {0};
byte beschleunigung[4] = {0};
unsigned long zeit = 0; //Abstand zwischen Messungen

int servoValue = 0;

const int numReadingsCurrent = 30;
float CurrentReadings[numReadingsCurrent];      // Strom Messwerte des Analog Inputs
int index = 0;                  // Index der Strom Messwerte
float total = 0;                  // Strom gesamtwert
float average = 0;                // Strom Durchschnitt
float currentValue = 0;



void setup() {
  Serial.begin(9600); //TODO (Serial hier korrekt?)
  /***********************WAAGE*******************************/
#ifdef DEBUGSERIAL
  Serial.println("HX711 calibration sketch");
  Serial.println("Remove all weight from scale");
  Serial.println("After readings begin, place known weight on scale");
  Serial.println("Press + or a to increase calibration factor");
  Serial.println("Press - or z to decrease calibration factor");
#endif

  scale.set_scale();
  scale.tare(); //Reset the scale to 0

  long zero_factor = scale.read_average(); //Nullmessung
#ifdef DEBUGSERIAL
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
}

void loop() {
  /****************************WAAGE**************************************************************/
  scale.set_scale(calibration_factor); //einstellen über diesen Kalibrierungsfaktor. lineare Interpolation zwischen Nullmessung und dem Vergleichsgewicht
#ifdef DEBUGSERIAL
  Serial.print("Reading: ");
  zeit = millis();
  scale.get_units();
  zeit = millis() - zeit;
  Serial.print(scale.get_units());
  Serial.print(" g");
  Serial.print(" calibration_factor: ");
  Serial.print(calibration_factor);
  Serial.print(" Zeit(in Milisek) zwischen Messwerten: ");
  Serial.print(zeit);
  Serial.println();
#endif

#ifdef PROCESSING
  umwandelnBytes(scale.get_units(), gewicht);
  Serial.write(gewicht[0]);
  Serial.write(gewicht[1]);
  Serial.write(gewicht[2]);
  Serial.write(gewicht[3]);
#endif
#ifdef CALIBRATIONSCALE
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
  /****************************WAAGE-ENDE******************************************************************/
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
  umwandelnBytes(servoValue, servo);
  Serial.write(servo[0]);
  Serial.write(servo[1]);
  Serial.write(servo[2]);
  Serial.write(servo[3]);
#endif



  myServo.write(servoValue);                  // sets the servo position according to the scaled value
  delay(15);                           // waits for the servo to get there
  /************************SERVO-ENDE****************************************************************************/
  /*******************************STROMSENSOR**********************************************************************/
  total = total - CurrentReadings[index];
  CurrentReadings[index] = analogRead(AMPPIN); //Raw data reading
  //Data processing:510-raw data from analogRead when the input is 0;
  // 5-5v; the first 0.04-0.04V/A(sensitivity); the second 0.04-offset val;
  CurrentReadings[index] = (CurrentReadings[index] - 512) * 5 / 1024 / 0.04 - 0.12;

  total = total + CurrentReadings[index];
  index = index + 1;
  if (index >= numReadingsCurrent)
    index = 0;
  average = total / numReadingsCurrent; //Smoothing algorithm (http://www.arduino.cc/en/Tutorial/Smoothing)
  currentValue = average;
  #ifdef DEBUGCURRENT
  Serial.print("StromWert: ");
  Serial.println(currentValue);
  delay(10);
  #endif
  /*******************************STROMSENSOR-ENDE***********************************************************************/

}

void umwandelnBytes(double zahl, byte array[]) {
  bool negativ = false;
  if ( zahl < 0.000) {
    negativ = true;
  }
  if (true == negativ) {
    zahl *= -1;
  }
  uint16_t vorkomma = ( int)zahl;
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

