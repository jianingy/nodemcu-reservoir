//The library used for arduino  https://github.com/bogde/HX711
// LCD can also be used instead of serial
#include "HX711.h"
// HX711.DOUT	- pin 10
// HX711.PD_SCK	- pin 11
int NOTIFY_PIN = 13;
HX711 scale(A2, A1); // parameter "gain" is ommited; the default value 128 is used by the  library  library*/

void setup()
{
  pinMode(NOTIFY_PIN, OUTPUT);      // sets the digital pin as output
  Serial.begin(38400);
  Serial.println("HX711 Demo");
  Serial.println("Before setting up the scale:");
  Serial.print("read: \t\t ");
  Serial.println(scale.read());			// print a raw reading from the ADC

  Serial.print("read average:\t\t ");
  Serial.println(scale.read_average(20));       // print the average of 20 readings from the ADC

  Serial.print("get value: \t\t ");
  Serial.println(scale.get_value(5));
// print the average of 5 readings from the ADC minus the tare weight (not set yet)

  Serial.print("get units: \t\t ");
  Serial.println(scale.get_units(5), 1);
// print the average of 5 readings from the ADC minus tare weight (not set) divided by the SCALE parameter (not set yet)
  scale.set_scale(2420.f);
 // this value is obtained by calibrating the scale with known weights; see the README for details
  scale.tare();   // reset the scale to 0

 Serial.println("After setting up the scale:");

 Serial.print("read: \t\t");
 Serial.println(scale.read());                	      // print a raw reading from the ADC

 Serial.print("read average:\t\t ");
 Serial.println(scale.read_average(20));       // print the average of 20 readings from the ADC

 Serial.print("get value: \t\t ");
 // print the average of 5 readings from the ADC minus the tare weight, set with tare()
 Serial.println(scale.get_value(5));
 Serial.print("get units: ");
 Serial.println(scale.get_units(5), 1);
 // print the average of 5 readings from the ADC minus tare weight, divided by the SCALE parameter set with set_scale

 Serial.println("Readings:");
}

void loop()
{
  Serial.print("Weight :");
  /* ---------Weight in terms of KG-------------*/
  float weight = scale.get_units() * 0.1;
  if (weight < 2.0) {
    digitalWrite(NOTIFY_PIN, HIGH);
  } else {
    digitalWrite(NOTIFY_PIN, LOW);
  }
  Serial.print(weight , 1);
  Serial.print("KG");
  Serial.print("\r\n");
  scale.power_down();			        // put the ADC in sleep mode
  delay(1000);
  scale.power_up();
}
