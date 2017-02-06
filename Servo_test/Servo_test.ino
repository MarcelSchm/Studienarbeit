/*
 Controlling a servo position using a potentiometer (variable resistor)
 by Michal Rinott <http://people.interaction-ivrea.it/m.rinott>

 modified on 8 Nov 2013
 by Scott Fitzgerald
 http://www.arduino.cc/en/Tutorial/Knob
*/

#include <Servo.h>

Servo myservo;  // create servo object to control a servo

int servoValue = 0;  
   

void setup() {
  Serial.begin(9600);
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  Serial.println("Press + or a to increase servo");
  Serial.println("Press - or z to decrease servo");
}

void loop() {
   if (Serial.available()) {
    char temp = Serial.read();
    if(temp == '+' || temp == 'a'){
      if(servoValue < 180){
        servoValue += 1;
      } else {
       Serial.println("Maximum reached");
      }

    } else if(temp == '-' || temp == 'z'){
      if(servoValue > 0){
        servoValue -= 1;
      } else {
       Serial.println("Minimum reached");
      }
    }
    Serial.print("Servo Value:  ");
    Serial.println(servoValue);
      
  }

 
  myservo.write(servoValue);                  // sets the servo position according to the scaled value
  delay(15);                           // waits for the servo to get there
}

