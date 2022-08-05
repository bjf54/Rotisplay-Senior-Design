/* UART Example, any character received on either the real
   serial port, or USB serial (or emulated serial to the
   Arduino Serial Monitor when using non-serial USB types)
   is printed as a message to both ports.

   This example code is in the public domain.
*/

// set this to the hardware serial port you wish to use
#define HWSERIAL Serial1

void setup() {
	Serial.begin(115200);
	Serial1.begin(115200);
}

  const int numLEDs = 70;

  byte readBuffer[(numLEDs * 360) * 4];

void loop() {
//        int incomingByte;
        
	if (Serial.available()) {
    char dat = Serial.read();
    Serial1.write(dat);
  }
  if (Serial1.available()) {
    char dat = Serial1.read();
    Serial.write(dat);
  }

  //Handle Bluetooth Commands
//  if (Serial1.available()) {
//
//    int initTime = millis();
//    int dat = Serial1.readBytes(readBuffer, (numLEDs * 360) * 4);
//    double endTime = millis() - initTime;
//    Serial1.flush();
//
//    if(dat == 0) return;
//    
//    Serial.print("\nI received: ");
//    Serial.print(dat);
//    Serial.print(" bytes\n");
//    Serial.print("In ");
//    Serial.print(endTime / 1000.0);
//    Serial.print(" seconds.\n");
//
//    if(readBuffer[0] == 's' && readBuffer[1] == '!') {
//      
//    }
//
//    if(dat > 100) {
//      delay(1000);
//      Serial1.write("tc!");
//      Serial.print("Sent tc!");
//      Serial.print("Received:\n");
//      for(int i = 0; i < dat; i++) {
//        Serial.print(String(readBuffer[i], HEX));
//      }
//    } else {
//      Serial.print("Received:\n");
//      for(int i = 0; i < dat; i++) {
//        Serial.print((char)readBuffer[i]);
//      }
//    }
//  }
}
