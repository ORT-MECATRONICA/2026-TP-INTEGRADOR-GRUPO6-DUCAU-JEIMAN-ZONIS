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

energia datosEnergia;
datosTemperatura datosTemperaturaActual;
datosPresenciaHumana datosPresencia;

unsigned long tiempoAnterior = 0;

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
  actualizarSensorPresencia(); // Mantiene sincronizado el buffer UART del sensor
  
  if(millis() - tiempoAnterior > 2000){
    tiempoAnterior = millis();
    datosPresencia = leerPresenciaHumana();
    if(datosPresencia.presencia == true){
      Serial.println("Presencia detectada");
      if (datosPresencia.hayEstatico) {
        Serial.print("Objetivo estatico: ");
        Serial.print(datosPresencia.distanciaEstatica);
        Serial.print("cm energia: ");
        Serial.print(datosPresencia.energiaEstatica);
        Serial.print(" | ");
      }
      
      if (datosPresencia.hayDinamico) {
        Serial.print("Objetivo en movimiento: ");
        Serial.print(datosPresencia.distanciaDinamica);
        Serial.print("cm energia: ");
        Serial.print(datosPresencia.energiaDinamica);
      }
      Serial.println();
    } else {
      Serial.println("No hay presencia");
    }
  }
}
