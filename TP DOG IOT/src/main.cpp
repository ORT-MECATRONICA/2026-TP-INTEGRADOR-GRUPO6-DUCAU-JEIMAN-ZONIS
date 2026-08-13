//Grupo 6 - Ducau, Jeiman & Zonis
#include "main.h"
#include <Arduino.h>
#include "ACTUADORES/lcd.h"
// put function declarations here:
int myFunction(int, int);

void setup() {
  Serial.begin(112500);
  inicializarLCD();
}

void loop() {
  printearLCD("Hola, mundo!", 0);
  delay(1000);
}

