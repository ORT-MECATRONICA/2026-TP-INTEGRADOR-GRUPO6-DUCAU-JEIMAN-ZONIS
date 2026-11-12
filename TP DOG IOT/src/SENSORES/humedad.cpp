//Grupo 6 - Ducau, Jeiman & Zonis
#include "humedad.h"

Adafruit_AHTX0 sensorHumedad;
static bool ahtEncontrado = false;

void inicializarSensorHumedad() {
    if (sensorHumedad.begin(&Wire1)) {
        ahtEncontrado = true;
        Serial.println("AHT encontrado en el bus I2C de 3.3V");
    } else if (sensorHumedad.begin(&Wire)) {
        ahtEncontrado = true;
        Serial.println("AHT encontrado en el bus I2C de 5V");
    } else {
        Serial.println("Error al inicializar el sensor AHT: no responde en 0x38 en ningun bus I2C");
    }
}

datosHumedad actualizarHumedad() {
    datosHumedad datos = {}; // Todo en 0 / false
    if (!ahtEncontrado) return datos;

    sensors_event_t humedad, temperatura;
    if (sensorHumedad.getEvent(&humedad, &temperatura)) {
        datos.temperatura = temperatura.temperature;
        datos.humedad = humedad.relative_humidity;
        datos.conectado = true;
    }
    return datos;
}
