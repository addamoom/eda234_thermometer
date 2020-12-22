#include <Wire.h>
#include <LM75.h>

#define outpin 4
#define length_of_bit  1000 //us, max 16000 according to delayMicro docs
#define carrier_period 100 //us
#define periods 10 // how many periods a carrier wave is, = lenght_of_bit/carrier_period

LM75 sensor; //initialize sensor with A0->GND, A1->GND and A2->GND
	     //communicates via pin a4 and a5

void setup()
{
  Wire.begin();
  Serial.begin(9600);
  pinMode(outpin, OUTPUT);
}

//currently breaks if temp is over 100, but thats not very useful anyway
void loop()
{
  float tempraw = sensor.temp();
  int value = (tempraw * 100.0)+ 0.5; //0.5 to round up
  char thousandsDigit = '0' + ((value / 1000) % 10);
  char hundredsDigit = '0' + ((value / 100) % 10);
  char tensDigit =  '0' + ((value / 10) % 10);
  char onesDigit =  '0' + (value % 10);
  String sign = "0";

  if(tempraw < 0)
	sign = "1";
  
/* 
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

  String msg = "1101" + sign + "0000" + to4bit(thousandsDigit)  + to4bit(hundredsDigit) +to4bit(tensDigit) + to4bit(onesDigit);
  
  //Serial.print("message: ");
  //Serial.print(msg);
  
  transmit(msg);  
  delay(500);

}

//Trasnmits either 0, which is equal to nothing, or 1, being a carrier wave
void transmit(String data) {
  
  send_carrier_wave();  //start signal
  
  for (int i = 0; i < data.length(); i++) {
    if (data[i]=='0') {
      delayMicroseconds(length_of_bit-5);
    }
    else {
      send_carrier_wave();
    }
  }
}

//generate a carrier wave
void send_carrier_wave(){

  for(int i = 0; i < periods; i++) {
    digitalWrite(outpin, HIGH);
    delayMicroseconds(48);
    digitalWrite(outpin, LOW);
    delayMicroseconds(48);
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
