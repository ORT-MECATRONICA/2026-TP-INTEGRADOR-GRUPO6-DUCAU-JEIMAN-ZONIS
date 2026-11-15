//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <EEPROM.h>
#include "config.h"

// Los umbrales de la alarma se guardan en la EEPROM y se cambian desde la aplicación.
// Antes de usar estas funciones hay que llamar a EEPROM.begin(EEPROM_SIZE) en el setup.

struct umbralesAlarma {
    int gas;             // Gas, en la escala de 0 a 99
    float temperatura;   // Temperatura, en grados
};

// Guarda los umbrales en la EEPROM.
// Devuelve false si no se guardaron: valores fuera de rango o falla de la EEPROM
bool guardarUmbrales(umbralesAlarma umbrales);

// Lee los umbrales guardados en la EEPROM.
// Si nunca se guardaron devuelve UMBRAL_GAS_INICIAL y UMBRAL_TEMPERATURA_INICIAL
umbralesAlarma leerUmbrales();
