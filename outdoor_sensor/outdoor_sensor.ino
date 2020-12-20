#include <Wire.h>
#include <LM75.h>

#define outpin 4
#define length_of_bit  1000 //us, max 16000 according to delayMicro docs
#define carrier_period 100 //us

LM75 sensor; //initialize sensor with A0->GND, A1->GND and A2->GND
//kommer kommunicera på a4 och a5 tror jag

  void setup()
{
  Wire.begin();
  Serial.begin(9600);
  pinMode(outpin, OUTPUT);
}

//currently breaks if temp is negative or over 100 but whatever
void loop()
{
  float tempraw = sensor.temp();
  int value = (tempraw * 100.0) + 0.5;
  char thousandsDigit = '0' + ((value / 1000) % 10);
  char hundredsDigit = '0' + ((value / 100) % 10);
  char tensDigit =  '0' + ((value / 10) % 10);
  char onesDigit =  '0' + (value % 10);

  Serial.print("\nTemp: ");
  Serial.print(to4bit(thousandsDigit));
  Serial.print(" ");
  Serial.print(to4bit(hundredsDigit));
  Serial.print(" ");
  Serial.print(to4bit(tensDigit));
  Serial.print(" ");
  Serial.print(to4bit(onesDigit));
  Serial.print(" C\n");
 
  String msg = "110100000" + to4bit(thousandsDigit)  + to4bit(hundredsDigit) +to4bit(tensDigit) + to4bit(onesDigit);
  Serial.print("message: ");
  Serial.print(msg);
  transmit(msg);  
  delay(2500);
}

void transmit(String data) {
  
  send_carrier_wave(length_of_bit, carrier_period);  //start signal
  
  for (int i = 0; i < data.length(); i++) {
    if (data[i]=='0') {
      //Serial.print(data[i]);
      delayMicroseconds(length_of_bit-5);
    }
    else {
      //Serial.print(data[i]);
      send_carrier_wave(length_of_bit,carrier_period);
    }
  }
}

void send_carrier_wave(long duration, long wave_period){
  //long periods = duration/wave_period;
  int periods = 10; 
  //Serial.print(periods);
  for(int i = 0; i < periods; i++) {
    digitalWrite(outpin, HIGH);
    delayMicroseconds(48);
    digitalWrite(outpin, LOW);
    delayMicroseconds(48);
  }
}

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
