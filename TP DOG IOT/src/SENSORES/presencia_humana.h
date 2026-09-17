//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>
#include <ld2410.h>
#include "config.h"
//Esta función en realidad inicializa el segundo channel de UART que lo uso para comunicarme  con  el sensor de presencia humana
void inicializarSensorPresenciaHumana();

struct datosPresenciaHumana {
  bool presencia;
  bool hayEstatico;
  float distanciaEstatica;
  float energiaEstatica;
  bool hayDinamico;
  float distanciaDinamica;
  float energiaDinamica;
};

//Esta función devuelve un booleano que indica si hay presencia humana o no
//bool hayPresenciaHumana();

void actualizarSensorPresencia();
datosPresenciaHumana leerPresenciaHumana();