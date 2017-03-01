#include "BMA180.h"
 BMA180* beschleunigungssensor;
void setup(){
   byte temp[6];   
  // Serial Monitoring  
  Serial.begin(115200);                     
  Serial.println("BMA180 accelerometer test");
  Serial.println();
  beschleunigungssensor = new BMA180();

 // beschleunigungssensor->readFrom(0x35,6,temp)
  
  Wire.beginTransmission(0x40);  // Address of the BMA180 device
  Wire.write(0x36);      // Send register address
  Wire.write(B11111101);          // Send value 
  Wire.endTransmission();
  
  
  beschleunigungssensor->readFrom(0x35,6,temp);
  Serial.print("Register 0x3A:  ");
  Serial.println(temp[5],BIN);
   Serial.print("Register 0x39:  ");
  Serial.println(temp[4],BIN);
   Serial.print("Register 0x38:  ");
  Serial.println(temp[3],BIN);
   Serial.print("Register 0x37:  ");
  Serial.println(temp[2],BIN);
   Serial.print("Register 0x36:  ");
  Serial.println(temp[1],BIN); 
  Serial.print("Register 0x35:  ");
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

