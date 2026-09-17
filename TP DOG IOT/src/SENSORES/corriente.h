//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_INA219.h>
#include "config.h"

struct energia {
    float voltaje;
    float corriente;
};

void inicializarSensorCorriente();

energia actualizarDatosEnergia();


