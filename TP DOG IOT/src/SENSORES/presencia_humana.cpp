//Grupo 6 - Ducau, Jeiman & Zonis
#include "presencia_humana.h"

ld2410 sensorPresencia;


void inicializarSensorPresenciaHumana() {
    Serial2.begin(256000, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN);
    if (sensorPresencia.begin(Serial2)) {
      Serial.println(F("OK"));
    }
}

datosPresenciaHumana leerPresenciaHumana() {
  datosPresenciaHumana datosPresencia;
  sensorPresencia.read();
   if (sensorPresencia.isConnected()) {
    if (sensorPresencia.presenceDetected()) {
      if (sensorPresencia.stationaryTargetDetected()) {
        datosPresencia.distancia = sensorPresencia.stationaryTargetDistance();
        datosPresencia.energia = sensorPresencia.stationaryTargetEnergy();
        datosPresencia.presencia = true;
        datosPresencia.dinamico = false;
      }
      
      if (sensorPresencia.movingTargetDetected()) {
        datosPresencia.dinamico = true;
        datosPresencia.distancia = sensorPresencia.movingTargetDistance();
        datosPresencia.energia = sensorPresencia.movingTargetEnergy();
        datosPresencia.presencia = true;
      }
    } else {
      datosPresencia.presencia = false;
      datosPresencia.dinamico = false;
    }
  }
  return datosPresencia;
}