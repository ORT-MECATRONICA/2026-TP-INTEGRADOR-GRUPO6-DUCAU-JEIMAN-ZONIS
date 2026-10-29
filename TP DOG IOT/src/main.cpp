//Grupo 6 - Ducau, Jeiman & Zonis
#include "main.h"
#include <Arduino.h>
#include <Wire.h>

#include "SENSORES/temperatura.h"
#include "SENSORES/gas.h"
#include "SENSORES/corriente.h"
#include "SENSORES/luz.h"
#include "SENSORES/presencia_humana.h"
#include "ACTUADORES/interfaz.h"
#include "ACTUADORES/lcd.h"
#include "config.h"


datosTemperatura datosTemperaturaActual;
uint16_t lecturaGasActual;
datosPresenciaHumana datosPresenciaActual;
energia datosCorrienteActual;
bool estadoLDR;
estadoBotones datosBotonActual;

void setup() {
  Serial.begin(115200);

  Wire.begin(SDA_5V, SCL_5V);
  Wire1.begin(SDA_3V3, SCL_3V3, 100000);

  // Inicializacion de Sensores
 /* inicializarSensorGas();
  inicializarSensorPresenciaHumana(); 
  inicializarSensorTemperatura();
  */
  inicializarSensorCorriente();

  // Inicializacion de Actuadores
  inicializarLDR();
  inicializarInterfaz();
  inicializarLCD();
}

void loop() {
 /* datosTemperaturaActual = actualizarTemperatura();
  lecturaGasActual = lecturaAnalogicaGas();
  datosPresenciaActual = leerPresenciaHumana();
  datosCorrienteActual = actualizarDatosEnergia();
  estadoLDR = LDRDigital();
  estadoBotones datosBotonActual = leerBotones(); */
  datosCorrienteActual = actualizarDatosEnergia();
  float corriente = datosCorrienteActual.corriente;
  printearLCD("La corriente es", 0);
  printearLCD(corriente,1);
  Serial.println(" mA");
}