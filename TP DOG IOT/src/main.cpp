// Grupo 5: Marco Mallardo, Thiago Ducau, Ramiro Perekalski

#include <Arduino.h>
#include <Wire.h>
#include <ld2410.h>

#include "SENSORES/temperatura.h"
#include "config.h" // RADAR_RX_PIN, RADAR_TX_PIN, SDA_3V3, SCL_3V3

#define MONITOR_SERIAL Serial
#define RADAR_SERIAL Serial1

ld2410 radar;
uint32_t ultimaLectura = 0;

void setup() {
  MONITOR_SERIAL.begin(115200);

  // El BMP280 está en el bus I2C de 3.3V
  Wire1.begin(SDA_3V3, SCL_3V3, 100000);
  inicializarSensorTemperatura();

  RADAR_SERIAL.begin(256000, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN);
  
  delay(500);
  MONITOR_SERIAL.print(F("Iniciando sensor radar LD2410... "));
 
  if (radar.begin(RADAR_SERIAL)) {
    MONITOR_SERIAL.println(F("OK"));
  } else {
    MONITOR_SERIAL.println(F("Error de conexion"));
  }
}
 
void loop() {
  radar.read();
  
  // Reportar cada 1000ms
  if (millis() - ultimaLectura > 1000) {
    ultimaLectura = millis();

    datosTemperatura datosTemp = actualizarTemperatura();
    MONITOR_SERIAL.print(F("Temperatura: "));
    MONITOR_SERIAL.print(datosTemp.temperatura);
    MONITOR_SERIAL.print(F(" C | Presion: "));
    MONITOR_SERIAL.print(datosTemp.presion);
    MONITOR_SERIAL.println(F(" hPa"));

    // La temperatura se imprime siempre; el radar solo si está mandando datos
    if (!radar.isConnected()) {
      MONITOR_SERIAL.println(F("Radar sin datos"));
    } else if (radar.presenceDetected()) {
      if (radar.stationaryTargetDetected()) {
        MONITOR_SERIAL.print(F("Objetivo estatico: "));
        MONITOR_SERIAL.print(radar.stationaryTargetDistance());
        MONITOR_SERIAL.print(F("cm energia: "));
        MONITOR_SERIAL.print(radar.stationaryTargetEnergy());
        MONITOR_SERIAL.print(F(" | "));
      }
      
      if (radar.movingTargetDetected()) {
        MONITOR_SERIAL.print(F("Objetivo en movimiento: "));
        MONITOR_SERIAL.print(radar.movingTargetDistance());
        MONITOR_SERIAL.print(F("cm energia: "));
        MONITOR_SERIAL.print(radar.movingTargetEnergy());
      }
      MONITOR_SERIAL.println();
    } else {
      MONITOR_SERIAL.println(F("Sin presencia"));
    }
  }
}
