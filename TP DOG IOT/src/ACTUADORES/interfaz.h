//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include "config.h"

struct estadoBotones {
    bool boton1;
    bool boton2;
    bool boton3;
    bool boton4;
    bool boton5;
    bool boton6;
};

void inicializarInterfaz();
estadoBotones leerBotones();
void modificarEstadoLed(bool estado, int pinLed);