//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_AHTX0.h>
#include "config.h"

// Sensor de temperatura y humedad AHT10 / AHT20 / AHT21 (I2C, dirección 0x38)

struct datosHumedad {
    float temperatura; // °C
    float humedad;     // % de humedad relativa
    bool conectado;    // false si el AHT no respondió (temperatura y humedad quedan en 0)
};

// Busca el AHT en el bus de 3.3V (Wire1) y, si no está, en el de 5V (Wire).
// Los dos buses tienen que estar inicializados con sus pines antes de llamarla.
void inicializarSensorHumedad();

// Pide una medición y espera a que termine (tarda unos 80 ms)
datosHumedad actualizarHumedad();
