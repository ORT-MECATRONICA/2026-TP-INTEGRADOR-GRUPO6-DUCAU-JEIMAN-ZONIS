//Grupo 6 - Ducau, Jeiman & Zonis
#include "corriente.h"

Adafruit_INA219 sensorCorriente;
static bool inaEncontrado = false;

void inicializarSensorCorriente() {
    if (sensorCorriente.begin(&Wire1)) {
        inaEncontrado = true;
        Serial.println("INA219 encontrado: " + String(sensorCorriente.getBusVoltage_V(), 2) + " V | " +
                       String(sensorCorriente.getCurrent_mA(), 1) + " mA | shunt " +
                       String(sensorCorriente.getShuntVoltage_mV(), 2) + " mV");
    } else {
        Serial.println("Error al inicializar el sensor INA219");
    }
}

energia actualizarDatosEnergia() {
    energia datos = {}; // Todo en 0
    // Si el sensor no está no se lo lee: cada intento llenaba el monitor serie de errores de I2C
    if (!inaEncontrado) return datos;

    datos.voltaje = abs(sensorCorriente.getBusVoltage_V());
    datos.corriente = abs(sensorCorriente.getCurrent_mA());
    return datos;
}