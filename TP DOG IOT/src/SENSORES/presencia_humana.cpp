//Grupo 6 - Ducau, Jeiman & Zonis
#include "presencia_humana.h"

ld2410 sensorPresencia;


void inicializarSensorPresenciaHumana() {
    Serial1.begin(256000, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN);
    delay(500); // Darle tiempo al sensor para iniciar (como en el código de prueba)
    if (sensorPresencia.begin(Serial1)) {
      Serial.println(F("OK"));
    } else {
      Serial.println(F("Error de conexion radar"));
    }
}

void actualizarSensorPresencia() {
    sensorPresencia.read();
}

datosPresenciaHumana leerPresenciaHumana() {
  datosPresenciaHumana datosPresencia = {false, false, 0.0, 0.0, false, 0.0, 0.0};
   if (sensorPresencia.isConnected()) {
    if (sensorPresencia.presenceDetected()) {
      datosPresencia.presencia = true;
      
      if (sensorPresencia.stationaryTargetDetected()) {
        datosPresencia.hayEstatico = true;
        datosPresencia.distanciaEstatica = sensorPresencia.stationaryTargetDistance();
        datosPresencia.energiaEstatica = sensorPresencia.stationaryTargetEnergy();
      }
      
      if (sensorPresencia.movingTargetDetected()) {
        datosPresencia.hayDinamico = true;
        datosPresencia.distanciaDinamica = sensorPresencia.movingTargetDistance();
        datosPresencia.energiaDinamica = sensorPresencia.movingTargetEnergy();
      }
    } else {
      datosPresencia.presencia = false;
    }
  }
  return datosPresencia;
}