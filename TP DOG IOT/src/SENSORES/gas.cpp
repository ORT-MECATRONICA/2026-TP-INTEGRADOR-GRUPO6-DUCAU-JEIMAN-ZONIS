//Grupo 6 - Ducau, Jeiman & Zonis
#include "gas.h"
#include "config.h"

void inicializarSensorGas() {
    pinMode(PIN_SENSOR_GAS, INPUT);
}

uint16_t lecturaAnalogicaGas() {
    return analogRead(PIN_SENSOR_GAS);
}
