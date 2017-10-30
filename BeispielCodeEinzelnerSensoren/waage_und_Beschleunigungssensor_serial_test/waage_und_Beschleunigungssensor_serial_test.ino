#include "Hx711myown.h"
#include "BMA180.h"

#define DOUT  A1
#define CLK  A0


//#define DEBUGSERIAL  //Werte über Arduino Serial Monitor
#define PROCESSING  //für weitergabe an processing

HX711 scale(DOUT, CLK);
 BMA180* beschleunigungssensor;
 
float calibration_factor = -246.5; //-246 für tablet, -247 für handy
byte gewicht[4]={0}; // Gewicht in 3 Bytes, ersten 2 byte Ganzzahl(plus evtl startzeichen), letzte byte komma 
byte beschleunigung[4]={0};
 unsigned long zeit = 0; //Abstand zwischen Messungen



void setup() {
  Serial.begin(9600);
  #ifdef DEBUGSERIAL
  Serial.println("HX711 calibration sketch");
  Serial.println("Remove all weight from scale");
  Serial.println("After readings begin, place known weight on scale");
  Serial.println("Press + or a to increase calibration factor");
  Serial.println("Press - or z to decrease calibration factor");
  #endif

  scale.set_scale();
  scale.tare(); //Reset the scale to 0
  beschleunigungssensor = new BMA180();

  long zero_factor = scale.read_average(); //Nullmessung
  #ifdef DEBUGSERIAL
  Serial.print("Zero factor: "); //kann genutzt werden, um die waage nicht mehr tarieren zu müssen.vllt noch sinnvoll
  Serial.println(zero_factor);
  #endif
}

void loop() {

  scale.set_scale(calibration_factor); //einstellen über diesen Kalibrierungsfaktor. lineare Interpolation zwischen Nullmessung und dem Vergleichsgewicht
#ifdef DEBUGSERIAL
  Serial.print("Reading: ");
  zeit = millis();
  scale.get_units();
    zeit = millis()-zeit;
  Serial.print(scale.get_units());
  Serial.print(" g"); 
  Serial.print(" calibration_factor: ");
  Serial.print(calibration_factor);
  Serial.print(" Zeit(in Milisek) zwischen Messwerten: ");
  Serial.print(zeit);
  Serial.println();
  #endif
  
  #ifdef PROCESSING
    beschleunigungssensor->accelerometerRead();
umwandelnBytes(scale.get_units(),gewicht);
Serial.write(gewicht[0]);
Serial.write(gewicht[1]);
Serial.write(gewicht[2]);
Serial.write(gewicht[3]);
umwandelnBytes(beschleunigungssensor->acc_x,beschleunigung);
Serial.write(beschleunigung[0]);
Serial.write(beschleunigung[1]);
Serial.write(beschleunigung[2]);
Serial.write(beschleunigung[3]);
  #endif

//  if(Serial.available())
//  {
//    char temp = Serial.read();
//    if(temp=='t'){
//      scale.tare();
//    }
//    if(temp == '+' || temp == 'a')
//      calibration_factor += 1;
//    else if(temp == '-' || temp == 'z')
//      calibration_factor -= 1;
//  }
}

void umwandelnBytes(double zahl, byte array[]) {
  bool negativ = false;
  if( zahl<0.000){
    negativ = true;
  }
  if (true==negativ){
    zahl *= -1;
    }
  uint16_t vorkomma = ( int)zahl;
  unsigned int nachkomma = 0;
  zahl -= (int)zahl;
  nachkomma = 100 * zahl;
  array[0] = ((vorkomma & 0xF00) >> 8) ;
  
if(true==negativ){
  array[0] = array[0] | (1<<5); 
  }
	array[1] = (vorkomma & 0x0F0)  | (vorkomma & 0x00F);
	array[2] = (nachkomma & 0xF0) | (nachkomma & 0x0F);
        array[3]= '@';
// 0000.0000                         0000.0000         0000.0000     0010.0000   
// posnegByte.vorkomma               vorkomma          nachkomma     endbyte.
}

