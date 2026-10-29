//Grupo 6 - Ducau, Jeiman & Zonis
#include "corriente.h"

Adafruit_INA219 sensorCorriente; 

void inicializarSensorCorriente() {
    if (!sensorCorriente.begin(&Wire1)) {
        Serial.println("Error al inicializar el sensor INA219");
    }
}

energia actualizarDatosEnergia() {
    energia datos;
    datos.voltaje = abs(sensorCorriente.getBusVoltage_V());
    datos.corriente = abs(sensorCorriente.getCurrent_mA());
    return datos;
}