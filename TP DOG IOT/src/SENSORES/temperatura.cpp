//Grupo 6 - Ducau, Jeiman & Zonis
#include "temperatura.h"

 Adafruit_BMP280 sensorTemp; // I2C

void inicializarSensorTemperatura() {
    Wire.begin();
    if (!sensorTemp.begin(0x76)) { // LA DIRECCIÓN PUEDE SER 0x76 o 0x77
        Serial.println("Error al inicializar el sensor BMP280");
    }
    sensorTemp.setSampling(Adafruit_BMP280::MODE_NORMAL,     /* Modo de operación */
                  Adafruit_BMP280::SAMPLING_X2,     /* Sobremuestreo de temperatura */
                  Adafruit_BMP280::SAMPLING_X16,    /* Sobremuestreo de presión */
                  Adafruit_BMP280::FILTER_X16,      /* Coeficiente del filtro IIR */
                  Adafruit_BMP280::STANDBY_MS_500); /* Tiempo de espera en modo normal */
}

datosTemperatura actualizarTemperatura() {
    datosTemperatura datos;
    datos.temperatura = sensorTemp.readTemperature();
    datos.presion = sensorTemp.readPressure() / 100.0F;
    datos.altitud = sensorTemp.readAltitude(1013.25);
    return datos;
}