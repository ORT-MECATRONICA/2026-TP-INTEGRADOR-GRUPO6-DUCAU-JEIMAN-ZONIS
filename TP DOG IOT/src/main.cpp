//Grupo 6 - Ducau, Jeiman & Zonis
#include "main.h"
#include <Arduino.h>
#include "SENSORES/gas.h"
#include "ACTUADORES/lcd.h"


void setup() {
  Serial.begin(115200);
  escanearI2C();
  inicializarLCD();
  inicializarSensorGas();
}

void loop() {
  printearLCD("Hola, mundo!", 0);
  delay(1000);
  printearLCD("Linea 2", 1);
  delay(500);
  uint16_t lectura = lecturaAnalogicaGas();
  Serial.print("Lectura del sensor de gas: ");
  Serial.println(lectura);
}

