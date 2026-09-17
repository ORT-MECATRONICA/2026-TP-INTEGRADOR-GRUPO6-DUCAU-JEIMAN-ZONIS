//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_BMP280.h>
#include "config.h"

void inicializarSensorTemperatura();

struct datosTemperatura {
    float temperatura;
    float presion;
    float altitud;
};

datosTemperatura actualizarTemperatura();