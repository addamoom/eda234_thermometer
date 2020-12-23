#include <Wire.h>
#include <LM75.h>

#define OUTPIN 4
#define LENGTH_OF_BIT  1000 //us, max 16000 due to delayMicro() limitations
#define CARRIER_PERIOD 100 //us
#define periods 10 // how many periods a carrier wave is, = LENGTH_OF_BIT/CARRIER_PERIOD

LM75 sensor; //initialize sensor with A0->GND, A1->GND and A2->GND
	     //communicates via pin a4 and a5

void setup()
{
  Wire.begin();
  Serial.begin(9600);
  pinMode(OUTPIN, OUTPUT);
}

//currently breaks if temp is over 100, but thats not very useful anyway
void loop()
{
  //Aquire Temperature from sensor, handled by LM75 library
  float tempraw = sensor.temp();

  //Split float into separate digits. There are some rounding issues with this approach
  //could be done with snprintf or pointer operations instead
  int value = (tempraw * 100.0)+ 0.5; //0.5 to round up
  char thousandsDigit = '0' + ((value / 1000) % 10);
  char hundredsDigit = '0' + ((value / 100) % 10);
  char tensDigit =  '0' + ((value / 10) % 10);
  char onesDigit =  '0' + (value % 10);
  String sign = "0";
 
  //Set sign bit if applicable
  if(tempraw < 0)
	sign = "1";
  
/*//Debug information 
  Serial.print("\nTemp: ");
  Serial.print(to4bit(thousandsDigit));
  Serial.print(" ");
  Serial.print(to4bit(hundredsDigit));
  Serial.print(" ");
  Serial.print(to4bit(tensDigit));
  Serial.print(" ");
  Serial.print(to4bit(onesDigit));
  Serial.print(" C\n");
*/
  
  //generate the message with the "key" - 1101 , the sign bit, and all the aquired digits
  String msg = "1101" + sign + "0000" + to4bit(thousandsDigit)  + to4bit(hundredsDigit) +to4bit(tensDigit) + to4bit(onesDigit);
  
  //Debug information
  //Serial.print("message: ");
  //Serial.print(msg);
  
  //Send message
  transmit(msg);

  //Wait a bit before the next transmission  
  delay(500);

}

//Takes the message, being a string of zeroes and ones, and transmits it to the fpga.
void transmit(String data) {
  
  //Send the start bit, a logic one, telling the fpga to start receiving after this
  send_carrier_wave();
  
  // Loop through each character in the message, and send either
  // 0, which is equal to doing nothing for LENGTH_OF_BIT, or 1, being a carrier wave for LENGTH_OF_BIT
  for (int i = 0; i < data.length(); i++) {
    if (data[i]=='0') {
      delayMicroseconds(LENGTH_OF_BIT-5);
    }
    else {
      send_carrier_wave();
    }
  }
}

//generate a carrier wave for LENGTH_OF_BIT microseconds
void send_carrier_wave(){

  for(int i = 0; i < periods; i++) {
    //Drive outpin high for half the period  - a few microseconds to account for skew
    digitalWrite(OUTPIN, HIGH);
    delayMicroseconds(CARRIER_PERIOD/2 - 2);
    //then do the same but low
    digitalWrite(OUTPIN, LOW);
    delayMicroseconds(CARRIER_PERIOD/2 - 2);
  }
}
//conversion table from char to string of bits
String to4bit(char d){
 if(d=='0')
    return "0000";
 else if(d=='1')
    return "0001";
 else if(d=='2')
    return "0010";
 else if(d=='3')
    return "0011";
 else if(d=='4')
    return "0100";
 else if(d=='5')
    return "0101";
 else if(d=='6')
    return "0110";
 else if(d=='7')
    return "0111";
 else if(d=='8')
    return "1000";
 else if(d=='9')
    return "1001";
 return "0000";
}
