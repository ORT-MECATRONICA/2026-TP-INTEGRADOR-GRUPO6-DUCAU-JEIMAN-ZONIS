//Grupo 6 - Ducau, Jeiman & Zonis
#pragma once
#include <Arduino.h>

//Esta función en realidad inicializa el segundo channel de UART que lo uso para comunicarme  con  el sensor de presencia humana
void inicializarSensorPresenciaHumana();

//Esta función devuelve un booleano que indica si hay presencia humana o no
bool hayPresenciaHumana();

int procesarDistanciaUART();