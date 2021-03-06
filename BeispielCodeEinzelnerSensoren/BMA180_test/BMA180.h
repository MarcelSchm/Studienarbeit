
#ifndef BMA180_h
#define BMA180_h
#include <Arduino.h>
#include <Wire.h>

class BMA180{
  public:
    BMA180();
    //~BMA180();
    void accelerometerInit();
    void accelerometerRead();
    void writeTo(byte address, byte val);
    void readFrom( byte address, int num, byte buff[]);
    void getAccelerometervalues(float* data[]); 
    void rectifyOffset(byte offset_x[2], byte offset_y[2], byte offset_z[2]);
  //private:
    // BMA180 return values
    byte chipVersion[1];
    byte chipID[1];
    float acc_x, acc_y, acc_z;  // accelerometer data
    
    // BMA180 registers
    const int  BMA180  = 0x40;  // Address of the BMA180 device
    const byte RESET   = 0x10;  // soft reset
    const byte PWR     = 0x0D;  // power mode.
    const byte BW      = 0X20;  // bandwidth and temperatur sensivity
    const byte RANGE   = 0X35;  // range
    const byte DATA    = 0x02;  // x, y, z data
    const byte CHIP_ID = 0x00;  // chip ID
    const byte VERSION = 0x01;  // version
    const byte OFFSET_LSB1 = 0x35; //bit 7 to 4 are offset_x 3:0
    const byte OFFSET_LSB2 = 0x36; //offset_z3:0, offset_y3:0
    const byte OFFSET_X = 0x38; //offset_x11:4(msb)
    const byte OFFSET_Y = 0x39; //offset_y11:4(msb)
    const byte OFFSET_Z = 0x3A; //offset_z11:4(msb)

};


#endif //BMA180_h
