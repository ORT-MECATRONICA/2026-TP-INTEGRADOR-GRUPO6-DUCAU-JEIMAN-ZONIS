//Grupo 6 - Ducau, Jeiman & Zonis
#include "luz.h"

void inicializarLDR() {
    pinMode(SENSOR_LUZ, INPUT);
}

int porcentajeLuz() {
    int valorAnalogico = analogRead(SENSOR_LUZ);
    int porcentaje = map(valorAnalogico, 0, 4095, 0, 100); //HAY QUE ACORDARSE QUE ESP USA 12 BITS
    return porcentaje;
}