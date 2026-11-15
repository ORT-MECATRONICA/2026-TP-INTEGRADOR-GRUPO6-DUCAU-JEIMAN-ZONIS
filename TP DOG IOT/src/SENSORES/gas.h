//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>

void inicializarSensorGas();
uint16_t lecturaAnalogicaGas();   // Lectura tal cual del pin: 0 a 4095
int porcentajeGas();              // Lectura pasada a porcentaje: 0 a 100 (el sensor es un potenciómetro)
