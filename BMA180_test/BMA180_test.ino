#include "BMA180.h"
 BMA180* beschleunigungssensor;
void setup(){
   byte temp[6];   
  // Serial Monitoring  
  Serial.begin(115200);                     
  Serial.println("BMA180 accelerometer test");
  Serial.println();
  beschleunigungssensor = new BMA180();

  
  
  beschleunigungssensor->readFrom(0x35,6,temp);
  Serial.print("Register OFFSET_LSB1:  ");
  Serial.println(temp[5],BIN);
   Serial.print("Register OFFSET_LSB2:  ");
  Serial.println(temp[4],BIN);
   Serial.print("Register OFFSET_T:  ");
  Serial.println(temp[3],BIN);
   Serial.print("Register OFFSET_x:  ");
  Serial.println(temp[2],BIN);
   Serial.print("Register OFFSET_y:  ");
  Serial.println(temp[1],BIN); 
  Serial.print("Register OFFSET_z:  ");
  Serial.println(temp[0],BIN);
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

  delay(500);  
}

