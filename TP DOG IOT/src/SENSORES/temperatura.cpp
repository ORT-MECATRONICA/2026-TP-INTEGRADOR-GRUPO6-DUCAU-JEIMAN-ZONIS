//Grupo 6 - Ducau, Jeiman & Zonis
#include "temperatura.h"

 Adafruit_BMP280 sensorTemp; // I2C

void inicializarSensorTemperatura() {
    Wire.begin();
    
    // Intenta inicializar con la dirección por defecto (0x76) y el Chip ID de BMP280
    bool estado = sensorTemp.begin(0x76);
    
    // Si falla, intenta con la dirección alternativa (0x77)
    if (!estado) estado = sensorTemp.begin(0x77);
    
    // Si sigue fallando, intenta con el Chip ID de un BME280 (0x60)
    // (Muchos módulos vendidos como BMP280 son en realidad BME280)
    if (!estado) estado = sensorTemp.begin(0x76, 0x60);
    if (!estado) estado = sensorTemp.begin(0x77, 0x60);
    
    if (!estado) {
        Serial.println("Error crítico: No se encontró el sensor BMP280 ni BME280.");
        Serial.println("Revisá las conexiones (SDA/SCL) y la alimentación.");
        return; // Salir para no configurar un sensor que no se inicializó
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