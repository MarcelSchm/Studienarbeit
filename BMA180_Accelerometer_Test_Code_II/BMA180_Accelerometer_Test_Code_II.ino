// *********************************************************************
// BMA180 triple axis accelerometer I2C test code 
// Displays x, y, z acceleration in 2g mode
// Origin Author:        www.geeetech.com
// Modified by:          Olaf Meier / Hubbie
//                       http://Arduino-Hannover.de
//                       http://electronicfreakblog.wordpress.com/
//
// Hardware connection:  A4 to SDI   I2C Data
//                       A5 to SCK   I2C Clock
// ***************************************************************
//
// Example of output:    x = 0.01g   y = -0.01g   z = 1.01g
//                       x = 0.01g   y = 0.00g    z = 1.00g
//                       x = 0.02g   y = -0.00g   z = 1.00g
//
// ***************************************************************
// Add libraries 
#include <Wire.h>           // I2C library

//----------------------------------------------------------------
// Software release and date 
const char* author    =  "Olaf Meier";
const char* revision  =  "R.0.7";
const char* date      =  "2013/09/27";

//----------------------------------------------------------------
// Address variable for BMA180 
const int  BMA180  = 0x40;  // Address of the BMA180 device

//----------------------------------------------------------------
// BMA180 registers
const byte RESET   = 0x10;  // soft reset
const byte PWR     = 0x0D;  // power mode. 
const byte BW      = 0X20;  // bandwidth and temperatur sensivity
const byte RANGE   = 0X35;  // range
const byte DATA    = 0x02;  // x, y, z data
const byte CHIP_ID = 0x00;  // chip ID
const byte VERSION = 0x01;  // version

//----------------------------------------------------------------
// BMA180 return values
byte chipVersion[1];    
byte chipID[1];         
float acc_x, acc_y, acc_z;  // accelerometer data 

// ***************************************************************
// Setup
// ***************************************************************
void setup() {                                    
  //--------------------------------------------------------------
  // Serial Monitoring  
  Serial.begin(9600);                     
  Serial.println("BMA180 accelerometer test");
  Serial.println();
  Serial.print(author);
  Serial.print("\t");
  Serial.print(revision);                         
  Serial.print("\t");
  Serial.println(date);  
  Serial.println();

  //----------------------------------------------------------------
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

// ***************************************************************
// ***************************************************************
// Loop
// ***************************************************************
void loop() {                               
  accelerometerRead();     
  
  Serial.print("x = ");
  Serial.print(acc_x);
  Serial.print("g"); 

  Serial.print("\t y = ");
  Serial.print(acc_y);
  Serial.print("g"); 

  Serial.print("\t z = ");
  Serial.print(acc_z);
  Serial.println("g"); 

  //delay(1000);             
}                     

// ***************************************************************
// ***************************************************************
// BMA180 initialize 
// ***************************************************************
void accelerometerInit() 
{ 
  byte temp[1];
  byte temp1;
  writeTo(RESET, 0xB6);     // Soft reset 
  writeTo(PWR, 0x10);       // Wake up 

  //----------------------------------------------------------------
  // Set bandwidth to 10 Hz; no change to temperature sensivity
  readFrom(BW,1,temp);                   
  temp1 = temp[0] & 0x0F;   // Clear bandwidth bits xxxx....
  writeTo(BW, temp1);   

  //----------------------------------------------------------------
  // Set range to */- 2 g, no change to offset_x and smp_skip  
  readFrom(RANGE, 1 ,temp);           
  temp1 = (temp[0] & 0xF1) | 0x04;  // 2 to range bits ....xxx.
  writeTo(RANGE, temp1);
}

// ***************************************************************
// Read and display the 3 axis, each one is 14 bits
// ***************************************************************
void accelerometerRead() 
{ 
  byte result[6];
  int temp;
  
  readFrom(DATA, 6, result);

  temp = (( result[0] | result[1] << 8) >>2 );
  acc_x = temp / 4096.0;

  temp = (( result[2] | result[3] << 8) >> 2);
  acc_y = temp / 4096.0;
  
  temp = (( result[4] | result[5] << 8) >> 2);
  acc_z = temp / 4096.0;
}

// ***************************************************************
// Write values to address register of the BMA180
// ***************************************************************
void writeTo(byte address, byte val) 
{
  Wire.beginTransmission(BMA180);              
  Wire.write(address);      // Send register address
  Wire.write(val);          // Send value 
  Wire.endTransmission();                        
}

// ***************************************************************
// Read num bytes starting from address into buffer array  
// ***************************************************************
void readFrom( byte address,int num, byte buff[])
{
  Wire.beginTransmission(BMA180);    
  Wire.write(address);      // Send start register address
  Wire.endTransmission();            

  Wire.beginTransmission(BMA180);                 
  Wire.requestFrom(BMA180,num);    // Request num bits from sensor

  for (int i = 0; i < num; i++)
    if(Wire.available()) buff[i] = Wire.read();          
    else buff[i]=0;
  Wire.endTransmission();            
}
// ***************************************************************
// ***************************************************************


