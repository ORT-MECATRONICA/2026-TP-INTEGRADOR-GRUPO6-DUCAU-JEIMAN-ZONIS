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
  float distanciaEstatica;   // cm
  float energiaEstatica;     // 0-100
  bool hayDinamico;
  float distanciaDinamica;   // cm
  float energiaDinamica;     // 0-100
  bool conectado;            // false si no llegó ninguna trama válida en los últimos TIMEOUT_RADAR_MS
};

//Hay que llamarla en cada vuelta del loop: pasa los datos del UART a la librería
void actualizarSensorPresencia();

//Devuelve true si llegó una trama válida hace menos de TIMEOUT_RADAR_MS
bool radarConectado();

//Diagnóstico: true si llegaron bytes (válidos o no) hace menos de TIMEOUT_RADAR_MS
bool radarRecibeBytes();

//Diagnóstico: total de bytes recibidos por el UART del radar desde el arranque
uint32_t radarBytesRecibidos();

//Devuelve la última lectura del radar. Si no está conectado, todo viene en false / 0
datosPresenciaHumana leerPresenciaHumana();
