#include "BMA180.h"
 BMA180* beschleunigungssensor;
void setup(){
   byte temp[6];   
  // Serial Monitoring  
  Serial.begin(115200);                     
  Serial.println("BMA180 accelerometer test");
  Serial.println();
  beschleunigungssensor = new BMA180();

byte x[] = {B11111011,B00001011};//{B00000011,B01101011}
byte y[] = {B01100110,B00001001};//{B00001001,B01100110}
byte z[] = {B01111110,B00000010};//{B00000010,B01111110}
  beschleunigungssensor->rectifyOffset(x,y,z);
  
  
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

