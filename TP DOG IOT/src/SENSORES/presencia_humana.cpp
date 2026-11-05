//Grupo 6 - Ducau, Jeiman & Zonis
#include "presencia_humana.h"

ld2410 sensorPresencia;

// Ultima vez (millis) que llegaron bytes del radar, sean validos o no
static uint32_t ultimosBytesRadar = 0;
// Ultima vez (millis) que la libreria proceso una trama valida del radar
static uint32_t ultimaTramaValida = 0;
static uint32_t bytesRecibidos = 0;

void inicializarSensorPresenciaHumana() {
    // El buffer tiene que agrandarse ANTES del begin. Con el de 256 bytes por defecto
    // se pierden datos si el loop tarda (el radar manda ~10 tramas por segundo a 256000 baudios)
    Serial1.setRxBufferSize(1024);
    Serial1.begin(256000, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN);
    delay(500); // Darle tiempo al sensor para iniciar (como en el código de prueba)

    sensorPresencia.debug(Serial); // Imprime la version de firmware y las respuestas a los comandos
    if (sensorPresencia.begin(Serial1)) {
      Serial.println(F("\nOK"));
    } else {
      Serial.println(F("\nError de conexion radar"));
    }
}

void actualizarSensorPresencia() {
    // read() procesa una sola trama por llamada (la mas vieja del buffer), asi que
    // se llama hasta vaciarlo para quedarse con la lectura mas reciente.
    // El limite evita quedarse trabado si siguen llegando bytes.
    for (uint8_t i = 0; i < MAX_LECTURAS_RADAR; i++) {
        bytesRecibidos += Serial1.available();
        if (!sensorPresencia.read()) break;
        ultimosBytesRadar = millis();
    }

    // La libreria marca el momento de cada trama valida; si fue hace menos de 100 ms
    // isConnected() da true sin tocar el buffer
    if (sensorPresencia.isConnected()) {
        ultimaTramaValida = millis();
    }
}

bool radarConectado() {
    return ultimaTramaValida != 0 && millis() - ultimaTramaValida < TIMEOUT_RADAR_MS;
}

bool radarRecibeBytes() {
    return ultimosBytesRadar != 0 && millis() - ultimosBytesRadar < TIMEOUT_RADAR_MS;
}

uint32_t radarBytesRecibidos() {
    return bytesRecibidos;
}

datosPresenciaHumana leerPresenciaHumana() {
  datosPresenciaHumana datosPresencia = {}; // Todo en false / 0

  if (!radarConectado()) {
    return datosPresencia;
  }
  datosPresencia.conectado = true;

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
  }
  return datosPresencia;
}
