#include "BMA180.h"
 BMA180* beschleunigungssensor;
void setup(){
  // Serial Monitoring  
  Serial.begin(9600);                     
  Serial.println("BMA180 accelerometer test");
  Serial.println();
  beschleunigungssensor = new BMA180();

}

void loop(){
  beschleunigungssensor->accelerometerRead();     
  
  Serial.print("x = ");
  Serial.print(beschleunigungssensor->acc_x);
  Serial.print("g"); 

  Serial.print("\t y = ");
  Serial.print(beschleunigungssensor->acc_y);
  Serial.print("g"); 

  Serial.print("\t z = ");
  Serial.print(beschleunigungssensor->acc_z);
  Serial.println("g"); 

  //delay(1000);  
}

