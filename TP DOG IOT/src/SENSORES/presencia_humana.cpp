//Grupo 6 - Ducau, Jeiman & Zonis
#include "presencia_humana.h"
#include "config.h"

void inicializarSensorPresenciaHumana() {
    Serial2.begin(115200, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN);
    pinMode(PIN_SENSOR_PRESENCIA, INPUT);
}

bool hayPresenciaHumana() {
   return (digitalRead(PIN_SENSOR_PRESENCIA) == HIGH);
}

int procesarDistanciaUART() {
    int distanciaActualCm = 0;
  static uint8_t estadoTrama = 0;
  static uint8_t trama[16]; // Buffer temporal para los bytes de interés
  const uint8_t CABECERA[4] = {0xF4, 0xF3, 0xF2, 0xF1};

  while (Serial2.available()) {
    uint8_t byteLeido = Serial2.read();

    // Máquina de estados para capturar la trama alineada a la cabecera
    if (estadoTrama < 4) {
      if (byteLeido == CABECERA[estadoTrama]) {
        trama[estadoTrama] = byteLeido;
        estadoTrama++;
      } else {
        estadoTrama = 0; // Reinicio si la secuencia de cabecera se rompe
      }
    } else {
      trama[estadoTrama] = byteLeido;
      estadoTrama++;

      // El byte de la compuerta de distancia suele ubicarse en el índice 8
      // tras la cabecera, la longitud y el byte de estado del objetivo.
      if (estadoTrama == 9) {
        int compuertaDistancia = trama[8];
        
        // Conversión matemática de compuerta a centímetros espaciales
        distanciaActualCm = compuertaDistancia * 70;
        
        // Reinicio del estado para esperar la siguiente trama
        estadoTrama = 0; 
      }
    }
  }
  return distanciaActualCm;
}