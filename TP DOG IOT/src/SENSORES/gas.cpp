//Grupo 6 - Ducau, Jeiman & Zonis
#include "gas.h"
#include "config.h"

void inicializarSensorGas() {
    pinMode(PIN_SENSOR_GAS, INPUT);
}

uint16_t lecturaAnalogicaGas() {
    return analogRead(PIN_SENSOR_GAS);
}

int porcentajeGas() {
    int valorAnalogico = analogRead(PIN_SENSOR_GAS);
    // El potenciómetro no recorre todo el rango del pin: va de GAS_LECTURA_MINIMA a GAS_LECTURA_MAXIMA
    int porcentaje = map(valorAnalogico, GAS_LECTURA_MINIMA, GAS_LECTURA_MAXIMA, 0, 100);
    // Si la lectura se pasa un poco de los extremos, queda en 0 o en 100
    porcentaje = constrain(porcentaje, 0, 100);
    return porcentaje;
}
