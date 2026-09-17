//Grupo 6 - Ducau, Jeiman & Zonis
#include "main.h"
#include <Arduino.h>
#include <Wire.h>
#include "SENSORES/temperatura.h"
#include "SENSORES/gas.h"
#include "SENSORES/presencia_humana.h"
#include "SENSORES/corriente.h"
#include "SENSORES/luz.h"
#include "ACTUADORES/interfaz.h"
#include "ACTUADORES/lcd.h"
#include "config.h"

void setup() {
  Serial.begin(115200);
  //Sensores
  inicializarSensorGas();
  inicializarSensorPresenciaHumana();
  inicializarSensorTemperatura();
  inicializarSensorCorriente();
  //Actuadores
  inicializarLDR();
  inicializarInterfaz();
  inicializarLCD();
}

void loop() {
  Serial.println(hayPresenciaHumana());
  Serial.println(procesarDistanciaUART());

  delay(1000);
}

