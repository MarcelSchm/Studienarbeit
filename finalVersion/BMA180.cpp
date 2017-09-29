#include "BMA180.h"


BMA180::BMA180(bool debug) {
  // BMA180 setup and shakehands
  Wire.begin();
  if (debug) {
    Serial.println("Initializing the BMA180 sensor");
    Serial.println();
  }
  accelerometerInit();
  if (debug) {
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
}



void BMA180:: accelerometerInit() {
  byte temp[1];
  byte temp1;
  writeTo(RESET, 0xB6);     // Soft reset
  writeTo(PWR, 0x10);       // Wake up

  //----------------------------------------------------------------
  // Set bandwidth to 1200 Hz; no change to temperature sensivity
  readFrom(BW, 1, temp);
  temp1 = temp[0] & 0x7F;   // Clear bandwidth bits xxxx....
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

  temp = (( result[0] | result[1] << 8) >> 2 );
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
  Wire.requestFrom(BMA180, num);   // Request num bits from sensor

  for (int i = 0; i < num; i++)
    if (Wire.available()) buff[i] = Wire.read();
    else buff[i] = 0;
  Wire.endTransmission();
}

