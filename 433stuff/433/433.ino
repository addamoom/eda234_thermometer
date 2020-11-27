#define outpin 4
#define length_of_bit  10 //ms
#define carrier_period 100 //us

void setup() {
  Serial.begin(9600);
  pinMode(outpin, OUTPUT);
}

void loop() {
   String msg = "1010111000001111";
   Serial.print("begin");
   transmit(msg);
   Serial.print("end\n");
}

void transmit(String data) {
  
  send_carrier_wave(length_of_bit, carrier_period);  //start signal
  
  for (int i = 0; i < data.length(); i++) {
    if (data[i]=='0') {
      Serial.print(data[i]);
      delay(length_of_bit);
    }
    else {
      Serial.print(data[i]);
      send_carrier_wave(length_of_bit,carrier_period);
    }
  }
}

void send_carrier_wave(long duration, long wave_period){
  long periods = (duration*1000)/wave_period;
  //Serial.print(periods);
  for(int i = 0; i < periods; i++) {
    digitalWrite(outpin, HIGH);
    delayMicroseconds(wave_period/2);
    digitalWrite(outpin, LOW);
    delayMicroseconds(wave_period/2);
  }
}
