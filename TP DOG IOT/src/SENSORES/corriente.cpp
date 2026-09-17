//Grupo 6 - Ducau, Jeiman & Zonis
#include "corriente.h"

Adafruit_INA219 sensorCorriente; 

void inicializarSensorCorriente() {
    Wire.begin();
    if (!sensorCorriente.begin()) {
        Serial.println("Error al inicializar el sensor INA219");
    }
}

energia actualizarDatosEnergia() {
    energia datos;
    datos.voltaje = sensorCorriente.getBusVoltage_V();
    datos.corriente = sensorCorriente.getCurrent_mA();
    return datos;
}