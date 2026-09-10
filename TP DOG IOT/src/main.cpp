//Grupo 6 - Ducau, Jeiman & Zonis
#include "main.h"
#include <Arduino.h>
#include "SENSORES/gas.h"
#include "SENSORES/presencia_humana.h"
#include "ACTUADORES/lcd.h"

void setup() {
  Serial.begin(115200);
  escanearI2C();
  inicializarLCD();
  inicializarSensorGas();
  inicializarSensorPresenciaHumana();
}

void loop() {
  Serial.println(hayPresenciaHumana());
  Serial.println(procesarDistanciaUART());
  delay(1000);
}

