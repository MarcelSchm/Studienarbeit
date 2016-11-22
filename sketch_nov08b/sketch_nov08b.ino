#define DEBUG

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
//Serial.print("array[0]");
//Serial.println(array[0],BIN);
//Serial.print("array[1]");
//Serial.println(array[1],BIN);
//Serial.print("array[2]");
//Serial.println(array[2],BIN);
//Serial.print("array[3]");
//Serial.println(array[3],BIN);
}

double umwandelnDouble(byte array[]) {
  if('@'==(array[3])){
	unsigned int vorkomma = ((array[0] & 0x0F ) << 8) | (array[1]) ;
	unsigned int nachkomma = (array[2]) ;

          if( 2 == (array[0]&0xF0)>>4){
              return -1.0*((double)vorkomma + (double)nachkomma / 100);
}
	return (double)vorkomma + (double)nachkomma / 100;
  }
  
  else{
  #ifdef DEBUG
  Serial.print("falsches Beginner-Byte empfangen");
  #endif
  }

}

byte gewicht[4]={0}; // Gewicht in 3 Bytes, ersten 2 byte Ganzzahl(plus evtl startzeichen), letzte byte komma 


void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
pinMode(13,OUTPUT);
analogWrite(13,LOW);

}

void loop() {

  Serial.write(gewicht,4);
 // Serial.println(umwandelnDouble(gewicht));
umwandelnBytes(452.42, gewicht);
char t = Serial.read();
if(t=='1'){
  digitalWrite(13,HIGH);
  umwandelnBytes(2.2, gewicht);
  }
  if(t=='2'){
    digitalWrite(13,LOW);
    umwandelnBytes(56.69, gewicht);

}

}
