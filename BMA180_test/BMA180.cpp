#include "BMA180.h"


BMA180::BMA180() {
  // BMA180 setup and shakehands
  Wire.begin();

  Serial.println("Initializing the BMA180 sensor");
  Serial.println();
  accelerometerInit();

  Serial.println("Reading chip id and version");
  Serial.println();

  readFrom(CHIP_ID, 1, chipID);
  readFrom(VERSION, 1, chipVersion);

  Serial.print("Chip ID: ");
  Serial.print(chipID[0]);
  Serial.print("\t");
  Serial.print("Version: ");
  Serial.println(chipVersion[0]);
  Serial.println();
}



void BMA180:: accelerometerInit() {
  byte temp[1];
  byte temp1;
  writeTo(RESET, 0xB6);     // Soft reset
  writeTo(PWR, 0x10);       // Wake up

  //----------------------------------------------------------------
  // Set bandwidth to 10 Hz; no change to temperature sensivity
  readFrom(BW, 1, temp);
  temp1 = temp[0] & 0x0F;   // Clear bandwidth bits xxxx....
  writeTo(BW, temp1);

  //----------------------------------------------------------------
  // Set range to */- 2 g, no change to offset_x and smp_skip
  readFrom(RANGE, 1 , temp);
  temp1 = (temp[0] & 0xF1) | 0x04;  // 2 to range bits ....xxx.
  writeTo(RANGE, temp1);
}

void BMA180::accelerometerRead() {
  byte result[6];
  int temp;

  readFrom(DATA, 6, result);

  temp = (( result[0] | result[1] << 8) >> 2);
  acc_x = temp / 4096.0;

  temp = (( result[2] | result[3] << 8) >> 2);
  acc_y = temp / 4096.0;

  temp = (( result[4] | result[5] << 8) >> 2);
  acc_z = temp / 4096.0;
}

void BMA180::writeTo(byte address, byte val) {
  Wire.beginTransmission(BMA180);
  Wire.write(address);      // Send register address
  Wire.write(val);          // Send value
  Wire.endTransmission();
}

void BMA180::readFrom( byte address, int num, byte buff[]) {
  Wire.beginTransmission(BMA180);
  Wire.write(address);      // Send start register address
  Wire.endTransmission();

  Wire.beginTransmission(BMA180);
  Wire.requestFrom(BMA180, num);   // Request num bytes from sensor

  for (int i = 0; i < num; i++)
    if (Wire.available()) buff[i] = Wire.read();
    else buff[i] = 0;
  Wire.endTransmission();
}

void BMA180::rectifyOffset(byte offset_x[2], byte offset_y[2], byte offset_z[2]) {
  byte tempOffset_x, tempOffset_y, tempOffset_z, temp;
  byte readTempOffset_xMSB, readTempOffset_xLSB, readTempOffset_yMSB, readTempOffset_yLSB, readTempOffset_zMSB, readTempOffset_zLSB;
  
//  readFrom(OFFSET_LSB1, 1, readTempOffset_xLSB);
//  readFrom(OFFSET_X, 1, readTempOffset_xMSB);
//  tempOffset_x = (readTempOffset_xLSB & 0x0F) | ((offset_x[0] & 0x0F) << 4);
//  writeTo(OFFSET_LSB1, tempOffset_x);
//  tempOffset_x = ((offset_x[1] & 0x0F) << 4) | ((offset_x[0] & 0xF0) >> 4);
//  writeTo(OFFSET_X, tempOffset_x);

  readFrom(OFFSET_LSB2,1, readTempOffset_yLSB); //actually LSB Y and Z
  readTempOffset_zLSB = (readTempOffset_yLSB & 0xF0);
//  readTempOffset_yLSB = (readTempOffset_yLSB & 0x0F);
//  readFrom(OFFSET_Y,1, readTempOffset_yMSB);
//  tempOffset_y = (readTempOffset_yLSB & 0x0F)
  temp = (offset_y[0] & 0x0F) | ((offset_z[0] & 0x0F) << 4);
  writeTo(OFFSET_LSB2, temp);
  
  temp = ((offset_y[0] & 0xF0) >> 4) | ((offset_y[1] & 0x0F) << 4); 
  writeTo(OFFSET_Y, temp);
  
  temp = ((offset_z[0] & 0xF0) >> 4) | ((offset_z[1] & 0x0F) << 4); 
  writeTo(OFFSET_Z, temp);






}
